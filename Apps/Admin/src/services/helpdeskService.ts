import { collection, addDoc, updateDoc, deleteDoc, doc, getDocs, query, where, orderBy, limit, onSnapshot } from 'firebase/firestore'
import { db } from '../config/firebase'

export interface Ticket {
  id?: string
  ticketNumber: string
  title: string
  description: string
  category: 'technical' | 'billing' | 'general' | 'complaint' | 'feature_request' | 'bug_report'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  status: 'open' | 'in_progress' | 'pending_customer' | 'resolved' | 'closed'
  customerId: string
  customerName: string
  customerEmail: string
  customerPhone: string
  assignedTo?: string
  assignedToName?: string
  assignedAt?: Date
  createdBy: string
  createdAt: Date
  updatedAt: Date
  resolvedAt?: Date
  closedAt?: Date
  resolution?: string
  tags: string[]
  attachments: string[]
  estimatedResolutionTime?: Date
  actualResolutionTime?: number // in minutes
}

export interface Message {
  id?: string
  ticketId: string
  senderId: string
  senderName: string
  senderType: 'customer' | 'admin' | 'system'
  content: string
  messageType: 'text' | 'image' | 'file' | 'system'
  attachments: string[]
  isRead: boolean
  readAt?: Date
  createdAt: Date
}

export interface SupportAgent {
  id: string
  name: string
  email: string
  role: 'agent' | 'supervisor' | 'manager'
  isActive: boolean
  currentTickets: number
  maxTickets: number
  averageResolutionTime: number
  customerRating: number
  totalTicketsResolved: number
  specializations: string[]
  workingHours: {
    start: string
    end: string
    days: string[]
  }
}

export interface HelpdeskStatistics {
  totalTickets: number
  openTickets: number
  resolvedTickets: number
  averageResolutionTime: number
  customerSatisfaction: number
  ticketsByCategory: Record<string, number>
  ticketsByPriority: Record<string, number>
  ticketsByStatus: Record<string, number>
  agentPerformance: {
    agentId: string
    name: string
    ticketsResolved: number
    averageResolutionTime: number
    customerRating: number
  }[]
}

class HelpdeskService {
  private ticketsCollection = 'helpdesk_tickets'
  private messagesCollection = 'helpdesk_messages'
  private agentsCollection = 'support_agents'

  // Create new ticket
  async createTicket(ticket: Omit<Ticket, 'id' | 'ticketNumber' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const ticketNumber = await this.generateTicketNumber()
      
      const docRef = await addDoc(collection(db, this.ticketsCollection), {
        ...ticket,
        ticketNumber,
        createdAt: new Date(),
        updatedAt: new Date()
      })

      // Auto-assign ticket if possible
      await this.autoAssignTicket(docRef.id)

      return docRef.id
    } catch (error) {
      console.error('Error creating ticket:', error)
      throw error
    }
  }

  // Get ticket by ID
  async getTicket(ticketId: string): Promise<Ticket | null> {
    try {
      const ticketDoc = await getDocs(query(
        collection(db, this.ticketsCollection),
        where('id', '==', ticketId)
      ))

      if (ticketDoc.empty) return null

      const doc = ticketDoc.docs[0]
      const data = doc.data()
      return {
        id: doc.id,
        ...data,
        assignedAt: data.assignedAt?.toDate(),
        createdAt: data.createdAt.toDate(),
        updatedAt: data.updatedAt.toDate(),
        resolvedAt: data.resolvedAt?.toDate(),
        closedAt: data.closedAt?.toDate(),
        estimatedResolutionTime: data.estimatedResolutionTime?.toDate()
      } as Ticket
    } catch (error) {
      console.error('Error getting ticket:', error)
      return null
    }
  }

  // Get tickets with filters
  async getTickets(filters: {
    status?: string
    priority?: string
    category?: string
    assignedTo?: string
    customerId?: string
    startDate?: Date
    endDate?: Date
    limitCount?: number
  } = {}): Promise<Ticket[]> {
    try {
      let q = query(collection(db, this.ticketsCollection), orderBy('createdAt', 'desc'))

      if (filters.status) {
        q = query(q, where('status', '==', filters.status))
      }

      if (filters.priority) {
        q = query(q, where('priority', '==', filters.priority))
      }

      if (filters.category) {
        q = query(q, where('category', '==', filters.category))
      }

      if (filters.assignedTo) {
        q = query(q, where('assignedTo', '==', filters.assignedTo))
      }

      if (filters.customerId) {
        q = query(q, where('customerId', '==', filters.customerId))
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
        assignedAt: doc.data().assignedAt?.toDate(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate(),
        resolvedAt: doc.data().resolvedAt?.toDate(),
        closedAt: doc.data().closedAt?.toDate(),
        estimatedResolutionTime: doc.data().estimatedResolutionTime?.toDate()
      })) as Ticket[]
    } catch (error) {
      console.error('Error getting tickets:', error)
      return []
    }
  }

  // Update ticket
  async updateTicket(ticketId: string, updates: Partial<Ticket>): Promise<void> {
    try {
      await updateDoc(doc(db, this.ticketsCollection, ticketId), {
        ...updates,
        updatedAt: new Date()
      })
    } catch (error) {
      console.error('Error updating ticket:', error)
      throw error
    }
  }

  // Assign ticket
  async assignTicket(ticketId: string, assignedTo: string, assignedToName: string): Promise<void> {
    try {
      await updateDoc(doc(db, this.ticketsCollection, ticketId), {
        assignedTo,
        assignedToName,
        assignedAt: new Date(),
        status: 'in_progress',
        updatedAt: new Date()
      })

      // Update agent's current ticket count
      await this.updateAgentTicketCount(assignedTo, 1)
    } catch (error) {
      console.error('Error assigning ticket:', error)
      throw error
    }
  }

  // Resolve ticket
  async resolveTicket(ticketId: string, resolution: string, resolvedBy: string): Promise<void> {
    try {
      const ticket = await this.getTicket(ticketId)
      if (!ticket) throw new Error('Ticket not found')

      const resolvedAt = new Date()
      const actualResolutionTime = ticket.assignedAt 
        ? Math.round((resolvedAt.getTime() - ticket.assignedAt.getTime()) / (1000 * 60))
        : undefined

      await updateDoc(doc(db, this.ticketsCollection, ticketId), {
        status: 'resolved',
        resolution,
        resolvedAt,
        actualResolutionTime,
        updatedAt: new Date()
      })

      // Update agent's ticket count and performance
      if (ticket.assignedTo) {
        await this.updateAgentTicketCount(ticket.assignedTo, -1)
        await this.updateAgentPerformance(ticket.assignedTo, actualResolutionTime)
      }
    } catch (error) {
      console.error('Error resolving ticket:', error)
      throw error
    }
  }

  // Close ticket
  async closeTicket(ticketId: string, closedBy: string): Promise<void> {
    try {
      await updateDoc(doc(db, this.ticketsCollection, ticketId), {
        status: 'closed',
        closedAt: new Date(),
        updatedAt: new Date()
      })
    } catch (error) {
      console.error('Error closing ticket:', error)
      throw error
    }
  }

  // Add message to ticket
  async addMessage(message: Omit<Message, 'id' | 'createdAt'>): Promise<string> {
    try {
      const docRef = await addDoc(collection(db, this.messagesCollection), {
        ...message,
        createdAt: new Date()
      })

      // Update ticket's updatedAt timestamp
      await updateDoc(doc(db, this.ticketsCollection, message.ticketId), {
        updatedAt: new Date()
      })

      return docRef.id
    } catch (error) {
      console.error('Error adding message:', error)
      throw error
    }
  }

  // Get messages for ticket
  async getTicketMessages(ticketId: string): Promise<Message[]> {
    try {
      const q = query(
        collection(db, this.messagesCollection),
        where('ticketId', '==', ticketId),
        orderBy('createdAt', 'asc')
      )

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        readAt: doc.data().readAt?.toDate(),
        createdAt: doc.data().createdAt.toDate()
      })) as Message[]
    } catch (error) {
      console.error('Error getting ticket messages:', error)
      return []
    }
  }

  // Mark message as read
  async markMessageAsRead(messageId: string): Promise<void> {
    try {
      await updateDoc(doc(db, this.messagesCollection, messageId), {
        isRead: true,
        readAt: new Date()
      })
    } catch (error) {
      console.error('Error marking message as read:', error)
      throw error
    }
  }

  // Subscribe to ticket updates
  subscribeToTickets(callback: (tickets: Ticket[]) => void): () => void {
    const q = query(
      collection(db, this.ticketsCollection),
      orderBy('updatedAt', 'desc')
    )

    return onSnapshot(q, (snapshot) => {
      const tickets = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        assignedAt: doc.data().assignedAt?.toDate(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate(),
        resolvedAt: doc.data().resolvedAt?.toDate(),
        closedAt: doc.data().closedAt?.toDate(),
        estimatedResolutionTime: doc.data().estimatedResolutionTime?.toDate()
      })) as Ticket[]
      callback(tickets)
    })
  }

  // Subscribe to ticket messages
  subscribeToTicketMessages(ticketId: string, callback: (messages: Message[]) => void): () => void {
    const q = query(
      collection(db, this.messagesCollection),
      where('ticketId', '==', ticketId),
      orderBy('createdAt', 'asc')
    )

    return onSnapshot(q, (snapshot) => {
      const messages = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        readAt: doc.data().readAt?.toDate(),
        createdAt: doc.data().createdAt.toDate()
      })) as Message[]
      callback(messages)
    })
  }

  // Get support agents
  async getSupportAgents(): Promise<SupportAgent[]> {
    try {
      const q = query(
        collection(db, this.agentsCollection),
        where('isActive', '==', true),
        orderBy('name', 'asc')
      )

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as SupportAgent[]
    } catch (error) {
      console.error('Error getting support agents:', error)
      return []
    }
  }

  // Get helpdesk statistics
  async getHelpdeskStatistics(): Promise<HelpdeskStatistics> {
    try {
      const tickets = await this.getTickets()
      const agents = await this.getSupportAgents()

      const totalTickets = tickets.length
      const openTickets = tickets.filter(t => ['open', 'in_progress', 'pending_customer'].includes(t.status)).length
      const resolvedTickets = tickets.filter(t => t.status === 'resolved').length

      const resolvedTicketsWithTime = tickets.filter(t => t.actualResolutionTime)
      const averageResolutionTime = resolvedTicketsWithTime.length > 0
        ? resolvedTicketsWithTime.reduce((sum, t) => sum + (t.actualResolutionTime || 0), 0) / resolvedTicketsWithTime.length
        : 0

      const ticketsByCategory = this.groupByField(tickets, 'category')
      const ticketsByPriority = this.groupByField(tickets, 'priority')
      const ticketsByStatus = this.groupByField(tickets, 'status')

      const agentPerformance = agents.map(agent => ({
        agentId: agent.id,
        name: agent.name,
        ticketsResolved: agent.totalTicketsResolved,
        averageResolutionTime: agent.averageResolutionTime,
        customerRating: agent.customerRating
      }))

      return {
        totalTickets,
        openTickets,
        resolvedTickets,
        averageResolutionTime,
        customerSatisfaction: 4.2, // This would be calculated from customer ratings
        ticketsByCategory,
        ticketsByPriority,
        ticketsByStatus,
        agentPerformance
      }
    } catch (error) {
      console.error('Error getting helpdesk statistics:', error)
      return {
        totalTickets: 0,
        openTickets: 0,
        resolvedTickets: 0,
        averageResolutionTime: 0,
        customerSatisfaction: 0,
        ticketsByCategory: {},
        ticketsByPriority: {},
        ticketsByStatus: {},
        agentPerformance: []
      }
    }
  }

  // Helper methods
  private async generateTicketNumber(): Promise<string> {
    const year = new Date().getFullYear()
    const month = String(new Date().getMonth() + 1).padStart(2, '0')
    const day = String(new Date().getDate()).padStart(2, '0')
    
    // Get count of tickets created today
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const tomorrow = new Date(today)
    tomorrow.setDate(tomorrow.getDate() + 1)
    
    const q = query(
      collection(db, this.ticketsCollection),
      where('createdAt', '>=', today),
      where('createdAt', '<', tomorrow)
    )
    
    const snapshot = await getDocs(q)
    const count = snapshot.size + 1
    
    return `TKT-${year}${month}${day}-${String(count).padStart(4, '0')}`
  }

  private async autoAssignTicket(ticketId: string): Promise<void> {
    try {
      const agents = await this.getSupportAgents()
      const availableAgent = agents.find(agent => agent.currentTickets < agent.maxTickets)
      
      if (availableAgent) {
        await this.assignTicket(ticketId, availableAgent.id, availableAgent.name)
      }
    } catch (error) {
      console.error('Error auto-assigning ticket:', error)
    }
  }

  private async updateAgentTicketCount(agentId: string, change: number): Promise<void> {
    try {
      const agentDoc = doc(db, this.agentsCollection, agentId)
      await updateDoc(agentDoc, {
        currentTickets: Math.max(0, (await this.getAgentCurrentTickets(agentId)) + change)
      })
    } catch (error) {
      console.error('Error updating agent ticket count:', error)
    }
  }

  private async getAgentCurrentTickets(agentId: string): Promise<number> {
    try {
      const q = query(
        collection(db, this.ticketsCollection),
        where('assignedTo', '==', agentId),
        where('status', 'in', ['in_progress', 'pending_customer'])
      )
      const snapshot = await getDocs(q)
      return snapshot.size
    } catch (error) {
      console.error('Error getting agent current tickets:', error)
      return 0
    }
  }

  private async updateAgentPerformance(agentId: string, resolutionTime?: number): Promise<void> {
    try {
      if (!resolutionTime) return

      const agent = await this.getSupportAgent(agentId)
      if (!agent) return

      const newTotalResolved = agent.totalTicketsResolved + 1
      const newAverageTime = ((agent.averageResolutionTime * agent.totalTicketsResolved) + resolutionTime) / newTotalResolved

      await updateDoc(doc(db, this.agentsCollection, agentId), {
        totalTicketsResolved: newTotalResolved,
        averageResolutionTime: newAverageTime
      })
    } catch (error) {
      console.error('Error updating agent performance:', error)
    }
  }

  private async getSupportAgent(agentId: string): Promise<SupportAgent | null> {
    try {
      const agentDoc = await getDocs(query(
        collection(db, this.agentsCollection),
        where('id', '==', agentId)
      ))

      if (agentDoc.empty) return null

      const doc = agentDoc.docs[0]
      return { id: doc.id, ...doc.data() } as SupportAgent
    } catch (error) {
      console.error('Error getting support agent:', error)
      return null
    }
  }

  private groupByField(data: any[], field: string): Record<string, number> {
    return data.reduce((acc, item) => {
      const value = item[field] || 'unknown'
      acc[value] = (acc[value] || 0) + 1
      return acc
    }, {})
  }

  // Get helpdesk statistics
  async getStatistics(): Promise<any> {
    try {
      const allTickets = await this.getTickets()
      
      const totalTickets = allTickets.length
      const openTickets = allTickets.filter(t => t.status === 'open').length
      const inProgressTickets = allTickets.filter(t => t.status === 'in_progress').length
      const resolvedTickets = allTickets.filter(t => t.status === 'resolved').length
      const closedTickets = allTickets.filter(t => t.status === 'closed').length
      
      const ticketsByCategory = this.groupByField(allTickets, 'category')
      const ticketsByPriority = this.groupByField(allTickets, 'priority')
      const ticketsByStatus = this.groupByField(allTickets, 'status')
      
      // Calculate average response time
      const ticketsWithResponseTime = allTickets.filter(t => t.assignedAt && t.createdAt)
      const averageResponseTime = ticketsWithResponseTime.length > 0
        ? ticketsWithResponseTime.reduce((sum, ticket) => {
            const responseTime = ticket.assignedAt!.getTime() - ticket.createdAt.getTime()
            return sum + (responseTime / (1000 * 60 * 60)) // Convert to hours
          }, 0) / ticketsWithResponseTime.length
        : 0
      
      // Calculate average resolution time
      const resolvedTicketsWithTime = allTickets.filter(t => t.status === 'resolved' && t.resolvedAt && t.createdAt)
      const averageResolutionTime = resolvedTicketsWithTime.length > 0
        ? resolvedTicketsWithTime.reduce((sum, ticket) => {
            const resolutionTime = ticket.resolvedAt!.getTime() - ticket.createdAt.getTime()
            return sum + (resolutionTime / (1000 * 60 * 60)) // Convert to hours
          }, 0) / resolvedTicketsWithTime.length
        : 0
      
      return {
        totalTickets,
        openTickets,
        inProgressTickets,
        resolvedTickets,
        closedTickets,
        averageResponseTime: Math.round(averageResponseTime * 10) / 10,
        averageResolutionTime: Math.round(averageResolutionTime * 10) / 10,
        customerSatisfaction: 4.2, // This would come from ratings collection
        ticketsByCategory,
        ticketsByPriority,
        ticketsByStatus
      }
    } catch (error) {
      console.error('Error getting helpdesk statistics:', error)
      return {
        totalTickets: 0,
        openTickets: 0,
        inProgressTickets: 0,
        resolvedTickets: 0,
        closedTickets: 0,
        averageResponseTime: 0,
        averageResolutionTime: 0,
        customerSatisfaction: 0,
        ticketsByCategory: {},
        ticketsByPriority: {},
        ticketsByStatus: {}
      }
    }
  }
}

export const helpdeskService = new HelpdeskService()
