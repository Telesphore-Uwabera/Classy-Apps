import { useState, useEffect } from 'react'
import { Receipt, DollarSign, TrendingUp, Edit, RefreshCw } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'

interface TaxTransaction {
  id: string
  amount: number
  date: string
  time: string
  type: 'collected' | 'paid'
  description: string
}

export default function TaxTransactions() {
  const [taxStats, setTaxStats] = useState({
    totalTaxCollected: 0,
    taxPaid: 0,
    taxToBePaid: 0
  })
  const [transactions, setTransactions] = useState<TaxTransaction[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadTaxData()
  }, [])

  const loadTaxData = async () => {
    try {
      setLoading(true)
      
      // Get all orders to calculate tax
      const orders = await firebaseService.getOrders()
      const payments = await firebaseService.getCollection('payments')
      
      // Calculate tax collected from orders
      const totalTaxCollected = orders
        .filter((order: any) => order.status === 'delivered')
        .reduce((total: number, order: any) => {
          return total + (order.taxAmount || 0)
        }, 0)
      
      // Calculate tax paid (from payments with tax status)
      const taxPaid = payments
        .filter((payment: any) => payment.type === 'tax_payment' && payment.status === 'completed')
        .reduce((total: number, payment: any) => {
          return total + (payment.amount || 0)
        }, 0)
      
      const taxToBePaid = totalTaxCollected - taxPaid
      
      setTaxStats({
        totalTaxCollected,
        taxPaid,
        taxToBePaid
      })
      
      // Create transaction history from payments
      const taxTransactions = payments
        .filter((payment: any) => payment.type === 'tax_payment')
        .map((payment: any) => ({
          id: payment.id,
          amount: payment.amount || 0,
          date: payment.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
          time: payment.createdAt?.toDate?.()?.toLocaleTimeString() || 'Unknown',
          type: 'paid' as const,
          description: 'Tax Payment'
        }))
        .sort((a: TaxTransaction, b: TaxTransaction) => {
          const dateA = new Date(a.date)
          const dateB = new Date(b.date)
          return dateB.getTime() - dateA.getTime()
        })
      
      setTransactions(taxTransactions)
    } catch (error) {
      console.error('Error loading tax data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleUpdateTax = async () => {
    try {
      // Create a new tax payment record
      const taxPaymentData = {
        amount: taxStats.taxToBePaid,
        type: 'tax_payment',
        status: 'completed',
        description: 'Tax payment processed',
        createdAt: new Date()
      }
      
      await firebaseService.addDocument('payments', taxPaymentData)
      
      // Reload data
      await loadTaxData()
      
      alert('Tax payment processed successfully!')
    } catch (error) {
      console.error('Error processing tax payment:', error)
      alert('Error processing tax payment')
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
          <h1 className="text-3xl font-bold text-gray-900">Tax Transactions</h1>
          <p className="text-gray-600 mt-1">Manage tax collection from Firebase</p>
        </div>
        <button 
          onClick={loadTaxData}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh
        </button>
      </div>

      {/* Tax Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Total Tax Collected</h3>
              <p className="text-3xl font-bold text-blue-600">${taxStats.totalTaxCollected.toFixed(2)}</p>
            </div>
            <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <DollarSign className="w-6 h-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Tax Paid</h3>
              <p className="text-3xl font-bold text-green-600">${taxStats.taxPaid.toFixed(2)}</p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <Receipt className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Tax to be Paid</h3>
              <p className={`text-3xl font-bold ${taxStats.taxToBePaid > 0 ? 'text-orange-600' : 'text-gray-600'}`}>
                ${taxStats.taxToBePaid.toFixed(2)}
              </p>
            </div>
            <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
              <TrendingUp className="w-6 h-6 text-orange-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Tax Payment Action */}
      {taxStats.taxToBePaid > 0 && (
        <div className="bg-orange-50 border border-orange-200 rounded-lg p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-orange-800">Outstanding Tax Payment</h3>
              <p className="text-orange-600">You have ${taxStats.taxToBePaid.toFixed(2)} in outstanding tax payments.</p>
            </div>
            <button
              onClick={handleUpdateTax}
              className="flex items-center px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors"
            >
              <Edit className="w-4 h-4 mr-2" />
              Process Payment
            </button>
          </div>
        </div>
      )}

      {/* Tax Transactions Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-800">Tax Transaction History</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Time
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Type
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {transactions.map((transaction) => (
                <tr key={transaction.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {transaction.date}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {transaction.time}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-green-600">
                    ${transaction.amount.toFixed(2)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      {transaction.type}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {transactions.length === 0 && (
          <div className="text-center py-12">
            <Receipt className="w-12 h-12 text-gray-400 mx-auto mb-2" />
            <div className="text-gray-500">No tax transactions found</div>
          </div>
        )}
      </div>
    </div>
  )
}