import { useState, useEffect } from 'react'
import { DollarSign, TrendingUp, CreditCard, Receipt } from 'lucide-react'

export default function Payouts() {
  const [payoutStats, setPayoutStats] = useState({
    balanceDueToDriver: 12892.16,
    balanceDueToVendor: 16694.85,
    balanceInStripe: 2073613.97,
    taxToBePaid: -720.78
  })

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Payouts</h1>
        <p className="text-gray-600 mt-1">Manage financial transactions and payouts</p>
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
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Balance in stripe</h3>
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
              {payoutStats.taxToBePaid < 0 && (
                <p className="text-sm text-red-600">Credit/Refund</p>
              )}
            </div>
            <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
              <Receipt className="w-6 h-6 text-orange-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Payout Actions */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Payout Actions</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors text-left">
            <DollarSign className="w-6 h-6 text-blue-600 mb-2" />
            <h4 className="font-medium text-gray-900">Process Driver Payouts</h4>
            <p className="text-sm text-gray-600">Send pending payments to drivers</p>
          </button>
          
          <button className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors text-left">
            <TrendingUp className="w-6 h-6 text-green-600 mb-2" />
            <h4 className="font-medium text-gray-900">Process Vendor Payouts</h4>
            <p className="text-sm text-gray-600">Send pending payments to restaurants</p>
          </button>
          
          <button className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors text-left">
            <Receipt className="w-6 h-6 text-orange-600 mb-2" />
            <h4 className="font-medium text-gray-900">Tax Management</h4>
            <p className="text-sm text-gray-600">Handle tax payments and refunds</p>
          </button>
        </div>
      </div>

      {/* Recent Transactions */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Recent Transactions</h3>
        <div className="text-center py-8">
          <Receipt className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500">No recent transactions to display</p>
        </div>
      </div>
    </div>
  )
}
