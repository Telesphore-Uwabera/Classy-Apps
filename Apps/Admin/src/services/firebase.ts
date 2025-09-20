import { initializeApp } from 'firebase/app';
import { 
  getAuth, 
  signInWithEmailAndPassword, 
  signOut, 
  onAuthStateChanged,
  User as FirebaseUser
} from 'firebase/auth';
import { 
  getFirestore, 
  doc, 
  getDoc, 
  collection, 
  query, 
  where, 
  getDocs, 
  orderBy, 
  limit,
  updateDoc,
  deleteDoc,
  addDoc,
  onSnapshot,
  DocumentData,
  QuerySnapshot
} from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

// Firebase configuration for Admin
// 🔐 SECURITY: API keys moved to environment variables
const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY || "your-firebase-api-key-here",
  authDomain: "classyapp-unified-backend.firebaseapp.com",
  projectId: "classyapp-unified-backend",
  storageBucket: "classyapp-unified-backend.firebasestorage.app",
  messagingSenderId: "156854442550",
  appId: process.env.REACT_APP_FIREBASE_APP_ID || "your-firebase-app-id-here"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const auth = getAuth(app);
export const firestore = getFirestore(app);
export const storage = getStorage(app);

// Admin user interface
export interface AdminUser {
  uid: string;
  email: string;
  name: string;
  role: 'admin' | 'super_admin';
  permissions: string[];
  isActive: boolean;
  lastLogin?: Date;
  createdAt: Date;
}

// Authentication service
export class AdminAuthService {
  static async login(email: string, password: string): Promise<AdminUser> {
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // Get admin profile from Firestore
      const adminDoc = await getDoc(doc(firestore, 'admins', user.uid));
      
      if (!adminDoc.exists()) {
        throw new Error('Admin profile not found');
      }

      const adminData = adminDoc.data();
      
      if (!adminData.isActive) {
        throw new Error('Admin account is deactivated');
      }

      // Update last login
      await updateDoc(doc(firestore, 'admins', user.uid), {
        lastLogin: new Date()
      });

      return {
        uid: user.uid,
        email: user.email!,
        name: adminData.name,
        role: adminData.role,
        permissions: adminData.permissions || [],
        isActive: adminData.isActive,
        lastLogin: new Date(),
        createdAt: adminData.createdAt?.toDate() || new Date()
      };
    } catch (error: any) {
      console.error('Login error:', error);
      throw new Error(error.message || 'Login failed');
    }
  }

  static async logout(): Promise<void> {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Logout error:', error);
      throw error;
    }
  }

  static onAuthStateChanged(callback: (user: FirebaseUser | null) => void) {
    return onAuthStateChanged(auth, callback);
  }

  static getCurrentUser(): FirebaseUser | null {
    return auth.currentUser;
  }

  static async getIdToken(): Promise<string | null> {
    try {
      const user = auth.currentUser;
      if (!user) return null;
      return await user.getIdToken();
    } catch (error) {
      console.error('Error getting ID token:', error);
      return null;
    }
  }
}

// Firestore service for admin operations
export class AdminFirestoreService {
  // Users management
  static async getUsers(userType?: 'customer' | 'vendor' | 'driver') {
    try {
      let q = query(collection(firestore, 'users'));
      
      if (userType) {
        q = query(q, where('userType', '==', userType));
      }
      
      q = query(q, orderBy('createdAt', 'desc'));
      
      const snapshot = await getDocs(q);
      return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
      console.error('Error getting users:', error);
      throw error;
    }
  }

  static async getUserById(userId: string) {
    try {
      const userDoc = await getDoc(doc(firestore, 'users', userId));
      if (!userDoc.exists()) {
        throw new Error('User not found');
      }
      return { id: userDoc.id, ...userDoc.data() };
    } catch (error) {
      console.error('Error getting user:', error);
      throw error;
    }
  }

  static async updateUser(userId: string, updates: any) {
    try {
      await updateDoc(doc(firestore, 'users', userId), {
        ...updates,
        updatedAt: new Date()
      });
    } catch (error) {
      console.error('Error updating user:', error);
      throw error;
    }
  }

  static async approveUser(userId: string, userType: 'vendor' | 'driver') {
    try {
      await updateDoc(doc(firestore, 'users', userId), {
        isApproved: true,
        isActive: true,
        approvedAt: new Date(),
        updatedAt: new Date()
      });
    } catch (error) {
      console.error('Error approving user:', error);
      throw error;
    }
  }

  static async deactivateUser(userId: string) {
    try {
      await updateDoc(doc(firestore, 'users', userId), {
        isActive: false,
        deactivatedAt: new Date(),
        updatedAt: new Date()
      });
    } catch (error) {
      console.error('Error deactivating user:', error);
      throw error;
    }
  }

  // Orders management
  static async getOrders(status?: string, limit?: number) {
    try {
      let q = query(collection(firestore, 'orders'));
      
      if (status) {
        q = query(q, where('status', '==', status));
      }
      
      q = query(q, orderBy('createdAt', 'desc'));
      
      if (limit) {
        q = query(q, limit(limit));
      }
      
      const snapshot = await getDocs(q);
      return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
      console.error('Error getting orders:', error);
      throw error;
    }
  }

  static async getOrderById(orderId: string) {
    try {
      const orderDoc = await getDoc(doc(firestore, 'orders', orderId));
      if (!orderDoc.exists()) {
        throw new Error('Order not found');
      }
      return { id: orderDoc.id, ...orderDoc.data() };
    } catch (error) {
      console.error('Error getting order:', error);
      throw error;
    }
  }

  static async updateOrderStatus(orderId: string, status: string) {
    try {
      await updateDoc(doc(firestore, 'orders', orderId), {
        status,
        updatedAt: new Date()
      });
    } catch (error) {
      console.error('Error updating order status:', error);
      throw error;
    }
  }

  // Transactions management
  static async getTransactions(limit?: number) {
    try {
      let q = query(collection(firestore, 'transactions'), orderBy('createdAt', 'desc'));
      
      if (limit) {
        q = query(q, limit(limit));
      }
      
      const snapshot = await getDocs(q);
      return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
      console.error('Error getting transactions:', error);
      throw error;
    }
  }

  // Analytics and statistics
  static async getDashboardStats() {
    try {
      const [users, orders, transactions] = await Promise.all([
        getDocs(collection(firestore, 'users')),
        getDocs(collection(firestore, 'orders')),
        getDocs(collection(firestore, 'transactions'))
      ]);

      const userStats = {
        total: users.size,
        customers: users.docs.filter(doc => doc.data().userType === 'customer').length,
        vendors: users.docs.filter(doc => doc.data().userType === 'vendor').length,
        drivers: users.docs.filter(doc => doc.data().userType === 'driver').length,
        active: users.docs.filter(doc => doc.data().isActive === true).length,
        pending: users.docs.filter(doc => doc.data().isApproved === false).length
      };

      const orderStats = {
        total: orders.size,
        pending: orders.docs.filter(doc => doc.data().status === 'pending').length,
        confirmed: orders.docs.filter(doc => doc.data().status === 'confirmed').length,
        inProgress: orders.docs.filter(doc => doc.data().status === 'in_progress').length,
        completed: orders.docs.filter(doc => doc.data().status === 'completed').length,
        cancelled: orders.docs.filter(doc => doc.data().status === 'cancelled').length
      };

      let totalRevenue = 0;
      let totalCommission = 0;
      
      transactions.docs.forEach(doc => {
        const data = doc.data();
        if (data.status === 'completed') {
          totalRevenue += data.amount || 0;
          totalCommission += data.classyCommission || 0;
        }
      });

      return {
        users: userStats,
        orders: orderStats,
        revenue: {
          total: totalRevenue,
          commission: totalCommission,
          transactions: transactions.size
        }
      };
    } catch (error) {
      console.error('Error getting dashboard stats:', error);
      throw error;
    }
  }

  // Real-time listeners
  static listenToOrders(callback: (orders: any[]) => void, status?: string) {
    let q = query(collection(firestore, 'orders'));
    
    if (status) {
      q = query(q, where('status', '==', status));
    }
    
    q = query(q, orderBy('createdAt', 'desc'), limit(50));
    
    return onSnapshot(q, (snapshot) => {
      const orders = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      callback(orders);
    });
  }

  static listenToUsers(callback: (users: any[]) => void, userType?: string) {
    let q = query(collection(firestore, 'users'));
    
    if (userType) {
      q = query(q, where('userType', '==', userType));
    }
    
    q = query(q, orderBy('createdAt', 'desc'), limit(100));
    
    return onSnapshot(q, (snapshot) => {
      const users = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      callback(users);
    });
  }

  // Categories management
  static async getCategories() {
    try {
      const q = query(collection(firestore, 'categories'), orderBy('name'));
      const snapshot = await getDocs(q);
      return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
      console.error('Error getting categories:', error);
      throw error;
    }
  }

  static async addCategory(categoryData: any) {
    try {
      const docRef = await addDoc(collection(firestore, 'categories'), {
        ...categoryData,
        createdAt: new Date(),
        updatedAt: new Date()
      });
      return docRef.id;
    } catch (error) {
      console.error('Error adding category:', error);
      throw error;
    }
  }

  static async updateCategory(categoryId: string, updates: any) {
    try {
      await updateDoc(doc(firestore, 'categories', categoryId), {
        ...updates,
        updatedAt: new Date()
      });
    } catch (error) {
      console.error('Error updating category:', error);
      throw error;
    }
  }

  static async deleteCategory(categoryId: string) {
    try {
      await deleteDoc(doc(firestore, 'categories', categoryId));
    } catch (error) {
      console.error('Error deleting category:', error);
      throw error;
    }
  }
}

export default app;
