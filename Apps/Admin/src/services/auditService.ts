import { collection, addDoc, query, orderBy, limit, getDocs, where, Timestamp } from 'firebase/firestore'
import { db } from '../config/firebase'

export interface AuditLog {
  id?: string
  userId: string
  userEmail: string
  userRole: string
  action: string
  resource: string
  resourceId?: string
  details: Record<string, any>
  ipAddress?: string
  userAgent?: string
  timestamp: Date
  success: boolean
  errorMessage?: string
}

class AuditService {
  private collectionName = 'audit_logs'

  async logAction(
    userId: string,
    userEmail: string,
    userRole: string,
    action: string,
    resource: string,
    details: Record<string, any> = {},
    resourceId?: string,
    success: boolean = true,
    errorMessage?: string
  ): Promise<void> {
    try {
      const auditLog: Omit<AuditLog, 'id'> = {
        userId,
        userEmail,
        userRole,
        action,
        resource,
        resourceId,
        details,
        ipAddress: this.getClientIP(),
        userAgent: navigator.userAgent,
        timestamp: new Date(),
        success,
        errorMessage
      }

      await addDoc(collection(db, this.collectionName), {
        ...auditLog,
        timestamp: Timestamp.fromDate(auditLog.timestamp)
      })
    } catch (error) {
      console.error('Error logging audit action:', error)
      // Don't throw error to avoid breaking the main flow
    }
  }

  async getAuditLogs(
    limitCount: number = 100,
    resource?: string,
    userId?: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<AuditLog[]> {
    try {
      let q = query(
        collection(db, this.collectionName),
        orderBy('timestamp', 'desc'),
        limit(limitCount)
      )

      if (resource) {
        q = query(q, where('resource', '==', resource))
      }

      if (userId) {
        q = query(q, where('userId', '==', userId))
      }

      if (startDate) {
        q = query(q, where('timestamp', '>=', Timestamp.fromDate(startDate)))
      }

      if (endDate) {
        q = query(q, where('timestamp', '<=', Timestamp.fromDate(endDate)))
      }

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        timestamp: doc.data().timestamp.toDate()
      })) as AuditLog[]
    } catch (error) {
      console.error('Error fetching audit logs:', error)
      return []
    }
  }

  async getAuditLogsByUser(userId: string, limitCount: number = 50): Promise<AuditLog[]> {
    return this.getAuditLogs(limitCount, undefined, userId)
  }

  async getAuditLogsByResource(resource: string, limitCount: number = 50): Promise<AuditLog[]> {
    return this.getAuditLogs(limitCount, resource)
  }

  async getFailedActions(limitCount: number = 50): Promise<AuditLog[]> {
    try {
      const q = query(
        collection(db, this.collectionName),
        where('success', '==', false),
        orderBy('timestamp', 'desc'),
        limit(limitCount)
      )

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        timestamp: doc.data().timestamp.toDate()
      })) as AuditLog[]
    } catch (error) {
      console.error('Error fetching failed actions:', error)
      return []
    }
  }

  private getClientIP(): string {
    // In a real application, you'd get this from the server
    // For now, return a placeholder
    return '127.0.0.1'
  }

  // Helper methods for common audit actions
  async logUserLogin(userId: string, userEmail: string, userRole: string, success: boolean, errorMessage?: string): Promise<void> {
    await this.logAction(
      userId,
      userEmail,
      userRole,
      'login',
      'auth',
      { loginMethod: 'email_password' },
      undefined,
      success,
      errorMessage
    )
  }

  async logUserLogout(userId: string, userEmail: string, userRole: string): Promise<void> {
    await this.logAction(
      userId,
      userEmail,
      userRole,
      'logout',
      'auth',
      { logoutMethod: 'manual' }
    )
  }

  async logDataAccess(userId: string, userEmail: string, userRole: string, resource: string, resourceId: string, action: string): Promise<void> {
    await this.logAction(
      userId,
      userEmail,
      userRole,
      action,
      resource,
      { resourceId },
      resourceId
    )
  }

  async logDataModification(
    userId: string,
    userEmail: string,
    userRole: string,
    resource: string,
    resourceId: string,
    action: string,
    oldData: Record<string, any>,
    newData: Record<string, any>
  ): Promise<void> {
    await this.logAction(
      userId,
      userEmail,
      userRole,
      action,
      resource,
      { 
        resourceId,
        changes: this.getChanges(oldData, newData),
        oldData,
        newData
      },
      resourceId
    )
  }

  private getChanges(oldData: Record<string, any>, newData: Record<string, any>): Record<string, { from: any, to: any }> {
    const changes: Record<string, { from: any, to: any }> = {}
    
    for (const key in newData) {
      if (oldData[key] !== newData[key]) {
        changes[key] = {
          from: oldData[key],
          to: newData[key]
        }
      }
    }
    
    return changes
  }
}

export const auditService = new AuditService()
