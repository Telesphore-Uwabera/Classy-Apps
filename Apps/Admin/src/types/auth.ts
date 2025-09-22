export interface AdminUser {
  id: string
  email: string
  name: string
  role: AdminRole
  permissions: Permission[]
  isActive: boolean
  lastLogin?: Date
  twoFactorEnabled: boolean
  createdAt: Date
  updatedAt: Date
}

export type AdminRole = 'super_admin' | 'finance' | 'operations' | 'support' | 'marketing'

export interface Permission {
  resource: string
  actions: ('create' | 'read' | 'update' | 'delete')[]
}

export interface RolePermissions {
  [key: string]: Permission[]
}

export const ROLE_PERMISSIONS: RolePermissions = {
  super_admin: [
    { resource: 'users', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'drivers', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'vendors', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'restaurants', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'orders', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'payments', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'analytics', actions: ['read'] },
    { resource: 'settings', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'audit_logs', actions: ['read'] },
    { resource: 'incidents', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'helpdesk', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'compliance', actions: ['read'] }
  ],
  finance: [
    { resource: 'payments', actions: ['read', 'update'] },
    { resource: 'earnings', actions: ['read'] },
    { resource: 'payouts', actions: ['create', 'read', 'update'] },
    { resource: 'tax', actions: ['read', 'update'] },
    { resource: 'analytics', actions: ['read'] },
    { resource: 'compliance', actions: ['read'] }
  ],
  operations: [
    { resource: 'drivers', actions: ['read', 'update'] },
    { resource: 'orders', actions: ['read', 'update'] },
    { resource: 'incidents', actions: ['create', 'read', 'update'] },
    { resource: 'analytics', actions: ['read'] }
  ],
  support: [
    { resource: 'users', actions: ['read'] },
    { resource: 'orders', actions: ['read'] },
    { resource: 'helpdesk', actions: ['create', 'read', 'update'] },
    { resource: 'complaints', actions: ['create', 'read', 'update'] }
  ],
  marketing: [
    { resource: 'users', actions: ['read'] },
    { resource: 'coupons', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'notifications', actions: ['create', 'read', 'update'] },
    { resource: 'analytics', actions: ['read'] }
  ]
}

export interface TwoFactorAuth {
  secret: string
  qrCode: string
  backupCodes: string[]
  isEnabled: boolean
}
