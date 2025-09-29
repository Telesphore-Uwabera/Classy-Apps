const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
let serviceAccount;
try {
  // Try to load service account from environment variable or file
  if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
  } else {
    // Fallback to default service account (for local development)
    serviceAccount = {
      type: "service_account",
      project_id: "classyapp-unified-backend",
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
      private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      client_id: process.env.FIREBASE_CLIENT_ID,
      auth_uri: "https://accounts.google.com/o/oauth2/auth",
      token_uri: "https://oauth2.googleapis.com/token",
      auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
      client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${process.env.FIREBASE_CLIENT_EMAIL}`
    };
  }
} catch (error) {
  console.error('Error loading Firebase service account:', error);
  // Use default credentials for development
  serviceAccount = null;
}

// Initialize Firebase Admin
if (serviceAccount) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'classyapp-unified-backend',
    storageBucket: 'classyapp-unified-backend.appspot.com',
    databaseURL: 'https://classyapp-unified-backend.firebaseio.com'
  });
} else {
  // Use default credentials (for local development with gcloud auth)
  admin.initializeApp({
    projectId: 'classyapp-unified-backend',
    storageBucket: 'classyapp-unified-backend.appspot.com',
    databaseURL: 'https://classyapp-unified-backend.firebaseio.com'
  });
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
