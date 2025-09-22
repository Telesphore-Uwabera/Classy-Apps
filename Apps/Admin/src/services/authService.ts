import { 
  signInWithEmailAndPassword, 
  signOut, 
  onAuthStateChanged,
  User as FirebaseUser
} from 'firebase/auth'
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore'
import { auth, db } from '../config/firebase'
import { AdminUser, AdminRole, ROLE_PERMISSIONS, TwoFactorAuth } from '../types/auth'

class AuthService {
  private currentUser: AdminUser | null = null
  private authStateListeners: ((user: AdminUser | null) => void)[] = []

  constructor() {
    onAuthStateChanged(auth, async (firebaseUser: FirebaseUser | null) => {
      if (firebaseUser) {
        const adminUser = await this.getAdminUser(firebaseUser.uid)
        this.currentUser = adminUser
        this.notifyListeners(adminUser)
      } else {
        this.currentUser = null
        this.notifyListeners(null)
      }
    })
  }

  async signIn(email: string, password: string): Promise<AdminUser> {
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password)
      const adminUser = await this.getAdminUser(userCredential.user.uid)
      
      if (!adminUser) {
        // If user exists in Firebase Auth but not in admin database, create them
        if (email === 'admin@classy.com') {
          console.log('Creating admin user in database...')
          const newAdminUser: Omit<AdminUser, 'id' | 'createdAt' | 'updatedAt'> = {
            email: 'admin@classy.com',
            name: 'Super Admin',
            role: 'super_admin',
            permissions: [],
            isActive: true,
            twoFactorEnabled: false
          }
          
          const adminUserId = await this.createAdminUser(newAdminUser)
          const createdAdminUser = await this.getAdminUser(adminUserId)
          
          if (createdAdminUser) {
            this.currentUser = createdAdminUser
            return createdAdminUser
          }
        }
        
        throw new Error('User not found in admin database. Please use the "Setup Admin User" button first.')
      }

      if (!adminUser.isActive) {
        throw new Error('Account is deactivated')
      }

      // Update last login
      await this.updateLastLogin(adminUser.id)
      
      this.currentUser = adminUser
      return adminUser
    } catch (error) {
      console.error('Sign in error:', error)
      throw error
    }
  }

  async signOut(): Promise<void> {
    try {
      await signOut(auth)
      this.currentUser = null
    } catch (error) {
      console.error('Sign out error:', error)
      throw error
    }
  }

  async getAdminUser(uid: string): Promise<AdminUser | null> {
    try {
      const userDoc = await getDoc(doc(db, 'admin_users', uid))
      if (userDoc.exists()) {
        const data = userDoc.data()
        return {
          id: userDoc.id,
          ...data,
          lastLogin: data.lastLogin?.toDate(),
          createdAt: data.createdAt?.toDate(),
          updatedAt: data.updatedAt?.toDate()
        } as AdminUser
      }
      return null
    } catch (error: any) {
      console.error('Error getting admin user:', error)
      
      // If it's a permissions error, the collection might not exist yet
      if (error.code === 'permission-denied' || error.message?.includes('permissions')) {
        console.log('Admin users collection does not exist or has insufficient permissions')
        return null
      }
      
      return null
    }
  }

  async createAdminUser(adminUser: Omit<AdminUser, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const userRef = doc(db, 'admin_users', adminUser.email)
      const now = new Date()
      
      await setDoc(userRef, {
        ...adminUser,
        createdAt: now,
        updatedAt: now
      })
      
      return userRef.id
    } catch (error) {
      console.error('Error creating admin user:', error)
      throw error
    }
  }

  async updateLastLogin(userId: string): Promise<void> {
    try {
      await updateDoc(doc(db, 'admin_users', userId), {
        lastLogin: new Date()
      })
    } catch (error) {
      console.error('Error updating last login:', error)
    }
  }

  hasPermission(resource: string, action: string): boolean {
    if (!this.currentUser) return false
    
    const permissions = ROLE_PERMISSIONS[this.currentUser.role] || []
    const resourcePermission = permissions.find(p => p.resource === resource)
    
    return resourcePermission?.actions.includes(action as any) || false
  }

  getCurrentUser(): AdminUser | null {
    return this.currentUser
  }

  onAuthStateChange(callback: (user: AdminUser | null) => void): () => void {
    this.authStateListeners.push(callback)
    
    // Return unsubscribe function
    return () => {
      const index = this.authStateListeners.indexOf(callback)
      if (index > -1) {
        this.authStateListeners.splice(index, 1)
      }
    }
  }

  private notifyListeners(user: AdminUser | null): void {
    this.authStateListeners.forEach(callback => callback(user))
  }

  // Two-Factor Authentication methods
  async generateTwoFactorSecret(): Promise<TwoFactorAuth> {
    // This would integrate with a 2FA library like speakeasy
    // For now, returning mock data
    return {
      secret: 'mock-secret-key',
      qrCode: 'data:image/png;base64,mock-qr-code',
      backupCodes: ['12345678', '87654321', '11223344', '44332211'],
      isEnabled: false
    }
  }

  async verifyTwoFactorCode(secret: string, code: string): Promise<boolean> {
    // This would verify the TOTP code
    // For now, returning true for demo
    return true
  }

  async enableTwoFactor(userId: string, secret: string): Promise<void> {
    try {
      await updateDoc(doc(db, 'admin_users', userId), {
        twoFactorEnabled: true,
        twoFactorSecret: secret,
        updatedAt: new Date()
      })
    } catch (error) {
      console.error('Error enabling 2FA:', error)
      throw error
    }
  }
}

export const authService = new AuthService()
