const express = require('express');
const { db, COLLECTIONS, messaging } = require('../config/firebase');
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

// Get notifications for user
router.get('/', verifyToken, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const userId = req.user.uid;
    
    const snapshot = await db.collection(COLLECTIONS.NOTIFICATIONS)
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(parseInt(limit))
      .offset((parseInt(page) - 1) * parseInt(limit))
      .get();

    const notifications = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json({
      success: true,
      data: notifications,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: notifications.length
      }
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ error: 'Failed to fetch notifications', message: error.message });
  }
});

// Send notification
router.post('/', verifyToken, async (req, res) => {
  try {
    const { title, body, data, userId, type } = req.body;
    
    const notificationData = {
      title,
      body,
      data: data || {},
      userId,
      type: type || 'general',
      createdAt: new Date(),
      read: false
    };

    const docRef = await db.collection(COLLECTIONS.NOTIFICATIONS).add(notificationData);
    
    // Send push notification if FCM token is available
    if (userId) {
      try {
        const userDoc = await db.collection(COLLECTIONS.USERS).doc(userId).get();
        const userData = userDoc.data();
        
        if (userData && userData.fcmToken) {
          await messaging.send({
            token: userData.fcmToken,
            notification: {
              title,
              body
            },
            data: data || {}
          });
        }
      } catch (fcmError) {
        console.error('FCM send error:', fcmError);
        // Don't fail the request if FCM fails
      }
    }
    
    res.status(201).json({
      success: true,
      message: 'Notification sent successfully',
      data: {
        id: docRef.id,
        ...notificationData
      }
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({ error: 'Failed to send notification', message: error.message });
  }
});

// Mark notification as read
router.put('/:id/read', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    
    await db.collection(COLLECTIONS.NOTIFICATIONS).doc(id).update({
      read: true,
      readAt: new Date()
    });
    
    res.json({
      success: true,
      message: 'Notification marked as read'
    });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ error: 'Failed to mark notification as read', message: error.message });
  }
});

module.exports = router;
