import { useState, useEffect } from 'react'
import { Receipt, DollarSign, TrendingUp, Edit } from 'lucide-react'

export default function TaxTransactions() {
  const [taxStats, setTaxStats] = useState({
    totalTaxCollected: 6116.60,
    taxPaid: 4660.00,
    taxToBePaid: 1456.60
  })

  const [transactions, setTransactions] = useState([
    {
      id: 1,
      amount: 4400,
      date: '31 Jul 2025',
      time: '05:20 PM'
    },
    {
      id: 2,
      amount: 100,
      date: '31 Jul 2025',
      time: '05:20 PM'
    },
    {
      id: 3,
      amount: 100,
      date: '16 May 2025',
      time: '01:51 PM'
    },
    {
      id: 4,
      amount: 50,
      date: '01 Apr 2025',
      time: '01:14 PM'
    }
  ])

  const handleUpdateTax = () => {
    // Implement tax update functionality
    console.log('Updating tax...')
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Tax Transactions</h1>
        <p className="text-gray-600 mt-1">Manage tax collection and payments</p>
      </div>

      {/* Tax Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Total tax collected</h3>
              <p className="text-3xl font-bold text-green-600">${taxStats.totalTaxCollected.toLocaleString()}</p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <TrendingUp className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Tax paid</h3>
              <p className="text-3xl font-bold text-blue-600">${taxStats.taxPaid.toLocaleString()}</p>
            </div>
            <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <DollarSign className="w-6 h-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Tax to be paid</h3>
              <p className="text-3xl font-bold text-orange-600">${taxStats.taxToBePaid.toLocaleString()}</p>
              <button
                onClick={handleUpdateTax}
                className="mt-2 px-3 py-1 bg-gray-800 text-white text-sm rounded hover:bg-gray-900 transition-colors"
              >
                Update Tax
              </button>
            </div>
            <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
              <Receipt className="w-6 h-6 text-orange-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Tax Transactions Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Tax transactions</h3>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Sr. no.
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Time
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {transactions.map((transaction, index) => (
                <tr key={transaction.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    ${transaction.amount.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {transaction.date}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {transaction.time}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="flex items-center justify-between mt-4">
          <div className="text-sm text-gray-700">
            Showing 1 to 4 of 4 entries
          </div>
          <div className="flex items-center space-x-2">
            <button className="px-3 py-1 border border-gray-300 rounded text-sm text-gray-700 hover:bg-gray-50">
              ←
            </button>
            <button className="px-3 py-1 bg-yellow-500 text-white rounded text-sm">
              1
            </button>
            <button className="px-3 py-1 border border-gray-300 rounded text-sm text-gray-700 hover:bg-gray-50">
              2
            </button>
            <button className="px-3 py-1 border border-gray-300 rounded text-sm text-gray-700 hover:bg-gray-50">
              →
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
