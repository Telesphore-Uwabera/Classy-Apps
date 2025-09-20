const admin = require('firebase-admin');

const authMiddleware = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No Firebase token provided.'
      });
    }

    // Extract Firebase ID token
    const idToken = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Check if Firebase Admin SDK is available
    if (!admin.apps.length) {
      console.warn('Firebase Admin SDK not initialized. Skipping token verification for development.');
      // For development/testing purposes, create a mock user
      req.user = {
        uid: 'mock-user-id',
        phone: '+256700000000',
        email: 'test@classy.app',
        userType: 'customer'
      };
      return next();
    }

    // Verify Firebase ID token
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    
    // Add user info to request
    req.user = {
      uid: decodedToken.uid,
      phone: decodedToken.phone_number,
      email: decodedToken.email,
      // Get user type from custom claims or Firestore
      userType: decodedToken.userType || 'customer'
    };
    
    next();
  } catch (error) {
    console.error('Firebase token verification error:', error);
    return res.status(401).json({
      success: false,
      message: 'Invalid Firebase token.'
    });
  }
};

// Middleware to check user type
const requireUserType = (allowedTypes) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required.'
      });
    }

    const userTypes = Array.isArray(allowedTypes) ? allowedTypes : [allowedTypes];
    
    if (!userTypes.includes(req.user.userType)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Insufficient permissions.'
      });
    }

    next();
  };
};

module.exports = {
  authMiddleware,
  requireUserType
};
