import { 
  collection, 
  doc, 
  getDocs, 
  getDoc, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  query, 
  where, 
  orderBy, 
  limit, 
  onSnapshot,
  Timestamp,
  serverTimestamp 
} from 'firebase/firestore';
import { db, COLLECTIONS } from '../config/firebase';

export class FirebaseService {
  
  // Generic methods for CRUD operations
  
  // Get all documents from a collection
  async getCollection(collectionName: string, orderByField?: string, limitCount?: number) {
    try {
      let q = collection(db, collectionName);
      
      if (orderByField) {
        q = query(q, orderBy(orderByField, 'desc'));
      }
      
      if (limitCount) {
        q = query(q, limit(limitCount));
      }
      
      const snapshot = await getDocs(q);
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } catch (error) {
      console.error('Error getting collection:', error);
      throw error;
    }
  }

  // Get a single document
  async getDocument(collectionName: string, docId: string) {
    try {
      const docRef = doc(db, collectionName, docId);
      const docSnap = await getDoc(docRef);
      
      if (docSnap.exists()) {
        return {
          id: docSnap.id,
          ...docSnap.data()
        };
      } else {
        throw new Error('Document not found');
      }
    } catch (error) {
      console.error('Error getting document:', error);
      throw error;
    }
  }

  // Add a new document
  async addDocument(collectionName: string, data: any) {
    try {
      const docRef = await addDoc(collection(db, collectionName), {
        ...data,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp()
      });
      return docRef.id;
    } catch (error) {
      console.error('Error adding document:', error);
      throw error;
    }
  }

  // Update a document
  async updateDocument(collectionName: string, docId: string, data: any) {
    try {
      const docRef = doc(db, collectionName, docId);
      await updateDoc(docRef, {
        ...data,
        updatedAt: serverTimestamp()
      });
      return true;
    } catch (error) {
      console.error('Error updating document:', error);
      throw error;
    }
  }

  // Delete a document
  async deleteDocument(collectionName: string, docId: string) {
    try {
      const docRef = doc(db, collectionName, docId);
      await deleteDoc(docRef);
      return true;
    } catch (error) {
      console.error('Error deleting document:', error);
      throw error;
    }
  }

  // Listen to real-time updates for a collection
  subscribeToCollection(collectionName: string, callback: (data: any[]) => void, orderByField?: string) {
    let q = collection(db, collectionName);
    
    if (orderByField) {
      q = query(q, orderBy(orderByField, 'desc'));
    }
    
    return onSnapshot(q, (snapshot) => {
      const data = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      callback(data);
    }, (error) => {
      console.error('Real-time subscription error:', error);
    });
  }

  // Listen to real-time updates for a single document
  subscribeToDocument(collectionName: string, docId: string, callback: (data: any) => void) {
    const docRef = doc(db, collectionName, docId);
    
    return onSnapshot(docRef, (doc) => {
      if (doc.exists()) {
        const data = {
          id: doc.id,
          ...doc.data()
        };
        callback(data);
      }
    });
  }

  // Query with conditions
  async queryCollection(collectionName: string, conditions: { field: string; operator: any; value: any }[]) {
    try {
      let q = collection(db, collectionName);
      
      conditions.forEach(condition => {
        q = query(q, where(condition.field, condition.operator, condition.value));
      });
      
      const snapshot = await getDocs(q);
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } catch (error) {
      console.error('Error querying collection:', error);
      throw error;
    }
  }

  // Specific methods for admin dashboard

  // Get all customers
  async getCustomers() {
    try {
      const users = await this.getCollection(COLLECTIONS.USERS);
      // Filter users with role 'customer' or no role (default to customer)
      return users.filter(user => user.role === 'customer' || !user.role);
    } catch (error) {
      console.error('Error getting customers:', error);
      return [];
    }
  }

  // Get all vendors
  async getVendors() {
    try {
      return await this.getCollection(COLLECTIONS.VENDORS);
    } catch (error) {
      console.error('Error getting vendors:', error);
      return [];
    }
  }

  // Get all drivers
  async getDrivers() {
    try {
      return await this.getCollection(COLLECTIONS.DRIVERS);
    } catch (error) {
      console.error('Error getting drivers:', error);
      return [];
    }
  }

  // Get all orders
  async getOrders() {
    try {
      return await this.getCollection(COLLECTIONS.ORDERS);
    } catch (error) {
      console.error('Error getting orders:', error);
      return [];
    }
  }

  // Get all products
  async getProducts() {
    return this.getCollection(COLLECTIONS.PRODUCTS, 'createdAt');
  }

  // Get all categories
  async getCategories() {
    return this.getCollection(COLLECTIONS.CATEGORIES, 'createdAt');
  }

  // Get orders by status
  async getOrdersByStatus(status: string) {
    return this.queryCollection(COLLECTIONS.ORDERS, [
      { field: 'status', operator: '==', value: status }
    ]);
  }

  // Get users by role
  async getUsersByRole(role: string) {
    return this.queryCollection(COLLECTIONS.USERS, [
      { field: 'role', operator: '==', value: role }
    ]);
  }

  // Get pending vendor requests
  async getPendingVendors() {
    return this.queryCollection(COLLECTIONS.VENDORS, [
      { field: 'status', operator: '==', value: 'pending' }
    ]);
  }

  // Get pending driver requests
  async getPendingDrivers() {
    return this.queryCollection(COLLECTIONS.DRIVERS, [
      { field: 'status', operator: '==', value: 'pending' }
    ]);
  }

  // Get statistics
  async getDashboardStats() {
    try {
      const [customers, vendors, drivers, orders] = await Promise.all([
        this.getCustomers(),
        this.getVendors(),
        this.getDrivers(),
        this.getOrders()
      ]);

      const pendingVendors = await this.getPendingVendors();
      const pendingDrivers = await this.getPendingDrivers();

      return {
        customers: customers.length,
        vendors: vendors.length,
        drivers: drivers.length,
        orders: orders.length,
        pendingVendors: pendingVendors.length,
        pendingDrivers: pendingDrivers.length
      };
    } catch (error) {
      console.error('Error getting dashboard stats:', error);
      throw error;
    }
  }

  // Update user status (block/unblock)
  async updateUserStatus(userId: string, status: string) {
    return this.updateDocument(COLLECTIONS.USERS, userId, { status });
  }

  // Update vendor status (approve/reject)
  async updateVendorStatus(vendorId: string, status: string) {
    return this.updateDocument(COLLECTIONS.VENDORS, vendorId, { status });
  }

  // Update driver status (approve/reject)
  async updateDriverStatus(driverId: string, status: string) {
    return this.updateDocument(COLLECTIONS.DRIVERS, driverId, { status });
  }

  // Update order status
  async updateOrderStatus(orderId: string, status: string) {
    return this.updateDocument(COLLECTIONS.ORDERS, orderId, { status });
  }

  // Send notification
  async sendNotification(notificationData: any) {
    return this.addDocument(COLLECTIONS.NOTIFICATIONS, notificationData);
  }

  // Get notifications
  async getNotifications() {
    return this.getCollection(COLLECTIONS.NOTIFICATIONS, 'createdAt');
  }

  // Real-time dashboard updates
  subscribeToDashboardUpdates(callback: (stats: any) => void) {
    const unsubscribeFunctions: (() => void)[] = [];
    
    // Subscribe to users
    const unsubscribeUsers = this.subscribeToCollection(COLLECTIONS.USERS, (users) => {
      const customers = users.filter(user => user.role === 'customer' || !user.role);
      callback({ customers: customers.length });
    });
    unsubscribeFunctions.push(unsubscribeUsers);
    
    // Subscribe to vendors
    const unsubscribeVendors = this.subscribeToCollection(COLLECTIONS.VENDORS, (vendors) => {
      const activeVendors = vendors.filter(vendor => 
        vendor.status === 'active' || vendor.status === 'approved' || vendor.status === 'online'
      );
      const pendingVendors = vendors.filter(vendor => 
        vendor.status === 'pending' || vendor.status === 'offline' || !vendor.status
      );
      callback({ 
        vendors: activeVendors.length,
        pendingVendors: pendingVendors.length
      });
    });
    unsubscribeFunctions.push(unsubscribeVendors);
    
    // Subscribe to drivers
    const unsubscribeDrivers = this.subscribeToCollection(COLLECTIONS.DRIVERS, (drivers) => {
      const activeDrivers = drivers.filter(driver => 
        driver.status === 'active' || driver.status === 'approved' || driver.status === 'online'
      );
      const pendingDrivers = drivers.filter(driver => 
        driver.status === 'pending' || driver.status === 'offline' || !driver.status
      );
      callback({ 
        drivers: activeDrivers.length,
        pendingDrivers: pendingDrivers.length
      });
    });
    unsubscribeFunctions.push(unsubscribeDrivers);
    
    // Subscribe to orders
    const unsubscribeOrders = this.subscribeToCollection(COLLECTIONS.ORDERS, (orders) => {
      callback({ orders: orders.length });
    });
    unsubscribeFunctions.push(unsubscribeOrders);
    
    // Return cleanup function
    return () => {
      unsubscribeFunctions.forEach(unsubscribe => unsubscribe());
    };
  }
}

export const firebaseService = new FirebaseService();
