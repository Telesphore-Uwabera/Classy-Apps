const admin = require('firebase-admin');

class FirebaseService {
  constructor() {
    this.db = null;
    this.auth = null;
  }

  initialize() {
    try {
      // Check if Firebase credentials are available
      const hasCredentials = process.env.FIREBASE_PROJECT_ID && 
                            process.env.FIREBASE_CLIENT_EMAIL && 
                            process.env.FIREBASE_PRIVATE_KEY;

      if (!hasCredentials) {
        console.log('⚠️ Firebase Admin SDK credentials not found. Running without Firebase backend.');
        this.isInitialized = false;
        return;
      }

      // Initialize Firebase Admin SDK
      if (!admin.apps.length) {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId: process.env.FIREBASE_PROJECT_ID,
            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
            privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n')
          }),
          databaseURL: `https://${process.env.FIREBASE_PROJECT_ID}.firebaseio.com`
        });
      }

      this.db = admin.firestore();
      this.auth = admin.auth();
      this.isInitialized = true;
      
      console.log('✅ Firebase Admin SDK initialized successfully');
    } catch (error) {
      console.error('❌ Firebase initialization error:', error);
      console.log('⚠️ Continuing without Firebase Admin SDK');
      this.isInitialized = false;
    }
  }

  // Firebase Admin SDK for backend operations only
  // Authentication is handled 100% by Firebase client SDK in Flutter apps

  // Transaction methods
  async createTransaction(transactionData) {
    try {
      const transactionRef = this.db.collection('transactions').doc();
      await transactionRef.set({
        id: transactionRef.id,
        ...transactionData,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      return transactionRef.id;
    } catch (error) {
      throw error;
    }
  }

  async updateTransaction(transactionId, updateData) {
    try {
      await this.db.collection('transactions').doc(transactionId).update({
        ...updateData,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      return true;
    } catch (error) {
      throw error;
    }
  }

  async getTransaction(transactionId) {
    try {
      const doc = await this.db.collection('transactions').doc(transactionId).get();
      return doc.exists ? { id: doc.id, ...doc.data() } : null;
    } catch (error) {
      throw error;
    }
  }

  // Order methods
  async createOrder(orderData) {
    try {
      const orderRef = this.db.collection('orders').doc();
      await orderRef.set({
        id: orderRef.id,
        ...orderData,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      return orderRef.id;
    } catch (error) {
      throw error;
    }
  }

  async updateOrder(orderId, updateData) {
    try {
      await this.db.collection('orders').doc(orderId).update({
        ...updateData,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      return true;
    } catch (error) {
      throw error;
    }
  }

  async getOrder(orderId) {
    try {
      const doc = await this.db.collection('orders').doc(orderId).get();
      return doc.exists ? { id: doc.id, ...doc.data() } : null;
    } catch (error) {
      throw error;
    }
  }

  // Notification methods
  async sendNotification(tokens, notification) {
    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body
        },
        data: notification.data || {},
        tokens: Array.isArray(tokens) ? tokens : [tokens]
      };

      const response = await admin.messaging().sendMulticast(message);
      return response;
    } catch (error) {
      console.error('Notification error:', error);
      throw error;
    }
  }
}

module.exports = new FirebaseService();
