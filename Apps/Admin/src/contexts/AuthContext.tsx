import React, { createContext, useContext, useState, useEffect } from 'react'
import { AdminAuthService, AdminUser } from '../services/firebase'
import { User as FirebaseUser } from 'firebase/auth'

interface User {
  id: string
  name: string
  email: string
  role: string
  permissions?: string[]
}

interface AuthContextType {
  user: User | null
  isAuthenticated: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
  loading: boolean
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Listen to Firebase auth state changes
    const unsubscribe = AdminAuthService.onAuthStateChanged(async (firebaseUser: FirebaseUser | null) => {
      if (firebaseUser) {
        try {
          // Get admin profile from Firestore
          const adminUser = await AdminAuthService.login(firebaseUser.email!, '');
          setUser({
            id: adminUser.uid,
            name: adminUser.name,
            email: adminUser.email,
            role: adminUser.role,
            permissions: adminUser.permissions
          });
        } catch (error) {
          console.error('Error getting admin profile:', error);
          setUser(null);
        }
      } else {
        setUser(null);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, [])

  const login = async (email: string, password: string) => {
    try {
      setLoading(true);
      const adminUser = await AdminAuthService.login(email, password);
      
      const userData = {
        id: adminUser.uid,
        name: adminUser.name,
        email: adminUser.email,
        role: adminUser.role,
        permissions: adminUser.permissions
      };
      
      setUser(userData);
      localStorage.setItem('admin_user', JSON.stringify(userData));
    } catch (error: any) {
      console.error('Login error:', error);
      throw new Error(error.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  }

  const logout = async () => {
    try {
      await AdminAuthService.logout();
      setUser(null);
      localStorage.removeItem('admin_user');
    } catch (error) {
      console.error('Logout error:', error);
      // Clear local state even if Firebase logout fails
      setUser(null);
      localStorage.removeItem('admin_user');
    }
  }

  const value = {
    user,
    isAuthenticated: !!user,
    login,
    logout,
    loading
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
