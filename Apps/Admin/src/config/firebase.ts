import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getStorage } from 'firebase/storage';

// Firebase configuration - same as Flutter apps
const firebaseConfig = {
  apiKey: "AIzaSyASmUafz431YLkL6d1tNL9qv5cuHC1TkDw",
  authDomain: "classyapp-unified-backend.firebaseapp.com",
  projectId: "classyapp-unified-backend",
  storageBucket: "classyapp-unified-backend.firebasestorage.app",
  messagingSenderId: "156854442550",
  appId: "1:156854442550:web:classyapp-unified-backend"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);

// Firestore collections - same as Flutter apps
export const COLLECTIONS = {
  USERS: 'users',
  VENDORS: 'vendors',
  RESTAURANTS: 'restaurants',
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

export default app;
