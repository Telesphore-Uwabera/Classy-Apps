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

// Get all orders
router.get('/', verifyToken, async (req, res) => {
  try {
    const { page = 1, limit = 20, status, type } = req.query;
    
    let query = db.collection(COLLECTIONS.ORDERS);

    if (status) {
      query = query.where('status', '==', status);
    }

    if (type) {
      query = query.where('type', '==', type);
    }

    const snapshot = await query
      .orderBy('createdAt', 'desc')
      .limit(parseInt(limit))
      .offset((parseInt(page) - 1) * parseInt(limit))
      .get();

    const orders = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json({
      success: true,
      data: orders,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: orders.length
      }
    });
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders', message: error.message });
  }
});

// Get order by ID
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const doc = await db.collection(COLLECTIONS.ORDERS).doc(id).get();
    
    if (!doc.exists) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json({
      success: true,
      data: {
        id: doc.id,
        ...doc.data()
      }
    });
  } catch (error) {
    console.error('Error fetching order:', error);
    res.status(500).json({ error: 'Failed to fetch order', message: error.message });
  }
});

// Create new order
router.post('/', verifyToken, async (req, res) => {
  try {
    const {
      type, // 'food', 'taxi', 'boda', 'service'
      items,
      customer_id,
      vendor_id,
      delivery_address,
      pickup_address,
      delivery_time,
      payment_method,
      subtotal,
      delivery_fee,
      service_fee,
      discount,
      total,
      notes
    } = req.body;

    // Validate required fields
    if (!type || !customer_id || !total) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Create order object
    const orderData = {
      type,
      customer_id,
      vendor_id: vendor_id || null,
      items: items || [],
      delivery_address: delivery_address || null,
      pickup_address: pickup_address || null,
      delivery_time: delivery_time || null,
      payment_method: payment_method || 'cash',
      subtotal: parseFloat(subtotal) || 0,
      delivery_fee: parseFloat(delivery_fee) || 0,
      service_fee: parseFloat(service_fee) || 0,
      discount: parseFloat(discount) || 0,
      total: parseFloat(total),
      notes: notes || '',
      status: 'pending',
      created_at: new Date(),
      updated_at: new Date(),
      created_by: req.user.uid
    };

    // Save order to Firestore
    const docRef = await db.collection(COLLECTIONS.ORDERS).add(orderData);
    
    // Get the created order
    const createdOrder = await docRef.get();
    
    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: {
        id: docRef.id,
        ...createdOrder.data()
      }
    });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ error: 'Failed to create order', message: error.message });
  }
});

// Update order status
router.put('/:id/status', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    
    const validStatuses = ['pending', 'accepted', 'preparing', 'ready', 'picked_up', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    await db.collection(COLLECTIONS.ORDERS).doc(id).update({
      status,
      updatedAt: new Date()
    });
    
    res.json({
      success: true,
      message: 'Order status updated successfully'
    });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ error: 'Failed to update order status', message: error.message });
  }
});

module.exports = router;
