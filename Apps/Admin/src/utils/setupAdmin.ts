import { createUserWithEmailAndPassword } from 'firebase/auth'
import { doc, setDoc, collection, getDocs } from 'firebase/firestore'
import { auth, db } from '../config/firebase'
import { AdminUser } from '../types/auth'

export async function setupAdminUser() {
  try {
    console.log('Setting up admin user...')
    
    // Create Firebase Auth user
    const userCredential = await createUserWithEmailAndPassword(auth, 'admin@classy.com', 'admin123')
    const user = userCredential.user
    
    console.log('Firebase Auth user created:', user.uid)
    
    // Create admin user document
    const adminUser: Omit<AdminUser, 'id'> = {
      email: 'admin@classy.com',
      name: 'Super Admin',
      role: 'super_admin',
      permissions: [], // Will be populated from ROLE_PERMISSIONS
      isActive: true,
      twoFactorEnabled: false,
      createdAt: new Date(),
      updatedAt: new Date()
    }
    
    await setDoc(doc(db, 'admin_users', user.uid), {
      ...adminUser,
      createdAt: adminUser.createdAt,
      updatedAt: adminUser.updatedAt
    })
    
    console.log('Admin user document created successfully!')
    
    // Sign out the user after creation
    await auth.signOut()
    
    return { success: true, message: 'Admin user created successfully!' }
  } catch (error: any) {
    console.error('Error setting up admin user:', error)
    
    if (error.code === 'auth/email-already-in-use') {
      console.log('Admin user already exists in Firebase Auth')
      return { success: true, message: 'Admin user already exists' }
    }
    
    return { success: false, message: error.message }
  }
}

export async function checkAdminUserExists(): Promise<boolean> {
  try {
    const adminUsersRef = doc(db, 'admin_users', 'check')
    // Try to read the collection to check if it exists
    const snapshot = await getDocs(collection(db, 'admin_users'))
    return !snapshot.empty
  } catch (error) {
    console.error('Error checking admin user:', error)
    return false
  }
}
