import { collection, addDoc, updateDoc, deleteDoc, doc, getDocs, query, where, orderBy, limit } from 'firebase/firestore'
import { db } from '../config/firebase'

export interface PaymentMethod {
  id?: string
  type: 'mobile_money' | 'bank_transfer' | 'wallet' | 'card'
  provider: 'mtn' | 'airtel' | 'equity' | 'stanbic' | 'absa' | 'dfcu' | 'classy_wallet'
  name: string
  accountNumber?: string
  phoneNumber?: string
  isActive: boolean
  commissionRate: number // Percentage
  processingFee: number // Fixed amount
  minAmount: number
  maxAmount: number
  createdAt: Date
  updatedAt: Date
}

export interface Payment {
  id?: string
  transactionId: string
  orderId: string
  customerId: string
  amount: number
  currency: string
  method: PaymentMethod['type']
  provider: PaymentMethod['provider']
  status: 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled' | 'refunded'
  reference: string
  externalReference?: string
  commission: number
  processingFee: number
  netAmount: number
  metadata: Record<string, any>
  processedAt?: Date
  failedAt?: Date
  failureReason?: string
  refundedAt?: Date
  refundAmount?: number
  refundReason?: string
  createdAt: Date
  updatedAt: Date
}

export interface PaymentStatistics {
  totalPayments: number
  totalAmount: number
  totalCommission: number
  totalProcessingFees: number
  netRevenue: number
  paymentsByMethod: Record<string, number>
  paymentsByStatus: Record<string, number>
  averageTransactionValue: number
  successRate: number
  refundRate: number
}

export interface RefundRequest {
  id?: string
  paymentId: string
  orderId: string
  customerId: string
  amount: number
  reason: string
  requestedBy: string
  status: 'pending' | 'approved' | 'rejected' | 'processed'
  approvedBy?: string
  approvedAt?: Date
  processedAt?: Date
  createdAt: Date
  updatedAt: Date
}

class PaymentService {
  private paymentsCollection = 'payments'
  private paymentMethodsCollection = 'payment_methods'
  private refundRequestsCollection = 'refund_requests'

  // Get all payment methods
  async getPaymentMethods(): Promise<PaymentMethod[]> {
    try {
      const q = query(
        collection(db, this.paymentMethodsCollection),
        where('isActive', '==', true),
        orderBy('createdAt', 'desc')
      )

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate()
      })) as PaymentMethod[]
    } catch (error) {
      console.error('Error getting payment methods:', error)
      return []
    }
  }

  // Create payment method
  async createPaymentMethod(method: Omit<PaymentMethod, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const docRef = await addDoc(collection(db, this.paymentMethodsCollection), {
        ...method,
        createdAt: new Date(),
        updatedAt: new Date()
      })
      return docRef.id
    } catch (error) {
      console.error('Error creating payment method:', error)
      throw error
    }
  }

  // Update payment method
  async updatePaymentMethod(methodId: string, updates: Partial<PaymentMethod>): Promise<void> {
    try {
      await updateDoc(doc(db, this.paymentMethodsCollection, methodId), {
        ...updates,
        updatedAt: new Date()
      })
    } catch (error) {
      console.error('Error updating payment method:', error)
      throw error
    }
  }

  // Process payment
  async processPayment(payment: Omit<Payment, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      // Get payment method details
      const paymentMethods = await this.getPaymentMethods()
      const method = paymentMethods.find(m => m.type === payment.method && m.provider === payment.provider)
      
      if (!method) {
        throw new Error('Payment method not found')
      }

      // Calculate commission and processing fee
      const commission = (payment.amount * method.commissionRate) / 100
      const processingFee = method.processingFee
      const netAmount = payment.amount - commission - processingFee

      const paymentData = {
        ...payment,
        commission,
        processingFee,
        netAmount,
        status: 'processing' as const,
        createdAt: new Date(),
        updatedAt: new Date()
      }

      const docRef = await addDoc(collection(db, this.paymentsCollection), paymentData)

      // Simulate payment processing
      setTimeout(async () => {
        await this.updatePaymentStatus(docRef.id, 'completed', { processedAt: new Date() })
      }, 2000)

      return docRef.id
    } catch (error) {
      console.error('Error processing payment:', error)
      throw error
    }
  }

  // Update payment status
  async updatePaymentStatus(
    paymentId: string, 
    status: Payment['status'], 
    additionalData: Record<string, any> = {}
  ): Promise<void> {
    try {
      const updateData: any = {
        status,
        updatedAt: new Date(),
        ...additionalData
      }

      if (status === 'failed') {
        updateData.failedAt = new Date()
      }

      await updateDoc(doc(db, this.paymentsCollection, paymentId), updateData)
    } catch (error) {
      console.error('Error updating payment status:', error)
      throw error
    }
  }

  // Get payments with filters
  async getPayments(filters: {
    status?: string
    method?: string
    provider?: string
    startDate?: Date
    endDate?: Date
    customerId?: string
    limitCount?: number
  } = {}): Promise<Payment[]> {
    try {
      let q = query(collection(db, this.paymentsCollection), orderBy('createdAt', 'desc'))

      if (filters.status) {
        q = query(q, where('status', '==', filters.status))
      }

      if (filters.method) {
        q = query(q, where('method', '==', filters.method))
      }

      if (filters.provider) {
        q = query(q, where('provider', '==', filters.provider))
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
        processedAt: doc.data().processedAt?.toDate(),
        failedAt: doc.data().failedAt?.toDate(),
        refundedAt: doc.data().refundedAt?.toDate(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate()
      })) as Payment[]
    } catch (error) {
      console.error('Error getting payments:', error)
      return []
    }
  }

  // Create refund request
  async createRefundRequest(request: Omit<RefundRequest, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const docRef = await addDoc(collection(db, this.refundRequestsCollection), {
        ...request,
        createdAt: new Date(),
        updatedAt: new Date()
      })
      return docRef.id
    } catch (error) {
      console.error('Error creating refund request:', error)
      throw error
    }
  }

  // Process refund
  async processRefund(
    refundRequestId: string, 
    approvedBy: string, 
    approved: boolean, 
    reason?: string
  ): Promise<void> {
    try {
      const updateData: any = {
        status: approved ? 'approved' : 'rejected',
        approvedBy,
        approvedAt: new Date(),
        updatedAt: new Date()
      }

      if (reason) {
        updateData.rejectionReason = reason
      }

      await updateDoc(doc(db, this.refundRequestsCollection, refundRequestId), updateData)

      if (approved) {
        // Update original payment status
        const refundRequest = await this.getRefundRequest(refundRequestId)
        if (refundRequest) {
          await this.updatePaymentStatus(refundRequest.paymentId, 'refunded', {
            refundedAt: new Date(),
            refundAmount: refundRequest.amount,
            refundReason: refundRequest.reason
          })
        }
      }
    } catch (error) {
      console.error('Error processing refund:', error)
      throw error
    }
  }

  // Get refund request
  async getRefundRequest(refundRequestId: string): Promise<RefundRequest | null> {
    try {
      const refundDoc = await getDocs(query(
        collection(db, this.refundRequestsCollection),
        where('id', '==', refundRequestId)
      ))

      if (refundDoc.empty) return null

      const doc = refundDoc.docs[0]
      const data = doc.data()
      return {
        id: doc.id,
        ...data,
        approvedAt: data.approvedAt?.toDate(),
        processedAt: data.processedAt?.toDate(),
        createdAt: data.createdAt.toDate(),
        updatedAt: data.updatedAt.toDate()
      } as RefundRequest
    } catch (error) {
      console.error('Error getting refund request:', error)
      return null
    }
  }

  // Get payment statistics
  async getPaymentStatistics(startDate?: Date, endDate?: Date): Promise<PaymentStatistics> {
    try {
      const payments = await this.getPayments({ startDate, endDate })

      const totalPayments = payments.length
      const totalAmount = payments.reduce((sum, payment) => sum + payment.amount, 0)
      const totalCommission = payments.reduce((sum, payment) => sum + payment.commission, 0)
      const totalProcessingFees = payments.reduce((sum, payment) => sum + payment.processingFee, 0)
      const netRevenue = totalAmount - totalCommission - totalProcessingFees

      const paymentsByMethod: Record<string, number> = {}
      const paymentsByStatus: Record<string, number> = {}

      payments.forEach(payment => {
        paymentsByMethod[payment.method] = (paymentsByMethod[payment.method] || 0) + 1
        paymentsByStatus[payment.status] = (paymentsByStatus[payment.status] || 0) + 1
      })

      const completedPayments = payments.filter(p => p.status === 'completed')
      const refundedPayments = payments.filter(p => p.status === 'refunded')

      const averageTransactionValue = completedPayments.length > 0 
        ? completedPayments.reduce((sum, payment) => sum + payment.amount, 0) / completedPayments.length 
        : 0

      const successRate = totalPayments > 0 ? (completedPayments.length / totalPayments) * 100 : 0
      const refundRate = totalPayments > 0 ? (refundedPayments.length / totalPayments) * 100 : 0

      return {
        totalPayments,
        totalAmount,
        totalCommission,
        totalProcessingFees,
        netRevenue,
        paymentsByMethod,
        paymentsByStatus,
        averageTransactionValue,
        successRate,
        refundRate
      }
    } catch (error) {
      console.error('Error getting payment statistics:', error)
      return {
        totalPayments: 0,
        totalAmount: 0,
        totalCommission: 0,
        totalProcessingFees: 0,
        netRevenue: 0,
        paymentsByMethod: {},
        paymentsByStatus: {},
        averageTransactionValue: 0,
        successRate: 0,
        refundRate: 0
      }
    }
  }

  // MTN Mobile Money integration
  async processMTNPayment(amount: number, phoneNumber: string, reference: string): Promise<any> {
    // This would integrate with MTN Mobile Money API
    // For now, returning mock response
    return {
      transactionId: `MTN_${Date.now()}`,
      status: 'pending',
      reference,
      amount,
      phoneNumber
    }
  }

  // Airtel Money integration
  async processAirtelPayment(amount: number, phoneNumber: string, reference: string): Promise<any> {
    // This would integrate with Airtel Money API
    // For now, returning mock response
    return {
      transactionId: `AIRTEL_${Date.now()}`,
      status: 'pending',
      reference,
      amount,
      phoneNumber
    }
  }

  // Bank transfer integration
  async processBankTransfer(amount: number, accountNumber: string, bankCode: string, reference: string): Promise<any> {
    // This would integrate with bank API
    // For now, returning mock response
    return {
      transactionId: `BANK_${Date.now()}`,
      status: 'pending',
      reference,
      amount,
      accountNumber,
      bankCode
    }
  }
}

export const paymentService = new PaymentService()
