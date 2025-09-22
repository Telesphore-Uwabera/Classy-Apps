import React, { createContext, useContext, useState, useEffect } from 'react'
import { authService } from '../services/authService'
import { simpleLogin } from '../utils/simpleAuth'
import { AdminUser } from '../types/auth'

interface AuthContextType {
  user: AdminUser | null
  isAuthenticated: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
  loading: boolean
  hasPermission: (resource: string, action: string) => boolean
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AdminUser | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsubscribe = authService.onAuthStateChange((adminUser) => {
      setUser(adminUser)
      setLoading(false)
    })

    return unsubscribe
  }, [])

  const login = async (email: string, password: string) => {
    try {
      // Try the simple login first (bypasses Firestore)
      const adminUser = await simpleLogin(email, password)
      setUser(adminUser)
    } catch (error) {
      console.error('Login error:', error)
      throw new Error('Invalid credentials')
    }
  }

  const logout = async () => {
    try {
      await authService.signOut()
    } catch (error) {
      console.error('Logout error:', error)
    }
  }

  const hasPermission = (resource: string, action: string): boolean => {
    return authService.hasPermission(resource, action)
  }

  const value = {
    user,
    isAuthenticated: !!user,
    login,
    logout,
    loading,
    hasPermission
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
