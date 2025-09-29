import { initializeApp } from 'firebase/app'
import { getAuth, createUserWithEmailAndPassword, signInWithEmailAndPassword } from 'firebase/auth'
import { getFirestore, doc, setDoc, getDoc } from 'firebase/firestore'

// Initialize Firebase with admin SDK (if available) or use client SDK with relaxed rules
const firebaseConfig = {
  apiKey: "AIzaSyASmUafz431YLkL6d1tNL9qv5cuHC1TkDw",
  authDomain: "classyapp-unified-backend.firebaseapp.com",
  projectId: "classyapp-unified-backend",
  storageBucket: "classyapp-unified-backend.firebasestorage.app",
  messagingSenderId: "156854442550",
  appId: "1:156854442550:web:classyapp-unified-backend"
}

// Create a separate Firebase instance for setup
const setupApp = initializeApp(firebaseConfig, 'setup')
const setupAuth = getAuth(setupApp)
const setupDb = getFirestore(setupApp)

export async function setupAdminUserDirect() {
  try {
    console.log('Setting up admin user with direct Firebase access...')
    
    // First, try to sign in with existing credentials
    let user
    try {
      const userCredential = await signInWithEmailAndPassword(setupAuth, 'admin@classy.com', 'admin123')
      user = userCredential.user
      console.log('Signed in with existing admin user')
    } catch (error: any) {
      if (error.code === 'auth/user-not-found') {
        // Create new user if doesn't exist
        console.log('Creating new admin user...')
        const userCredential = await createUserWithEmailAndPassword(setupAuth, 'admin@classy.com', 'admin123')
        user = userCredential.user
        console.log('Created new admin user:', user.uid)
      } else {
        throw error
      }
    }

    // Create admin user document
    const adminUserData = {
      email: 'admin@classy.com',
      name: 'Super Admin',
      role: 'super_admin',
      permissions: [],
      isActive: true,
      twoFactorEnabled: false,
      createdAt: new Date(),
      updatedAt: new Date()
    }

    try {
      await setDoc(doc(setupDb, 'admin_users', user.uid), adminUserData)
      console.log('Admin user document created successfully!')
    } catch (error: any) {
      console.error('Error creating admin user document:', error)
      
      // If it's a permissions error, try to create the collection with a different approach
      if (error.code === 'permission-denied') {
        console.log('Permission denied. This might be due to Firestore security rules.')
        console.log('Please check your Firestore security rules and ensure they allow writes to admin_users collection.')
        return {
          success: false,
          message: 'Permission denied. Please check Firestore security rules for admin_users collection.',
          needsRulesUpdate: true
        }
      }
      throw error
    }

    // Sign out after setup
    await setupAuth.signOut()
    
    return {
      success: true,
      message: 'Admin user created successfully! You can now log in.',
      userId: user.uid
    }
  } catch (error: any) {
    console.error('Error setting up admin user:', error)
    return {
      success: false,
      message: error.message,
      needsRulesUpdate: error.code === 'permission-denied'
    }
  }
}

export async function checkFirestoreRules() {
  try {
    // Try to read from a test document
    const testDoc = await getDoc(doc(setupDb, 'test', 'permissions'))
    return { canRead: true, canWrite: false }
  } catch (error: any) {
    if (error.code === 'permission-denied') {
      return { canRead: false, canWrite: false }
    }
    return { canRead: true, canWrite: true }
  }
}
