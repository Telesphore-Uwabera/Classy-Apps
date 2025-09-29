const express = require('express');
const { db, COLLECTIONS } = require('../config/firebase');
const router = express.Router();

// Middleware to verify Firebase token
const verifyToken = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const { auth } = require('../config/firebase');
    const decodedToken = await auth.verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Token verification error:', error);
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Get all products
router.get('/', verifyToken, async (req, res) => {
  try {
    const { page = 1, limit = 20, category, vendorId } = req.query;
    
    let query = db.collection(COLLECTIONS.PRODUCTS)
      .where('isActive', '==', true);

    if (category) {
      query = query.where('category', '==', category);
    }

    if (vendorId) {
      query = query.where('vendorId', '==', vendorId);
    }

    const snapshot = await query
      .limit(parseInt(limit))
      .offset((parseInt(page) - 1) * parseInt(limit))
      .get();

    const products = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json({
      success: true,
      data: products,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: products.length
      }
    });
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ error: 'Failed to fetch products', message: error.message });
  }
});

// Get product by ID
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const doc = await db.collection(COLLECTIONS.PRODUCTS).doc(id).get();
    
    if (!doc.exists) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.json({
      success: true,
      data: {
        id: doc.id,
        ...doc.data()
      }
    });
  } catch (error) {
    console.error('Error fetching product:', error);
    res.status(500).json({ error: 'Failed to fetch product', message: error.message });
  }
});

module.exports = router;
