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

    const decodedToken = await auth.verifyIdToken(token);
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
