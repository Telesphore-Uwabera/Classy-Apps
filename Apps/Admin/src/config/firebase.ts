import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getStorage } from 'firebase/storage';

// Firebase configuration - same as Flutter apps
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || "AIzaSyASmUafz431YLkL6d1tNL9qv5cuHC1TkDw",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || "classyapp-unified-backend.firebaseapp.com",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || "classyapp-unified-backend",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || "classyapp-unified-backend.firebasestorage.app",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || "156854442550",
  appId: import.meta.env.VITE_FIREBASE_APP_ID || "1:156854442550:web:classyapp-unified-backend"
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
