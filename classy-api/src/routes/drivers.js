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

// Get all drivers
router.get('/', verifyToken, async (req, res) => {
  try {
    const { page = 1, limit = 20, status, vehicleType } = req.query;
    
    let query = db.collection(COLLECTIONS.DRIVERS);

    if (status) {
      query = query.where('status', '==', status);
    }

    if (vehicleType) {
      query = query.where('vehicleType', '==', vehicleType);
    }

    const snapshot = await query
      .limit(parseInt(limit))
      .offset((parseInt(page) - 1) * parseInt(limit))
      .get();

    const drivers = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json({
      success: true,
      data: drivers,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: drivers.length
      }
    });
  } catch (error) {
    console.error('Error fetching drivers:', error);
    res.status(500).json({ error: 'Failed to fetch drivers', message: error.message });
  }
});

// Get driver by ID
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const doc = await db.collection(COLLECTIONS.DRIVERS).doc(id).get();
    
    if (!doc.exists) {
      return res.status(404).json({ error: 'Driver not found' });
    }

    res.json({
      success: true,
      data: {
        id: doc.id,
        ...doc.data()
      }
    });
  } catch (error) {
    console.error('Error fetching driver:', error);
    res.status(500).json({ error: 'Failed to fetch driver', message: error.message });
  }
});

// Update driver status
router.put('/:id/status', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    
    const validStatuses = ['pending', 'approved', 'rejected', 'suspended', 'offline', 'online'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    await db.collection(COLLECTIONS.DRIVERS).doc(id).update({
      status,
      updatedAt: new Date()
    });
    
    res.json({
      success: true,
      message: 'Driver status updated successfully'
    });
  } catch (error) {
    console.error('Error updating driver status:', error);
    res.status(500).json({ error: 'Failed to update driver status', message: error.message });
  }
});

module.exports = router;
