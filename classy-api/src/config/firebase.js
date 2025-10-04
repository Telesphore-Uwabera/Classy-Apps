const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
console.log('🔧 Initializing Firebase Admin...');

// Check if we're in development mode
const isDevelopment = process.env.NODE_ENV !== 'production';

if (isDevelopment) {
  console.log('🔧 Development mode: Using Firebase emulator or default credentials');
  
  // Try to use Firebase emulator first
  try {
    // Set emulator environment variables
    process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
    process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';
    
    admin.initializeApp({
      projectId: 'classyapp-unified-backend',
      storageBucket: 'classyapp-unified-backend.appspot.com',
      databaseURL: 'https://classyapp-unified-backend.firebaseio.com'
    });
    
    console.log('✅ Firebase Admin initialized with emulator');
  } catch (error) {
    console.warn('⚠️ Firebase emulator not available, using mock services:', error.message);
    
    // Create enhanced mock Firebase services for development
    const mockDb = {
      collection: (name) => ({
        doc: (id) => ({
          get: () => Promise.resolve({ 
            exists: false, 
            data: () => null, 
            id: id || 'mock-doc-' + Date.now() 
          }),
          set: (data) => {
            console.log(`📝 Mock Firestore: Setting document in ${name}:`, data);
            return Promise.resolve();
          },
          update: (data) => {
            console.log(`📝 Mock Firestore: Updating document in ${name}:`, data);
            return Promise.resolve();
          },
          delete: () => {
            console.log(`🗑️ Mock Firestore: Deleting document in ${name}`);
            return Promise.resolve();
          }
        }),
        where: () => ({
          get: () => Promise.resolve({ docs: [] }),
          limit: () => ({ offset: () => ({ get: () => Promise.resolve({ docs: [] }) }) })
        })
      })
    };
    
    const mockAuth = {
      createUser: (userData) => {
        console.log('👤 Mock Auth: Creating user:', userData);
        return Promise.resolve({ 
          uid: 'mock-uid-' + Date.now(),
          email: userData.email,
          displayName: userData.displayName,
          phoneNumber: userData.phoneNumber
        });
      },
      getUserByEmail: (email) => {
        console.log('👤 Mock Auth: Getting user by email:', email);
        return Promise.resolve({ 
          uid: 'mock-uid-' + Date.now(),
          email: email,
          displayName: 'Mock User'
        });
      },
      createCustomToken: (uid) => {
        console.log('🔑 Mock Auth: Creating custom token for:', uid);
        return Promise.resolve('mock-token-' + Date.now());
      },
      verifyIdToken: (token) => {
        console.log('🔍 Mock Auth: Verifying token:', token);
        return Promise.resolve({ 
          uid: 'mock-uid-' + Date.now(),
          email: 'mock@example.com'
        });
      }
    };
    
    // Export mock services
    module.exports = {
      admin: { firestore: () => mockDb, auth: () => mockAuth },
      db: mockDb,
      auth: mockAuth,
      storage: null,
      messaging: null,
      COLLECTIONS
    };
    return;
  }
} else {
  // Production mode - use service account
  console.log('🔧 Production mode: Using service account credentials');
  
  let serviceAccount = null;
  try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
      serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
    } else if (process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
      // Try to load from file path
      const fs = require('fs');
      const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
      if (fs.existsSync(serviceAccountPath)) {
        serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
      }
    } else {
      // Try default service account key file
      const fs = require('fs');
      const defaultPath = './service-account-key.json';
      if (fs.existsSync(defaultPath)) {
        serviceAccount = JSON.parse(fs.readFileSync(defaultPath, 'utf8'));
        console.log('✅ Loaded service account from file:', defaultPath);
      }
    }
  } catch (error) {
    console.error('❌ Error parsing service account:', error.message);
  }
  
  if (serviceAccount) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: 'classyapp-unified-backend',
      storageBucket: 'classyapp-unified-backend.appspot.com',
      databaseURL: 'https://classyapp-unified-backend.firebaseio.com'
    });
    console.log('✅ Firebase Admin initialized with service account');
  } else {
    throw new Error('Service account credentials required for production');
  }
}

// Export Firebase services
const db = admin.firestore();
const auth = admin.auth();
const storage = admin.storage();
const messaging = admin.messaging();

// Firestore collections
const COLLECTIONS = {
  USERS: 'users',
  VENDORS: 'vendors',
  DRIVERS: 'drivers',
  ORDERS: 'orders',
  PRODUCTS: 'products',
  CATEGORIES: 'categories',
  SERVICES: 'services',
  REVIEWS: 'reviews',
  NOTIFICATIONS: 'notifications',
  ADDRESSES: 'addresses',
  PAYMENT_METHODS: 'payment_methods',
  COUPONS: 'coupons',
  BANNERS: 'banners',
  SETTINGS: 'settings',
  FAQS: 'faqs',
  CHATS: 'chats',
  PAYMENTS: 'payments',
  EARNINGS: 'earnings',
  REPORTS: 'reports'
};

module.exports = {
  admin,
  db,
  auth,
  storage,
  messaging,
  COLLECTIONS
};
