import { useState, useEffect } from 'react'
import { TrendingUp, Download, Calendar, DollarSign, RefreshCw } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'

export default function Earnings() {
  const [activeTab, setActiveTab] = useState<'today' | 'thisWeek' | 'thisMonth' | 'thisYear' | 'custom'>('today')
  const [earningsData, setEarningsData] = useState({
    today: 0,
    thisWeek: 0,
    thisMonth: 0,
    thisYear: 0
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadEarningsData()
  }, [])

  const loadEarningsData = async () => {
    try {
      setLoading(true)
      
      // Get all orders and calculate earnings based on date ranges
      const orders = await firebaseService.getOrders()
      const now = new Date()
      
      // Calculate date ranges
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
      const thisWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000)
      const thisMonth = new Date(now.getFullYear(), now.getMonth(), 1)
      const thisYear = new Date(now.getFullYear(), 0, 1)
      
      // Calculate earnings for each period
      const todayEarnings = orders.filter((order: any) => {
        const orderDate = order.createdAt?.toDate?.() || new Date(order.createdAt)
        return orderDate >= today && order.status === 'delivered'
      }).reduce((total: number, order: any) => total + (order.adminCommission || 0), 0)
      
      const weekEarnings = orders.filter((order: any) => {
        const orderDate = order.createdAt?.toDate?.() || new Date(order.createdAt)
        return orderDate >= thisWeek && order.status === 'delivered'
      }).reduce((total: number, order: any) => total + (order.adminCommission || 0), 0)
      
      const monthEarnings = orders.filter((order: any) => {
        const orderDate = order.createdAt?.toDate?.() || new Date(order.createdAt)
        return orderDate >= thisMonth && order.status === 'delivered'
      }).reduce((total: number, order: any) => total + (order.adminCommission || 0), 0)
      
      const yearEarnings = orders.filter((order: any) => {
        const orderDate = order.createdAt?.toDate?.() || new Date(order.createdAt)
        return orderDate >= thisYear && order.status === 'delivered'
      }).reduce((total: number, order: any) => total + (order.adminCommission || 0), 0)
      
      setEarningsData({
        today: todayEarnings,
        thisWeek: weekEarnings,
        thisMonth: monthEarnings,
        thisYear: yearEarnings
      })
    } catch (error) {
      console.error('Error loading earnings data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleExport = () => {
    // Implement export functionality
    const data = {
      period: activeTab,
      earnings: earningsData[activeTab],
      timestamp: new Date().toISOString()
    }
    
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `earnings-${activeTab}-${new Date().toISOString().split('T')[0]}.json`
    a.click()
    URL.revokeObjectURL(url)
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="flex justify-center items-center h-64">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-pink-500"></div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Earnings</h1>
          <p className="text-gray-600 mt-1">Track platform earnings from Firebase</p>
        </div>
        <div className="flex space-x-2">
          <button
            onClick={loadEarningsData}
            className="flex items-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
          >
            <RefreshCw className="w-4 h-4 mr-2" />
            Refresh
          </button>
          <button
            onClick={handleExport}
            className="flex items-center px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors"
          >
            <Download className="w-4 h-4 mr-2" />
            Export
          </button>
        </div>
      </div>

      {/* Date Filter Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          {[
            { key: 'today', label: 'Today' },
            { key: 'thisWeek', label: 'This week' },
            { key: 'thisMonth', label: 'This month' },
            { key: 'thisYear', label: 'This year' },
            { key: 'custom', label: 'Custom date' }
          ].map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key as any)}
              className={`py-2 px-1 border-b-2 font-medium text-sm ${
                activeTab === tab.key
                  ? 'border-yellow-500 text-yellow-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </nav>
      </div>

      {/* Earnings Summary */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-800">Earnings Summary</h2>
          <div className="flex items-center text-sm text-gray-500">
            <Calendar className="w-4 h-4 mr-1" />
            {activeTab === 'today' && 'Today'}
            {activeTab === 'thisWeek' && 'This Week'}
            {activeTab === 'thisMonth' && 'This Month'}
            {activeTab === 'thisYear' && 'This Year'}
            {activeTab === 'custom' && 'Custom Period'}
          </div>
        </div>
        
        <div className="flex items-center justify-center py-12">
          <div className="text-center">
            <div className="flex items-center justify-center w-16 h-16 bg-yellow-100 rounded-full mx-auto mb-4">
              <DollarSign className="w-8 h-8 text-yellow-600" />
            </div>
            <h3 className="text-3xl font-bold text-gray-900 mb-2">
              ${earningsData[activeTab].toLocaleString()}
            </h3>
            <p className="text-gray-600">Total Platform Earnings</p>
          </div>
        </div>
      </div>

      {/* Earnings Chart Placeholder */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Earnings Trend</h3>
        <div className="flex items-center justify-center py-12 bg-gray-50 rounded-lg">
          <div className="text-center">
            <TrendingUp className="w-12 h-12 text-gray-400 mx-auto mb-2" />
            <p className="text-gray-500">Earnings trend chart will be displayed here</p>
          </div>
        </div>
      </div>
    </div>
  )
}