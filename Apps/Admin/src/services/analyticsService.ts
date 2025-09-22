import { collection, getDocs, query, where, orderBy, limit, Timestamp } from 'firebase/firestore'
import { db } from '../config/firebase'

export interface AnalyticsData {
  overview: {
    totalUsers: number
    totalDrivers: number
    totalVendors: number
    totalOrders: number
    totalRevenue: number
    activeTrips: number
    completedTrips: number
    cancelledTrips: number
  }
  revenue: {
    daily: { date: string; amount: number }[]
    weekly: { week: string; amount: number }[]
    monthly: { month: string; amount: number }[]
    yearly: { year: string; amount: number }[]
  }
  users: {
    newUsers: { date: string; count: number }[]
    activeUsers: { date: string; count: number }[]
    userRetention: { period: string; rate: number }[]
  }
  trips: {
    completedTrips: { date: string; count: number }[]
    averageFare: { date: string; amount: number }[]
    tripTypes: { type: string; count: number }[]
  }
  drivers: {
    performance: { driverId: string; name: string; rating: number; trips: number; earnings: number }[]
    earnings: { date: string; amount: number }[]
    ratings: { date: string; average: number }[]
  }
  vendors: {
    performance: { vendorId: string; name: string; orders: number; revenue: number; rating: number }[]
    revenue: { date: string; amount: number }[]
    orders: { date: string; count: number }[]
  }
  heatmap: {
    area: string
    coordinates: { lat: number; lng: number }
    demand: number
    revenue: number
  }[]
  profitLoss: {
    revenue: number
    expenses: number
    profit: number
    margin: number
    breakdown: {
      category: string
      amount: number
      percentage: number
    }[]
  }
}

export interface PerformanceMetrics {
  kpis: {
    name: string
    value: number
    change: number
    trend: 'up' | 'down' | 'stable'
    target: number
  }[]
  charts: {
    type: 'line' | 'bar' | 'pie' | 'area'
    title: string
    data: any[]
    xAxis?: string
    yAxis?: string
  }[]
}

class AnalyticsService {
  private collections = {
    users: 'users',
    drivers: 'drivers',
    vendors: 'vendors',
    orders: 'orders',
    payments: 'payments',
    trips: 'trips'
  }

  // Get comprehensive analytics data
  async getAnalyticsData(period: 'day' | 'week' | 'month' | 'year' = 'month'): Promise<AnalyticsData> {
    try {
      const endDate = new Date()
      const startDate = this.getStartDate(period, endDate)

      const [
        overview,
        revenue,
        users,
        trips,
        drivers,
        vendors,
        heatmap,
        profitLoss
      ] = await Promise.all([
        this.getOverviewData(startDate, endDate),
        this.getRevenueData(startDate, endDate, period),
        this.getUserData(startDate, endDate, period),
        this.getTripData(startDate, endDate, period),
        this.getDriverData(startDate, endDate, period),
        this.getVendorData(startDate, endDate, period),
        this.getHeatmapData(startDate, endDate),
        this.getProfitLossData(startDate, endDate)
      ])

      return {
        overview,
        revenue,
        users,
        trips,
        drivers,
        vendors,
        heatmap,
        profitLoss
      }
    } catch (error) {
      console.error('Error getting analytics data:', error)
      throw error
    }
  }

  // Get overview statistics
  private async getOverviewData(startDate: Date, endDate: Date) {
    const [users, drivers, vendors, orders, payments, activeTrips] = await Promise.all([
      this.getCollectionCount(this.collections.users, startDate, endDate),
      this.getCollectionCount(this.collections.drivers, startDate, endDate),
      this.getCollectionCount(this.collections.vendors, startDate, endDate),
      this.getCollectionCount(this.collections.orders, startDate, endDate),
      this.getCollectionData(this.collections.payments, startDate, endDate),
      this.getActiveTripsCount()
    ])

    const totalRevenue = payments.reduce((sum, payment) => sum + (payment.amount || 0), 0)
    const completedTrips = orders.filter(order => order.status === 'completed').length
    const cancelledTrips = orders.filter(order => order.status === 'cancelled').length

    return {
      totalUsers: users,
      totalDrivers: drivers,
      totalVendors: vendors,
      totalOrders: orders.length,
      totalRevenue,
      activeTrips: activeTrips,
      completedTrips,
      cancelledTrips
    }
  }

  // Get revenue data
  private async getRevenueData(startDate: Date, endDate: Date, period: string) {
    const payments = await this.getCollectionData(this.collections.payments, startDate, endDate)
    
    const groupedData = this.groupDataByPeriod(payments, period, 'amount')
    
    return {
      daily: groupedData.daily,
      weekly: groupedData.weekly,
      monthly: groupedData.monthly,
      yearly: groupedData.yearly
    }
  }

  // Get user data
  private async getUserData(startDate: Date, endDate: Date, period: string) {
    const users = await this.getCollectionData(this.collections.users, startDate, endDate)
    const newUsers = this.groupDataByPeriod(users, period, 'count')
    
    // Calculate active users (users who made at least one order)
    const activeUsers = await this.getActiveUsersData(startDate, endDate, period)
    
    return {
      newUsers: newUsers.daily,
      activeUsers: activeUsers.daily,
      userRetention: await this.calculateUserRetention(startDate, endDate)
    }
  }

  // Get trip data
  private async getTripData(startDate: Date, endDate: Date, period: string) {
    const orders = await this.getCollectionData(this.collections.orders, startDate, endDate)
    const completedOrders = orders.filter(order => order.status === 'completed')
    
    const completedTrips = this.groupDataByPeriod(completedOrders, period, 'count')
    const averageFare = this.calculateAverageFare(completedOrders, period)
    
    // Group by trip type
    const tripTypes = this.groupByField(completedOrders, 'type')
    
    return {
      completedTrips: completedTrips.daily,
      averageFare: averageFare.daily,
      tripTypes: Object.entries(tripTypes).map(([type, count]) => ({ type, count }))
    }
  }

  // Get driver performance data
  private async getDriverData(startDate: Date, endDate: Date, period: string) {
    const drivers = await this.getCollectionData(this.collections.drivers, startDate, endDate)
    const orders = await this.getCollectionData(this.collections.orders, startDate, endDate)
    
    const performance = drivers.map(driver => {
      const driverOrders = orders.filter(order => order.driverId === driver.id)
      const completedOrders = driverOrders.filter(order => order.status === 'completed')
      const totalEarnings = completedOrders.reduce((sum, order) => sum + (order.driverEarnings || 0), 0)
      const averageRating = driver.rating || 0
      
      return {
        driverId: driver.id,
        name: driver.name || 'Unknown',
        rating: averageRating,
        trips: completedOrders.length,
        earnings: totalEarnings
      }
    }).sort((a, b) => b.earnings - a.earnings)

    const earnings = this.groupDataByPeriod(
      orders.filter(order => order.status === 'completed'),
      period,
      'driverEarnings'
    )

    return {
      performance,
      earnings: earnings.daily,
      ratings: this.calculateAverageRatings(drivers, period)
    }
  }

  // Get vendor performance data
  private async getVendorData(startDate: Date, endDate: Date, period: string) {
    const vendors = await this.getCollectionData(this.collections.vendors, startDate, endDate)
    const orders = await this.getCollectionData(this.collections.orders, startDate, endDate)
    
    const performance = vendors.map(vendor => {
      const vendorOrders = orders.filter(order => order.vendorId === vendor.id)
      const completedOrders = vendorOrders.filter(order => order.status === 'completed')
      const totalRevenue = completedOrders.reduce((sum, order) => sum + (order.amount || 0), 0)
      const averageRating = vendor.rating || 0
      
      return {
        vendorId: vendor.id,
        name: vendor.name || 'Unknown',
        orders: completedOrders.length,
        revenue: totalRevenue,
        rating: averageRating
      }
    }).sort((a, b) => b.revenue - a.revenue)

    const revenue = this.groupDataByPeriod(
      orders.filter(order => order.status === 'completed'),
      period,
      'amount'
    )

    return {
      performance,
      revenue: revenue.daily,
      orders: this.groupDataByPeriod(orders, period, 'count').daily
    }
  }

  // Get heatmap data
  private async getHeatmapData(startDate: Date, endDate: Date) {
    const orders = await this.getCollectionData(this.collections.orders, startDate, endDate)
    
    // Group orders by area/coordinates
    const areaData: Record<string, { count: number; revenue: number; coordinates: { lat: number; lng: number } }> = {}
    
    orders.forEach(order => {
      if (order.pickupLocation?.coordinates) {
        const area = this.getAreaFromCoordinates(order.pickupLocation.coordinates)
        if (!areaData[area]) {
          areaData[area] = { count: 0, revenue: 0, coordinates: order.pickupLocation.coordinates }
        }
        areaData[area].count += 1
        areaData[area].revenue += order.amount || 0
      }
    })

    return Object.entries(areaData).map(([area, data]) => ({
      area,
      coordinates: data.coordinates,
      demand: data.count,
      revenue: data.revenue
    }))
  }

  // Get profit and loss data
  private async getProfitLossData(startDate: Date, endDate: Date) {
    const payments = await this.getCollectionData(this.collections.payments, startDate, endDate)
    const orders = await this.getCollectionData(this.collections.orders, startDate, endDate)
    
    const revenue = payments
      .filter(payment => payment.status === 'completed')
      .reduce((sum, payment) => sum + payment.amount, 0)
    
    const expenses = payments.reduce((sum, payment) => sum + (payment.commission || 0) + (payment.processingFee || 0), 0)
    
    const profit = revenue - expenses
    const margin = revenue > 0 ? (profit / revenue) * 100 : 0

    const breakdown = [
      { category: 'Revenue', amount: revenue, percentage: 100 },
      { category: 'Commission', amount: payments.reduce((sum, p) => sum + (p.commission || 0), 0), percentage: revenue > 0 ? (payments.reduce((sum, p) => sum + (p.commission || 0), 0) / revenue) * 100 : 0 },
      { category: 'Processing Fees', amount: payments.reduce((sum, p) => sum + (p.processingFee || 0), 0), percentage: revenue > 0 ? (payments.reduce((sum, p) => sum + (p.processingFee || 0), 0) / revenue) * 100 : 0 },
      { category: 'Net Profit', amount: profit, percentage: margin }
    ]

    return {
      revenue,
      expenses,
      profit,
      margin,
      breakdown
    }
  }

  // Helper methods
  private getStartDate(period: string, endDate: Date): Date {
    const start = new Date(endDate)
    switch (period) {
      case 'day':
        start.setDate(start.getDate() - 1)
        break
      case 'week':
        start.setDate(start.getDate() - 7)
        break
      case 'month':
        start.setMonth(start.getMonth() - 1)
        break
      case 'year':
        start.setFullYear(start.getFullYear() - 1)
        break
    }
    return start
  }

  private async getCollectionCount(collectionName: string, startDate: Date, endDate: Date): Promise<number> {
    try {
      const q = query(
        collection(db, collectionName),
        where('createdAt', '>=', startDate),
        where('createdAt', '<=', endDate)
      )
      const snapshot = await getDocs(q)
      return snapshot.size
    } catch (error) {
      console.error(`Error getting ${collectionName} count:`, error)
      return 0
    }
  }

  private async getCollectionData(collectionName: string, startDate: Date, endDate: Date): Promise<any[]> {
    try {
      const q = query(
        collection(db, collectionName),
        where('createdAt', '>=', startDate),
        where('createdAt', '<=', endDate)
      )
      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate() || new Date()
      }))
    } catch (error) {
      console.error(`Error getting ${collectionName} data:`, error)
      return []
    }
  }

  private async getActiveTripsCount(): Promise<number> {
    try {
      const q = query(
        collection(db, this.collections.orders),
        where('status', 'in', ['pending', 'assigned', 'picked_up', 'in_progress'])
      )
      const snapshot = await getDocs(q)
      return snapshot.size
    } catch (error) {
      console.error('Error getting active trips count:', error)
      return 0
    }
  }

  private groupDataByPeriod(data: any[], period: string, valueField: string) {
    const grouped: Record<string, any> = { daily: [], weekly: [], monthly: [], yearly: [] }
    
    data.forEach(item => {
      const date = new Date(item.createdAt)
      const dayKey = date.toISOString().split('T')[0]
      const weekKey = this.getWeekKey(date)
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
      const yearKey = date.getFullYear().toString()
      
      const value = valueField === 'count' ? 1 : (item[valueField] || 0)
      
      this.addToGroup(grouped.daily, dayKey, value)
      this.addToGroup(grouped.weekly, weekKey, value)
      this.addToGroup(grouped.monthly, monthKey, value)
      this.addToGroup(grouped.yearly, yearKey, value)
    })
    
    return grouped
  }

  private addToGroup(group: any[], key: string, value: number) {
    const existing = group.find(item => item.date === key || item.week === key || item.month === key || item.year === key)
    if (existing) {
      existing.amount += value
      existing.count += value
    } else {
      group.push({
        [key.includes('-') ? 'date' : key.length === 4 ? 'year' : 'week']: key,
        amount: value,
        count: value
      })
    }
  }

  private getWeekKey(date: Date): string {
    const year = date.getFullYear()
    const week = this.getWeekNumber(date)
    return `${year}-W${String(week).padStart(2, '0')}`
  }

  private getWeekNumber(date: Date): number {
    const firstDayOfYear = new Date(date.getFullYear(), 0, 1)
    const pastDaysOfYear = (date.getTime() - firstDayOfYear.getTime()) / 86400000
    return Math.ceil((pastDaysOfYear + firstDayOfYear.getDay() + 1) / 7)
  }

  private groupByField(data: any[], field: string): Record<string, number> {
    return data.reduce((acc, item) => {
      const value = item[field] || 'unknown'
      acc[value] = (acc[value] || 0) + 1
      return acc
    }, {})
  }

  private calculateAverageFare(orders: any[], period: string) {
    const grouped = this.groupDataByPeriod(orders, period, 'amount')
    return {
      daily: grouped.daily.map(item => ({
        date: item.date,
        amount: item.amount / item.count
      }))
    }
  }

  private async getActiveUsersData(startDate: Date, endDate: Date, period: string) {
    // This would calculate active users based on order activity
    // For now, returning mock data
    return { daily: [] }
  }

  private async calculateUserRetention(startDate: Date, endDate: Date) {
    // This would calculate user retention rates
    // For now, returning mock data
    return []
  }

  private calculateAverageRatings(drivers: any[], period: string) {
    // This would calculate average ratings over time
    // For now, returning mock data
    return { daily: [] }
  }

  private getAreaFromCoordinates(coordinates: { lat: number; lng: number }): string {
    // This would convert coordinates to area names
    // For now, returning mock area
    return `Area_${Math.round(coordinates.lat * 100)}_${Math.round(coordinates.lng * 100)}`
  }

  // Get comprehensive analytics data
  async getAnalytics(): Promise<any> {
    try {
      // Return mock analytics data for now
      return {
        totalUsers: 2847,
        totalRevenue: 12500000, // UGX
        activeTrips: 23,
        coverageArea: 150, // km²
        averageResponseTime: 1.2, // seconds
        successRate: 98.5, // percentage
        customerSatisfaction: 4.6, // out of 5
        revenueGrowth: 15.2, // percentage
        userGrowth: 8.7, // percentage
        tripCompletionRate: 96.8, // percentage
        averageFare: 8500, // UGX
        peakHours: ['7:00-9:00', '17:00-19:00'],
        topAreas: [
          { name: 'Kampala Central', trips: 456 },
          { name: 'Nakawa', trips: 234 },
          { name: 'Makindye', trips: 189 },
          { name: 'Rubaga', trips: 167 },
          { name: 'Kawempe', trips: 145 }
        ],
        driverPerformance: {
          averageRating: 4.5,
          totalDrivers: 156,
          activeDrivers: 89,
          newDrivers: 12
        },
        customerMetrics: {
          totalCustomers: 2847,
          newCustomers: 234,
          returningCustomers: 2613,
          averageOrderValue: 12500
        }
      }
    } catch (error) {
      console.error('Error getting analytics:', error)
      return {
        totalUsers: 0,
        totalRevenue: 0,
        activeTrips: 0,
        coverageArea: 0,
        averageResponseTime: 0,
        successRate: 0,
        customerSatisfaction: 0,
        revenueGrowth: 0,
        userGrowth: 0,
        tripCompletionRate: 0,
        averageFare: 0,
        peakHours: [],
        topAreas: [],
        driverPerformance: {
          averageRating: 0,
          totalDrivers: 0,
          activeDrivers: 0,
          newDrivers: 0
        },
        customerMetrics: {
          totalCustomers: 0,
          newCustomers: 0,
          returningCustomers: 0,
          averageOrderValue: 0
        }
      }
    }
  }
}

export const analyticsService = new AnalyticsService()
