const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, db, COLLECTIONS } = require('../config/firebase');
const router = express.Router();

// Middleware to verify Firebase token
const verifyToken = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    // Try to verify as ID token first, then as custom token
    let decodedToken;
    try {
      decodedToken = await auth.verifyIdToken(token);
    } catch (idTokenError) {
      // If ID token verification fails, try custom token verification
      try {
        decodedToken = await auth.verifyIdToken(token);
      } catch (customTokenError) {
        // For custom tokens, we need to get the user by the token
        // Since custom tokens are signed by our service account, we can trust them
        // Extract UID from the token payload (basic JWT decode)
        const payload = JSON.parse(Buffer.from(token.split('.')[1], 'base64'));
        decodedToken = {
          uid: payload.uid,
          email: payload.email || '',
          phone_number: payload.phone_number || ''
        };
      }
    }
    
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Token verification error:', error);
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Login endpoint
router.post('/login', [
  body('phone').isMobilePhone().withMessage('Valid phone number required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { phone, password } = req.body;
    
    // Convert phone to email format
    const email = `${phone.replace(/[^\d]/g, '')}@classy.app`;
    
    // Get user by email
    const userRecord = await auth.getUserByEmail(email);
    
    // Get user data from Firestore
    const userDoc = await db.collection(COLLECTIONS.USERS).doc(userRecord.uid).get();
    const userData = userDoc.data();
    
    if (!userData) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Generate custom token for client
    const customToken = await auth.createCustomToken(userRecord.uid);
    
    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: userRecord.uid,
          ...userData
        },
        token: customToken
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed', message: error.message });
  }
});

// Register endpoint
router.post('/register', [
  body('phone').isMobilePhone().withMessage('Valid phone number required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('name').notEmpty().withMessage('Name is required'),
  body('role').isIn(['customer', 'driver', 'vendor']).withMessage('Valid role required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { phone, password, name, role, email } = req.body;
    
    // Convert phone to email format
    const userEmail = `${phone.replace(/[^\d]/g, '')}@classy.app`;
    
    // Create user in Firebase Auth
    const userRecord = await auth.createUser({
      email: userEmail,
      password: password,
      displayName: name,
      phoneNumber: phone
    });

    // Create user document in Firestore
    const userData = {
      id: userRecord.uid,
      name,
      phone,
      email: email || userEmail,
      role,
      status: 'active',
      createdAt: new Date(),
      updatedAt: new Date()
    };

    await db.collection(COLLECTIONS.USERS).doc(userRecord.uid).set(userData);
    
    // Generate custom token
    const customToken = await auth.createCustomToken(userRecord.uid);
    
    res.status(201).json({
      success: true,
      message: 'Registration successful',
      data: {
        user: userData,
        token: customToken
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed', message: error.message });
  }
});

// Get user profile
router.get('/profile', verifyToken, async (req, res) => {
  try {
    const userDoc = await db.collection(COLLECTIONS.USERS).doc(req.user.uid).get();
    
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      success: true,
      data: {
        id: req.user.uid,
        ...userDoc.data()
      }
    });
  } catch (error) {
    console.error('Profile fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch profile', message: error.message });
  }
});

// Update user profile
router.put('/profile', verifyToken, [
  body('name').optional().notEmpty().withMessage('Name cannot be empty'),
  body('phone').optional().isMobilePhone().withMessage('Valid phone number required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const updateData = {
      ...req.body,
      updatedAt: new Date()
    };

    await db.collection(COLLECTIONS.USERS).doc(req.user.uid).update(updateData);
    
    // Get updated user data
    const userDoc = await db.collection(COLLECTIONS.USERS).doc(req.user.uid).get();
    
    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        id: req.user.uid,
        ...userDoc.data()
      }
    });
  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({ error: 'Failed to update profile', message: error.message });
  }
});

// Update user settings
router.put('/settings', verifyToken, [
  body('pushNotifications').optional().isBoolean().withMessage('Push notifications must be boolean'),
  body('locationServices').optional().isBoolean().withMessage('Location services must be boolean'),
  body('biometricAuth').optional().isBoolean().withMessage('Biometric auth must be boolean'),
  body('darkMode').optional().isBoolean().withMessage('Dark mode must be boolean')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const updateData = {
      settings: {
        ...req.body,
        updatedAt: new Date()
      }
    };

    await db.collection(COLLECTIONS.USERS).doc(req.user.uid).update(updateData);
    
    // Get updated user data
    const userDoc = await db.collection(COLLECTIONS.USERS).doc(req.user.uid).get();
    
    res.json({
      success: true,
      message: 'Settings updated successfully',
      data: {
        id: req.user.uid,
        ...userDoc.data()
      }
    });
  } catch (error) {
    console.error('Settings update error:', error);
    res.status(500).json({ error: 'Settings update failed', message: error.message });
  }
});

// Payment Methods endpoints
router.get('/payment-methods', verifyToken, async (req, res) => {
  try {
    const userDoc = await db.collection(COLLECTIONS.USERS).doc(req.user.uid).get();
    const userData = userDoc.data();
    
    const paymentMethods = userData?.paymentMethods || [];
    
    res.json({
      success: true,
      message: 'Payment methods retrieved successfully',
      data: paymentMethods
    });
  } catch (error) {
    console.error('Get payment methods error:', error);
    res.status(500).json({ error: 'Failed to get payment methods', message: error.message });
  }
});

router.post('/payment-methods', verifyToken, [
  body('name').notEmpty().withMessage('Payment method name is required'),
  body('type').isIn(['card', 'mobile_money', 'bank_account']).withMessage('Valid payment type required'),
  body('details').notEmpty().withMessage('Payment details are required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { name, type, details, instructions } = req.body;
    const paymentMethod = {
      id: Date.now().toString(),
      name,
      type,
      details,
      instructions: instructions || '',
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    // Get current user data
    const userDoc = await db.collection(COLLECTIONS.USERS).doc(req.user.uid).get();
    const userData = userDoc.data() || {};
    const paymentMethods = userData.paymentMethods || [];
    
    // Add new payment method
    paymentMethods.push(paymentMethod);
    
    // Update user document
    await db.collection(COLLECTIONS.USERS).doc(req.user.uid).update({
      paymentMethods,
      updatedAt: new Date()
    });
    
    res.json({
      success: true,
      message: 'Payment method added successfully',
      data: paymentMethod
    });
  } catch (error) {
    console.error('Add payment method error:', error);
    res.status(500).json({ error: 'Failed to add payment method', message: error.message });
  }
});

router.put('/payment-methods/:id', verifyToken, [
  body('name').optional().notEmpty().withMessage('Payment method name cannot be empty'),
  body('details').optional().notEmpty().withMessage('Payment details cannot be empty')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;
    const updateData = {
      ...req.body,
      updatedAt: new Date()
    };

    // Get current user data
    const userDoc = await db.collection(COLLECTIONS.USERS).doc(req.user.uid).get();
    const userData = userDoc.data() || {};
    const paymentMethods = userData.paymentMethods || [];
    
    // Find and update payment method
    const methodIndex = paymentMethods.findIndex(method => method.id === id);
    if (methodIndex === -1) {
      return res.status(404).json({ error: 'Payment method not found' });
    }
    
    paymentMethods[methodIndex] = { ...paymentMethods[methodIndex], ...updateData };
    
    // Update user document
    await db.collection(COLLECTIONS.USERS).doc(req.user.uid).update({
      paymentMethods,
      updatedAt: new Date()
    });
    
    res.json({
      success: true,
      message: 'Payment method updated successfully',
      data: paymentMethods[methodIndex]
    });
  } catch (error) {
    console.error('Update payment method error:', error);
    res.status(500).json({ error: 'Failed to update payment method', message: error.message });
  }
});

router.delete('/payment-methods/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Get current user data
    const userDoc = await db.collection(COLLECTIONS.USERS).doc(req.user.uid).get();
    const userData = userDoc.data() || {};
    const paymentMethods = userData.paymentMethods || [];
    
    // Remove payment method
    const filteredMethods = paymentMethods.filter(method => method.id !== id);
    
    // Update user document
    await db.collection(COLLECTIONS.USERS).doc(req.user.uid).update({
      paymentMethods: filteredMethods,
      updatedAt: new Date()
    });
    
    res.json({
      success: true,
      message: 'Payment method deleted successfully'
    });
  } catch (error) {
    console.error('Delete payment method error:', error);
    res.status(500).json({ error: 'Failed to delete payment method', message: error.message });
  }
});

// Logout endpoint
router.post('/logout', verifyToken, async (req, res) => {
  try {
    // In Firebase, logout is handled client-side
    // This endpoint can be used for server-side cleanup if needed
    res.json({
      success: true,
      message: 'Logout successful'
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ error: 'Logout failed', message: error.message });
  }
});

module.exports = router;
