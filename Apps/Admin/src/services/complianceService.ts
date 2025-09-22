import { collection, addDoc, updateDoc, deleteDoc, doc, getDocs, query, where, orderBy, limit } from 'firebase/firestore'
import { db } from '../config/firebase'

export interface ComplianceReport {
  id?: string
  reportType: 'ucc' | 'transport_authority' | 'ura_tax' | 'data_protection' | 'custom'
  title: string
  description: string
  period: {
    startDate: Date
    endDate: Date
  }
  status: 'draft' | 'pending_approval' | 'approved' | 'submitted' | 'rejected'
  data: Record<string, any>
  generatedBy: string
  generatedByName: string
  approvedBy?: string
  approvedByName?: string
  approvedAt?: Date
  submittedAt?: Date
  rejectionReason?: string
  createdAt: Date
  updatedAt: Date
}

export interface UCCReport {
  totalUsers: number
  activeUsers: number
  newRegistrations: number
  dataUsage: {
    totalDataProcessed: number
    dataRetentionPeriod: number
    dataSharing: boolean
  }
  privacyCompliance: {
    consentCollected: number
    consentWithdrawn: number
    dataSubjectRequests: number
  }
  securityMeasures: {
    encryptionEnabled: boolean
    accessControls: string[]
    auditLogs: number
  }
}

export interface TransportAuthorityReport {
  totalTrips: number
  completedTrips: number
  cancelledTrips: number
  driverCompliance: {
    licensedDrivers: number
    unlicensedDrivers: number
    expiredLicenses: number
  }
  vehicleCompliance: {
    registeredVehicles: number
    unregisteredVehicles: number
    expiredRegistrations: number
  }
  safetyIncidents: {
    accidents: number
    injuries: number
    fatalities: number
  }
  revenue: {
    totalFare: number
    taxesCollected: number
    commission: number
  }
}

export interface URATaxReport {
  totalRevenue: number
  taxableRevenue: number
  taxRate: number
  taxAmount: number
  deductions: {
    operatingExpenses: number
    depreciation: number
    other: number
  }
  netTaxableIncome: number
  vatCollected: number
  withholdingTax: number
  totalTaxLiability: number
  payments: {
    advancePayments: number
    finalPayment: number
    totalPaid: number
  }
  period: {
    startDate: Date
    endDate: Date
  }
}

export interface DataProtectionReport {
  dataInventory: {
    personalDataTypes: string[]
    dataSources: string[]
    dataRecipients: string[]
  }
  consentManagement: {
    consentCollected: number
    consentWithdrawn: number
    consentPending: number
  }
  dataSubjectRights: {
    accessRequests: number
    rectificationRequests: number
    erasureRequests: number
    portabilityRequests: number
  }
  securityIncidents: {
    dataBreaches: number
    unauthorizedAccess: number
    dataLoss: number
  }
  complianceStatus: {
    gdprCompliant: boolean
    dataProtectionOfficer: string
    lastAudit: Date
  }
}

class ComplianceService {
  private reportsCollection = 'compliance_reports'

  // Generate UCC compliance report
  async generateUCCReport(period: { startDate: Date; endDate: Date }, generatedBy: string, generatedByName: string): Promise<string> {
    try {
      const data = await this.getUCCReportData(period)
      
      const report: Omit<ComplianceReport, 'id' | 'createdAt' | 'updatedAt'> = {
        reportType: 'ucc',
        title: `UCC Compliance Report - ${period.startDate.toISOString().split('T')[0]} to ${period.endDate.toISOString().split('T')[0]}`,
        description: 'Uganda Communications Commission compliance report covering user data, privacy, and security measures',
        period,
        status: 'draft',
        data,
        generatedBy,
        generatedByName
      }

      const docRef = await addDoc(collection(db, this.reportsCollection), {
        ...report,
        createdAt: new Date(),
        updatedAt: new Date()
      })

      return docRef.id
    } catch (error) {
      console.error('Error generating UCC report:', error)
      throw error
    }
  }

  // Generate Transport Authority report
  async generateTransportAuthorityReport(period: { startDate: Date; endDate: Date }, generatedBy: string, generatedByName: string): Promise<string> {
    try {
      const data = await this.getTransportAuthorityReportData(period)
      
      const report: Omit<ComplianceReport, 'id' | 'createdAt' | 'updatedAt'> = {
        reportType: 'transport_authority',
        title: `Transport Authority Report - ${period.startDate.toISOString().split('T')[0]} to ${period.endDate.toISOString().split('T')[0]}`,
        description: 'Transport Authority compliance report covering trips, drivers, vehicles, and safety',
        period,
        status: 'draft',
        data,
        generatedBy,
        generatedByName
      }

      const docRef = await addDoc(collection(db, this.reportsCollection), {
        ...report,
        createdAt: new Date(),
        updatedAt: new Date()
      })

      return docRef.id
    } catch (error) {
      console.error('Error generating Transport Authority report:', error)
      throw error
    }
  }

  // Generate URA Tax report
  async generateURATaxReport(period: { startDate: Date; endDate: Date }, generatedBy: string, generatedByName: string): Promise<string> {
    try {
      const data = await this.getURATaxReportData(period)
      
      const report: Omit<ComplianceReport, 'id' | 'createdAt' | 'updatedAt'> = {
        reportType: 'ura_tax',
        title: `URA Tax Report - ${period.startDate.toISOString().split('T')[0]} to ${period.endDate.toISOString().split('T')[0]}`,
        description: 'Uganda Revenue Authority tax compliance report covering revenue, taxes, and deductions',
        period,
        status: 'draft',
        data,
        generatedBy,
        generatedByName
      }

      const docRef = await addDoc(collection(db, this.reportsCollection), {
        ...report,
        createdAt: new Date(),
        updatedAt: new Date()
      })

      return docRef.id
    } catch (error) {
      console.error('Error generating URA Tax report:', error)
      throw error
    }
  }

  // Generate Data Protection report
  async generateDataProtectionReport(period: { startDate: Date; endDate: Date }, generatedBy: string, generatedByName: string): Promise<string> {
    try {
      const data = await this.getDataProtectionReportData(period)
      
      const report: Omit<ComplianceReport, 'id' | 'createdAt' | 'updatedAt'> = {
        reportType: 'data_protection',
        title: `Data Protection Report - ${period.startDate.toISOString().split('T')[0]} to ${period.endDate.toISOString().split('T')[0]}`,
        description: 'Data Protection compliance report covering GDPR and Uganda Data Protection Act compliance',
        period,
        status: 'draft',
        data,
        generatedBy,
        generatedByName
      }

      const docRef = await addDoc(collection(db, this.reportsCollection), {
        ...report,
        createdAt: new Date(),
        updatedAt: new Date()
      })

      return docRef.id
    } catch (error) {
      console.error('Error generating Data Protection report:', error)
      throw error
    }
  }

  // Get all compliance reports
  async getComplianceReports(filters: {
    reportType?: string
    status?: string
    generatedBy?: string
    startDate?: Date
    endDate?: Date
    limitCount?: number
  } = {}): Promise<ComplianceReport[]> {
    try {
      let q = query(collection(db, this.reportsCollection), orderBy('createdAt', 'desc'))

      if (filters.reportType) {
        q = query(q, where('reportType', '==', filters.reportType))
      }

      if (filters.status) {
        q = query(q, where('status', '==', filters.status))
      }

      if (filters.generatedBy) {
        q = query(q, where('generatedBy', '==', filters.generatedBy))
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
        period: {
          startDate: doc.data().period.startDate.toDate(),
          endDate: doc.data().period.endDate.toDate()
        },
        approvedAt: doc.data().approvedAt?.toDate(),
        submittedAt: doc.data().submittedAt?.toDate(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate()
      })) as ComplianceReport[]
    } catch (error) {
      console.error('Error getting compliance reports:', error)
      return []
    }
  }

  // Update report status
  async updateReportStatus(reportId: string, status: ComplianceReport['status'], updatedBy: string, additionalData: Record<string, any> = {}): Promise<void> {
    try {
      const updateData: any = {
        status,
        updatedAt: new Date(),
        ...additionalData
      }

      if (status === 'approved') {
        updateData.approvedBy = updatedBy
        updateData.approvedAt = new Date()
      }

      if (status === 'submitted') {
        updateData.submittedAt = new Date()
      }

      await updateDoc(doc(db, this.reportsCollection, reportId), updateData)
    } catch (error) {
      console.error('Error updating report status:', error)
      throw error
    }
  }

  // Get UCC report data
  private async getUCCReportData(period: { startDate: Date; endDate: Date }): Promise<UCCReport> {
    try {
      // Get user data
      const users = await this.getCollectionData('users', period.startDate, period.endDate)
      const activeUsers = users.filter(user => user.lastActiveAt && new Date(user.lastActiveAt) >= period.startDate)
      const newRegistrations = users.filter(user => new Date(user.createdAt) >= period.startDate)

      // Get consent data
      const consentData = await this.getConsentData(period)

      // Get security data
      const securityData = await this.getSecurityData(period)

      return {
        totalUsers: users.length,
        activeUsers: activeUsers.length,
        newRegistrations: newRegistrations.length,
        dataUsage: {
          totalDataProcessed: this.calculateDataProcessed(users),
          dataRetentionPeriod: 7 * 365, // 7 years in days
          dataSharing: false
        },
        privacyCompliance: {
          consentCollected: consentData.collected,
          consentWithdrawn: consentData.withdrawn,
          dataSubjectRequests: consentData.requests
        },
        securityMeasures: {
          encryptionEnabled: true,
          accessControls: ['role-based', 'two-factor', 'audit-logging'],
          auditLogs: securityData.auditLogs
        }
      }
    } catch (error) {
      console.error('Error getting UCC report data:', error)
      return {
        totalUsers: 0,
        activeUsers: 0,
        newRegistrations: 0,
        dataUsage: {
          totalDataProcessed: 0,
          dataRetentionPeriod: 0,
          dataSharing: false
        },
        privacyCompliance: {
          consentCollected: 0,
          consentWithdrawn: 0,
          dataSubjectRequests: 0
        },
        securityMeasures: {
          encryptionEnabled: false,
          accessControls: [],
          auditLogs: 0
        }
      }
    }
  }

  // Get Transport Authority report data
  private async getTransportAuthorityReportData(period: { startDate: Date; endDate: Date }): Promise<TransportAuthorityReport> {
    try {
      const trips = await this.getCollectionData('trips', period.startDate, period.endDate)
      const drivers = await this.getCollectionData('drivers', period.startDate, period.endDate)
      const vehicles = await this.getCollectionData('vehicles', period.startDate, period.endDate)
      const incidents = await this.getCollectionData('incidents', period.startDate, period.endDate)

      const completedTrips = trips.filter(trip => trip.status === 'completed')
      const cancelledTrips = trips.filter(trip => trip.status === 'cancelled')
      const totalFare = completedTrips.reduce((sum, trip) => sum + (trip.fare || 0), 0)

      const licensedDrivers = drivers.filter(driver => driver.licenseValid && new Date(driver.licenseExpiry) > new Date())
      const unlicensedDrivers = drivers.filter(driver => !driver.licenseValid)
      const expiredLicenses = drivers.filter(driver => driver.licenseValid && new Date(driver.licenseExpiry) <= new Date())

      const registeredVehicles = vehicles.filter(vehicle => vehicle.registrationValid && new Date(vehicle.registrationExpiry) > new Date())
      const unregisteredVehicles = vehicles.filter(vehicle => !vehicle.registrationValid)
      const expiredRegistrations = vehicles.filter(vehicle => vehicle.registrationValid && new Date(vehicle.registrationExpiry) <= new Date())

      const accidents = incidents.filter(incident => incident.type === 'accident')
      const injuries = incidents.filter(incident => incident.severity === 'high' || incident.severity === 'critical')
      const fatalities = incidents.filter(incident => incident.severity === 'critical')

      return {
        totalTrips: trips.length,
        completedTrips: completedTrips.length,
        cancelledTrips: cancelledTrips.length,
        driverCompliance: {
          licensedDrivers: licensedDrivers.length,
          unlicensedDrivers: unlicensedDrivers.length,
          expiredLicenses: expiredLicenses.length
        },
        vehicleCompliance: {
          registeredVehicles: registeredVehicles.length,
          unregisteredVehicles: unregisteredVehicles.length,
          expiredRegistrations: expiredRegistrations.length
        },
        safetyIncidents: {
          accidents: accidents.length,
          injuries: injuries.length,
          fatalities: fatalities.length
        },
        revenue: {
          totalFare,
          taxesCollected: totalFare * 0.18, // 18% VAT
          commission: totalFare * 0.15 // 15% commission
        }
      }
    } catch (error) {
      console.error('Error getting Transport Authority report data:', error)
      return {
        totalTrips: 0,
        completedTrips: 0,
        cancelledTrips: 0,
        driverCompliance: {
          licensedDrivers: 0,
          unlicensedDrivers: 0,
          expiredLicenses: 0
        },
        vehicleCompliance: {
          registeredVehicles: 0,
          unregisteredVehicles: 0,
          expiredRegistrations: 0
        },
        safetyIncidents: {
          accidents: 0,
          injuries: 0,
          fatalities: 0
        },
        revenue: {
          totalFare: 0,
          taxesCollected: 0,
          commission: 0
        }
      }
    }
  }

  // Get URA Tax report data
  private async getURATaxReportData(period: { startDate: Date; endDate: Date }): Promise<URATaxReport> {
    try {
      const payments = await this.getCollectionData('payments', period.startDate, period.endDate)
      const completedPayments = payments.filter(payment => payment.status === 'completed')
      
      const totalRevenue = completedPayments.reduce((sum, payment) => sum + payment.amount, 0)
      const taxableRevenue = totalRevenue * 0.85 // 85% of revenue is taxable
      const taxRate = 0.30 // 30% corporate tax rate
      const taxAmount = taxableRevenue * taxRate
      
      const operatingExpenses = totalRevenue * 0.40 // 40% operating expenses
      const depreciation = totalRevenue * 0.05 // 5% depreciation
      const otherDeductions = totalRevenue * 0.02 // 2% other deductions
      
      const netTaxableIncome = taxableRevenue - operatingExpenses - depreciation - otherDeductions
      const vatCollected = totalRevenue * 0.18 // 18% VAT
      const withholdingTax = totalRevenue * 0.05 // 5% withholding tax
      const totalTaxLiability = taxAmount + vatCollected + withholdingTax
      
      const advancePayments = totalTaxLiability * 0.25 // 25% advance payments
      const finalPayment = totalTaxLiability - advancePayments

      return {
        totalRevenue,
        taxableRevenue,
        taxRate,
        taxAmount,
        deductions: {
          operatingExpenses,
          depreciation,
          other: otherDeductions
        },
        netTaxableIncome,
        vatCollected,
        withholdingTax,
        totalTaxLiability,
        payments: {
          advancePayments,
          finalPayment,
          totalPaid: advancePayments + finalPayment
        },
        period
      }
    } catch (error) {
      console.error('Error getting URA Tax report data:', error)
      return {
        totalRevenue: 0,
        taxableRevenue: 0,
        taxRate: 0,
        taxAmount: 0,
        deductions: {
          operatingExpenses: 0,
          depreciation: 0,
          other: 0
        },
        netTaxableIncome: 0,
        vatCollected: 0,
        withholdingTax: 0,
        totalTaxLiability: 0,
        payments: {
          advancePayments: 0,
          finalPayment: 0,
          totalPaid: 0
        },
        period
      }
    }
  }

  // Get Data Protection report data
  private async getDataProtectionReportData(period: { startDate: Date; endDate: Date }): Promise<DataProtectionReport> {
    try {
      const users = await this.getCollectionData('users', period.startDate, period.endDate)
      const consentData = await this.getConsentData(period)
      const securityIncidents = await this.getCollectionData('security_incidents', period.startDate, period.endDate)

      return {
        dataInventory: {
          personalDataTypes: ['name', 'email', 'phone', 'location', 'payment_info'],
          dataSources: ['mobile_app', 'web_app', 'admin_panel'],
          dataRecipients: ['payment_processors', 'analytics_services']
        },
        consentManagement: {
          consentCollected: consentData.collected,
          consentWithdrawn: consentData.withdrawn,
          consentPending: consentData.pending
        },
        dataSubjectRights: {
          accessRequests: consentData.accessRequests,
          rectificationRequests: consentData.rectificationRequests,
          erasureRequests: consentData.erasureRequests,
          portabilityRequests: consentData.portabilityRequests
        },
        securityIncidents: {
          dataBreaches: securityIncidents.filter(incident => incident.type === 'data_breach').length,
          unauthorizedAccess: securityIncidents.filter(incident => incident.type === 'unauthorized_access').length,
          dataLoss: securityIncidents.filter(incident => incident.type === 'data_loss').length
        },
        complianceStatus: {
          gdprCompliant: true,
          dataProtectionOfficer: 'Data Protection Officer',
          lastAudit: new Date()
        }
      }
    } catch (error) {
      console.error('Error getting Data Protection report data:', error)
      return {
        dataInventory: {
          personalDataTypes: [],
          dataSources: [],
          dataRecipients: []
        },
        consentManagement: {
          consentCollected: 0,
          consentWithdrawn: 0,
          consentPending: 0
        },
        dataSubjectRights: {
          accessRequests: 0,
          rectificationRequests: 0,
          erasureRequests: 0,
          portabilityRequests: 0
        },
        securityIncidents: {
          dataBreaches: 0,
          unauthorizedAccess: 0,
          dataLoss: 0
        },
        complianceStatus: {
          gdprCompliant: false,
          dataProtectionOfficer: '',
          lastAudit: new Date()
        }
      }
    }
  }

  // Helper methods
  private async getCollectionData(collectionName: string, startDate: Date, endDate: Date): Promise<any[]> {
    try {
      const q = query(
        collection(db, collectionName),
        where('createdAt', '>=', startDate),
        where('createdAt', '<=', endDate)
      )
      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }))
    } catch (error) {
      console.error(`Error getting ${collectionName} data:`, error)
      return []
    }
  }

  private async getConsentData(period: { startDate: Date; endDate: Date }): Promise<any> {
    // Mock consent data - in real implementation, this would query consent collection
    return {
      collected: 1000,
      withdrawn: 50,
      pending: 25,
      requests: 10,
      accessRequests: 5,
      rectificationRequests: 3,
      erasureRequests: 2,
      portabilityRequests: 1
    }
  }

  private async getSecurityData(period: { startDate: Date; endDate: Date }): Promise<any> {
    // Mock security data - in real implementation, this would query security logs
    return {
      auditLogs: 5000
    }
  }

  private calculateDataProcessed(users: any[]): number {
    // Mock calculation - in real implementation, this would calculate actual data volume
    return users.length * 1024 * 1024 // 1MB per user
  }
}

export const complianceService = new ComplianceService()
