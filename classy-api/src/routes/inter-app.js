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

// Get available vendors (for Customer app)
router.get('/vendors/available', verifyToken, async (req, res) => {
  try {
    const { page = 1, limit = 20, category, latitude, longitude } = req.query;
    
    let query = db.collection(COLLECTIONS.VENDORS)
      .where('status', '==', 'approved')
      .where('isActive', '==', true);

    // Apply category filter if provided
    if (category) {
      query = query.where('categories', 'array-contains', category);
    }

    // Apply location filter if provided
    if (latitude && longitude) {
      // For now, we'll skip location filtering as it requires geospatial queries
      // In production, you'd use GeoFirestore or similar
    }

    const snapshot = await query
      .limit(parseInt(limit))
      .offset((parseInt(page) - 1) * parseInt(limit))
      .get();

    const vendors = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json({
      success: true,
      message: 'Vendors fetched successfully',
      data: {
        vendors,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: vendors.length
        }
      }
    });
  } catch (error) {
    console.error('Error fetching vendors:', error);
    res.status(500).json({ error: 'Failed to fetch vendors', message: error.message });
  }
});

// Get available drivers (for Customer app)
router.get('/drivers/available', verifyToken, async (req, res) => {
  try {
    const { page = 1, limit = 20, latitude, longitude, vehicleType } = req.query;
    
    let query = db.collection(COLLECTIONS.DRIVERS)
      .where('status', '==', 'approved')
      .where('isActive', '==', true)
      .where('isOnline', '==', true);

    // Apply vehicle type filter if provided
    if (vehicleType) {
      query = query.where('vehicleType', '==', vehicleType);
    }

    // Apply location filter if provided
    if (latitude && longitude) {
      // For now, we'll skip location filtering as it requires geospatial queries
      // In production, you'd use GeoFirestore or similar
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
      message: 'Drivers fetched successfully',
      data: {
        drivers,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: drivers.length
        }
      }
    });
  } catch (error) {
    console.error('Error fetching drivers:', error);
    res.status(500).json({ error: 'Failed to fetch drivers', message: error.message });
  }
});

// Get products by vendor (for Customer app)
router.get('/vendors/:vendorId/products', verifyToken, async (req, res) => {
  try {
    const { vendorId } = req.params;
    const { page = 1, limit = 20, category } = req.query;
    
    let query = db.collection(COLLECTIONS.PRODUCTS)
      .where('vendorId', '==', vendorId)
      .where('isActive', '==', true);

    // Apply category filter if provided
    if (category) {
      query = query.where('category', '==', category);
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
      message: 'Products fetched successfully',
      data: {
        products,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: products.length
        }
      }
    });
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ error: 'Failed to fetch products', message: error.message });
  }
});

// Get orders for user (for all apps)
router.get('/orders', verifyToken, async (req, res) => {
  try {
    const { page = 1, limit = 20, status, type } = req.query;
    const userId = req.user.uid;
    
    let query = db.collection(COLLECTIONS.ORDERS)
      .where('userId', '==', userId);

    // Apply status filter if provided
    if (status) {
      query = query.where('status', '==', status);
    }

    // Apply type filter if provided
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
      message: 'Orders fetched successfully',
      data: {
        orders,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: orders.length
        }
      }
    });
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders', message: error.message });
  }
});

// Create order (for Customer app)
router.post('/orders', verifyToken, async (req, res) => {
  try {
    const orderData = {
      ...req.body,
      userId: req.user.uid,
      status: 'pending',
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const docRef = await db.collection(COLLECTIONS.ORDERS).add(orderData);
    
    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: {
        id: docRef.id,
        ...orderData
      }
    });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ error: 'Failed to create order', message: error.message });
  }
});

// Update order status (for Driver/Vendor apps)
router.put('/orders/:orderId/status', verifyToken, async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;
    
    const validStatuses = ['pending', 'accepted', 'preparing', 'ready', 'picked_up', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    await db.collection(COLLECTIONS.ORDERS).doc(orderId).update({
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

// Get categories (for all apps)
router.get('/categories', verifyToken, async (req, res) => {
  try {
    const { type } = req.query;
    
    let query = db.collection(COLLECTIONS.CATEGORIES)
      .where('isActive', '==', true);

    // Apply type filter if provided
    if (type) {
      query = query.where('type', '==', type);
    }

    const snapshot = await query.get();
    const categories = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json({
      success: true,
      message: 'Categories fetched successfully',
      data: categories
    });
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ error: 'Failed to fetch categories', message: error.message });
  }
});

// Get app settings (for all apps)
router.get('/settings', async (req, res) => {
  try {
    // Return default app settings
    const settings = {
      strings: {
        app_name: "Classy",
        company_name: "Classy",
        currency: "UGX",
        country_code: "UG",
        enableChat: "1",
        partnersCanRegister: "1",
        otpGateway: "firebase",
        useWebsocketAssignment: false,
        qrcodeLogin: false
      },
      colors: {
        primary: "#E91E63",
        primary_dark: "#C2185B",
        accent: "#FF4081",
        background: "#FFFFFF",
        surface: "#F5F5F5",
        text: "#212121",
        text_secondary: "#757575",
        pendingColor: "#FF9800",
        preparingColor: "#2196F3",
        enrouteColor: "#9C27B0",
        deliveredColor: "#4CAF50",
        cancelledColor: "#F44336",
        failedColor: "#F44336",
        successfulColor: "#4CAF50",
        openColor: "#4CAF50",
        closeColor: "#F44336",
        deliveryColor: "#2196F3",
        pickupColor: "#FF9800",
        ratingColor: "#FFC107"
      },
      ui: {
        theme: "light",
        primaryColor: "#E91E63",
        accentColor: "#FF4081"
      },
      websocket: {
        enabled: false,
        url: ""
      }
    };

    res.json({
      success: true,
      message: 'App settings fetched successfully',
      data: settings
    });
  } catch (error) {
    console.error('Error fetching app settings:', error);
    res.status(500).json({ error: 'Failed to fetch app settings', message: error.message });
  }
});

// Get app onboardings (for all apps)
router.get('/onboardings', async (req, res) => {
  try {
    const onboardings = [
      {
        id: 1,
        title: "Welcome to Classy",
        description: "Your all-in-one delivery and service platform",
        image: "assets/images/1.png",
        color: "#E91E63"
      },
      {
        id: 2,
        title: "Easy Ordering",
        description: "Order food, groceries, and services with just a few taps",
        image: "assets/images/2.png",
        color: "#2196F3"
      },
      {
        id: 3,
        title: "Fast Delivery",
        description: "Get your orders delivered quickly and safely",
        image: "assets/images/3.png",
        color: "#4CAF50"
      }
    ];

    res.json({
      success: true,
      message: 'App onboardings fetched successfully',
      data: onboardings
    });
  } catch (error) {
    console.error('Error fetching app onboardings:', error);
    res.status(500).json({ error: 'Failed to fetch app onboardings', message: error.message });
  }
});

module.exports = router;
