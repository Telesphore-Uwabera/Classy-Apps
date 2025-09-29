import { collection, addDoc, updateDoc, deleteDoc, doc, getDocs, query, where, orderBy, limit } from 'firebase/firestore'
import { db } from '../config/firebase'

export interface Incident {
  id?: string
  type: 'accident' | 'fraud' | 'misconduct' | 'theft' | 'assault' | 'other'
  severity: 'low' | 'medium' | 'high' | 'critical'
  status: 'reported' | 'investigating' | 'resolved' | 'dismissed'
  title: string
  description: string
  reportedBy: string
  reportedByName: string
  reportedByRole: string
  reportedAt: Date
  assignedTo?: string
  assignedToName?: string
  assignedAt?: Date
  resolvedAt?: Date
  resolution?: string
  evidence: {
    images: string[]
    videos: string[]
    documents: string[]
    witnessStatements: string[]
  }
  location: {
    address: string
    coordinates: { lat: number; lng: number }
  }
  involvedParties: {
    userId: string
    name: string
    role: 'customer' | 'driver' | 'vendor' | 'admin'
    contactInfo: string
  }[]
  tripId?: string
  orderId?: string
  tags: string[]
  priority: 'low' | 'medium' | 'high' | 'urgent'
  createdAt: Date
  updatedAt: Date
}

export interface IncidentReport {
  id?: string
  incidentId: string
  reportedBy: string
  reportType: 'initial' | 'update' | 'resolution'
  content: string
  attachments: string[]
  createdAt: Date
}

export interface IncidentStatistics {
  totalIncidents: number
  incidentsByType: Record<string, number>
  incidentsBySeverity: Record<string, number>
  incidentsByStatus: Record<string, number>
  averageResolutionTime: number
  incidentsThisMonth: number
  incidentsLastMonth: number
  trendPercentage: number
}

class IncidentService {
  private incidentsCollection = 'incidents'
  private incidentReportsCollection = 'incident_reports'

  // Create new incident
  async createIncident(incident: Omit<Incident, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const docRef = await addDoc(collection(db, this.incidentsCollection), {
        ...incident,
        createdAt: new Date(),
        updatedAt: new Date()
      })
      return docRef.id
    } catch (error) {
      console.error('Error creating incident:', error)
      throw error
    }
  }

  // Get incident by ID
  async getIncident(incidentId: string): Promise<Incident | null> {
    try {
      const incidentDoc = await getDocs(query(
        collection(db, this.incidentsCollection),
        where('id', '==', incidentId)
      ))

      if (incidentDoc.empty) return null

      const doc = incidentDoc.docs[0]
      const data = doc.data()
      return {
        id: doc.id,
        ...data,
        reportedAt: data.reportedAt.toDate(),
        assignedAt: data.assignedAt?.toDate(),
        resolvedAt: data.resolvedAt?.toDate(),
        createdAt: data.createdAt.toDate(),
        updatedAt: data.updatedAt.toDate()
      } as Incident
    } catch (error) {
      console.error('Error getting incident:', error)
      return null
    }
  }

  // Get all incidents with filters
  async getIncidents(filters: {
    type?: string
    severity?: string
    status?: string
    assignedTo?: string
    priority?: string
    startDate?: Date
    endDate?: Date
    limitCount?: number
  } = {}): Promise<Incident[]> {
    try {
      let q = query(collection(db, this.incidentsCollection), orderBy('createdAt', 'desc'))

      if (filters.type) {
        q = query(q, where('type', '==', filters.type))
      }

      if (filters.severity) {
        q = query(q, where('severity', '==', filters.severity))
      }

      if (filters.status) {
        q = query(q, where('status', '==', filters.status))
      }

      if (filters.assignedTo) {
        q = query(q, where('assignedTo', '==', filters.assignedTo))
      }

      if (filters.priority) {
        q = query(q, where('priority', '==', filters.priority))
      }

      if (filters.startDate) {
        q = query(q, where('createdAt', '>=', filters.startDate))
      }

      if (filters.endDate) {
        q = query(q, where('createdAt', '<=', filters.endDate))
      }

      if (filters.limitCount) {
        q = query(q, limit(filters.limitCount))
      }

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        reportedAt: doc.data().reportedAt?.toDate(),
        assignedAt: doc.data().assignedAt?.toDate(),
        resolvedAt: doc.data().resolvedAt?.toDate(),
        createdAt: doc.data().createdAt?.toDate(),
        updatedAt: doc.data().updatedAt?.toDate()
      })) as Incident[]
    } catch (error) {
      console.error('Error getting incidents:', error)
      return []
    }
  }

  // Update incident
  async updateIncident(incidentId: string, updates: Partial<Incident>): Promise<void> {
    try {
      await updateDoc(doc(db, this.incidentsCollection, incidentId), {
        ...updates,
        updatedAt: new Date()
      })
    } catch (error) {
      console.error('Error updating incident:', error)
      throw error
    }
  }

  // Assign incident
  async assignIncident(incidentId: string, assignedTo: string, assignedToName: string): Promise<void> {
    try {
      await updateDoc(doc(db, this.incidentsCollection, incidentId), {
        assignedTo,
        assignedToName,
        assignedAt: new Date(),
        status: 'investigating',
        updatedAt: new Date()
      })
    } catch (error) {
      console.error('Error assigning incident:', error)
      throw error
    }
  }

  // Resolve incident
  async resolveIncident(incidentId: string, resolution: string, resolvedBy: string): Promise<void> {
    try {
      await updateDoc(doc(db, this.incidentsCollection, incidentId), {
        status: 'resolved',
        resolution,
        resolvedAt: new Date(),
        updatedAt: new Date()
      })

      // Create resolution report
      await this.addIncidentReport(incidentId, resolvedBy, 'resolution', resolution)
    } catch (error) {
      console.error('Error resolving incident:', error)
      throw error
    }
  }

  // Add incident report
  async addIncidentReport(
    incidentId: string,
    reportedBy: string,
    reportType: 'initial' | 'update' | 'resolution',
    content: string,
    attachments: string[] = []
  ): Promise<string> {
    try {
      const docRef = await addDoc(collection(db, this.incidentReportsCollection), {
        incidentId,
        reportedBy,
        reportType,
        content,
        attachments,
        createdAt: new Date()
      })
      return docRef.id
    } catch (error) {
      console.error('Error adding incident report:', error)
      throw error
    }
  }

  // Get incident reports
  async getIncidentReports(incidentId: string): Promise<IncidentReport[]> {
    try {
      const q = query(
        collection(db, this.incidentReportsCollection),
        where('incidentId', '==', incidentId),
        orderBy('createdAt', 'asc')
      )

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt.toDate()
      })) as IncidentReport[]
    } catch (error) {
      console.error('Error getting incident reports:', error)
      return []
    }
  }

  // Get incident statistics
  async getIncidentStatistics(): Promise<IncidentStatistics> {
    try {
      const now = new Date()
      const thisMonth = new Date(now.getFullYear(), now.getMonth(), 1)
      const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1)
      const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0)

      const [allIncidents, thisMonthIncidents, lastMonthIncidents] = await Promise.all([
        this.getIncidents(),
        this.getIncidents({ startDate: thisMonth }),
        this.getIncidents({ startDate: lastMonth, endDate: lastMonthEnd })
      ])

      const incidentsByType: Record<string, number> = {}
      const incidentsBySeverity: Record<string, number> = {}
      const incidentsByStatus: Record<string, number> = {}

      allIncidents.forEach(incident => {
        incidentsByType[incident.type] = (incidentsByType[incident.type] || 0) + 1
        incidentsBySeverity[incident.severity] = (incidentsBySeverity[incident.severity] || 0) + 1
        incidentsByStatus[incident.status] = (incidentsByStatus[incident.status] || 0) + 1
      })

      const resolvedIncidents = allIncidents.filter(i => i.status === 'resolved' && i.resolvedAt)
      const averageResolutionTime = resolvedIncidents.length > 0
        ? resolvedIncidents.reduce((sum, incident) => {
            const resolutionTime = incident.resolvedAt!.getTime() - incident.createdAt.getTime()
            return sum + resolutionTime
          }, 0) / resolvedIncidents.length / (1000 * 60 * 60 * 24) // Convert to days
        : 0

      const incidentsThisMonth = thisMonthIncidents.length
      const incidentsLastMonth = lastMonthIncidents.length
      const trendPercentage = incidentsLastMonth > 0
        ? ((incidentsThisMonth - incidentsLastMonth) / incidentsLastMonth) * 100
        : 0

      return {
        totalIncidents: allIncidents.length,
        incidentsByType,
        incidentsBySeverity,
        incidentsByStatus,
        averageResolutionTime,
        incidentsThisMonth,
        incidentsLastMonth,
        trendPercentage
      }
    } catch (error) {
      console.error('Error getting incident statistics:', error)
      return {
        totalIncidents: 0,
        incidentsByType: {},
        incidentsBySeverity: {},
        incidentsByStatus: {},
        averageResolutionTime: 0,
        incidentsThisMonth: 0,
        incidentsLastMonth: 0,
        trendPercentage: 0
      }
    }
  }

  // Delete incident
  async deleteIncident(incidentId: string): Promise<void> {
    try {
      await deleteDoc(doc(db, this.incidentsCollection, incidentId))
    } catch (error) {
      console.error('Error deleting incident:', error)
      throw error
    }
  }
}

export const incidentService = new IncidentService()
