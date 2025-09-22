import React, { createContext, useContext, useState, useEffect } from 'react'
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
    // Set loading to false immediately since we're using simple auth
    setLoading(false)
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
      // Simple logout - just clear the user state
      setUser(null)
    } catch (error) {
      console.error('Logout error:', error)
    }
  }

  const hasPermission = (resource: string, action: string): boolean => {
    // Simple permission check - allow all for now since we're using simple auth
    return true
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
