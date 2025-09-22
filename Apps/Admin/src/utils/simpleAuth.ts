import { signInWithEmailAndPassword, createUserWithEmailAndPassword } from 'firebase/auth'
import { auth } from '../config/firebase'

export async function simpleLogin(email: string, password: string) {
  try {
    // Try to sign in with existing credentials
    const userCredential = await signInWithEmailAndPassword(auth, email, password)
    console.log('Successfully signed in:', userCredential.user.uid)
    
    // Return a mock admin user object for now
    const mockAdminUser = {
      id: userCredential.user.uid,
      email: userCredential.user.email || email,
      name: 'Super Admin',
      role: 'super_admin' as const,
      permissions: [],
      isActive: true,
      twoFactorEnabled: false,
      lastLogin: new Date(),
      createdAt: new Date(),
      updatedAt: new Date()
    }
    
    return mockAdminUser
  } catch (error: any) {
    if (error.code === 'auth/user-not-found') {
      // Try to create the user
      try {
        const userCredential = await createUserWithEmailAndPassword(auth, email, password)
        console.log('Successfully created and signed in:', userCredential.user.uid)
        
        const mockAdminUser = {
          id: userCredential.user.uid,
          email: userCredential.user.email || email,
          name: 'Super Admin',
          role: 'super_admin' as const,
          permissions: [],
          isActive: true,
          twoFactorEnabled: false,
          lastLogin: new Date(),
          createdAt: new Date(),
          updatedAt: new Date()
        }
        
        return mockAdminUser
      } catch (createError) {
        console.error('Error creating user:', createError)
        throw createError
      }
    } else {
      console.error('Error signing in:', error)
      throw error
    }
  }
}
