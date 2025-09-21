import { useState, useEffect } from 'react'
import { DollarSign, TrendingUp, CreditCard, Receipt, RefreshCw } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'

export default function Payouts() {
  const [payoutStats, setPayoutStats] = useState({
    balanceDueToDriver: 0,
    balanceDueToVendor: 0,
    balanceInStripe: 0,
    taxToBePaid: 0
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadPayoutStats()
  }, [])

  const loadPayoutStats = async () => {
    try {
      setLoading(true)
      
      // Get all drivers and calculate their pending earnings
      const drivers = await firebaseService.getDrivers()
      const balanceDueToDriver = drivers.reduce((total: number, driver: any) => {
        return total + (driver.pendingEarnings || 0)
      }, 0)
      
      // Get all vendors and calculate their pending earnings
      const vendors = await firebaseService.getVendors()
      const balanceDueToVendor = vendors.reduce((total: number, vendor: any) => {
        return total + (vendor.pendingEarnings || 0)
      }, 0)
      
      // Get total balance from payments collection
      const payments = await firebaseService.getCollection('payments')
      const balanceInStripe = payments.reduce((total: number, payment: any) => {
        if (payment.status === 'completed') {
          return total + (payment.amount || 0)
        }
        return total
      }, 0)
      
      // Calculate tax (simplified - you might want to implement proper tax calculation)
      const taxToBePaid = (balanceDueToDriver + balanceDueToVendor) * 0.1 // 10% tax
      
      setPayoutStats({
        balanceDueToDriver,
        balanceDueToVendor,
        balanceInStripe,
        taxToBePaid: -taxToBePaid
      })
    } catch (error) {
      console.error('Error loading payout stats:', error)
    } finally {
      setLoading(false)
    }
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
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Payouts</h1>
          <p className="text-gray-600 mt-1">Manage financial transactions and payouts from Firebase</p>
        </div>
        <button 
          onClick={loadPayoutStats}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh
        </button>
      </div>

      {/* Payout Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Balance due to driver</h3>
              <p className="text-3xl font-bold text-blue-600">${payoutStats.balanceDueToDriver.toLocaleString()}</p>
            </div>
            <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <DollarSign className="w-6 h-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Balance due to vendor</h3>
              <p className="text-3xl font-bold text-green-600">${payoutStats.balanceDueToVendor.toLocaleString()}</p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <TrendingUp className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Balance in Stripe</h3>
              <p className="text-3xl font-bold text-purple-600">${payoutStats.balanceInStripe.toLocaleString()}</p>
            </div>
            <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
              <CreditCard className="w-6 h-6 text-purple-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Tax to be paid</h3>
              <p className={`text-3xl font-bold ${payoutStats.taxToBePaid < 0 ? 'text-red-600' : 'text-orange-600'}`}>
                ${Math.abs(payoutStats.taxToBePaid).toLocaleString()}
              </p>
            </div>
            <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
              <Receipt className="w-6 h-6 text-orange-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Additional Payout Management */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Recent Payouts</h3>
          <div className="space-y-3">
            <div className="text-center py-8 text-gray-500">
              <Receipt className="w-12 h-12 mx-auto mb-2 text-gray-300" />
              <p>No recent payouts found</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Pending Approvals</h3>
          <div className="space-y-3">
            <div className="text-center py-8 text-gray-500">
              <CreditCard className="w-12 h-12 mx-auto mb-2 text-gray-300" />
              <p>No pending approvals</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}