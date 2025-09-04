import { useState, useEffect } from 'react'
import { Search, Eye, UserMinus, UserCheck } from 'lucide-react'

interface Customer {
  id: string
  name: string
  email: string
  phone: string
  orders: number
  status: 'active' | 'blocked' | 'deleted'
  joinedDate: string
}

export default function Customers() {
  const [customers, setCustomers] = useState<Customer[]>([
    {
      id: '1',
      name: 'Mohit',
      email: 'moh***********',
      phone: '+9********223',
      orders: 0,
      status: 'active',
      joinedDate: '01 Sep 2025'
    },
    {
      id: '2',
      name: 'Ramesh',
      email: 'sah***********',
      phone: '+9********433',
      orders: 0,
      status: 'active',
      joinedDate: '15 Aug 2025'
    },
    {
      id: '3',
      name: 'Yazar Arfath',
      email: 'yaz***********',
      phone: '+9********469',
      orders: 0,
      status: 'active',
      joinedDate: '20 Aug 2025'
    },
    {
      id: '4',
      name: 'saransh',
      email: 'sar***********',
      phone: '++*********677',
      orders: 10,
      status: 'active',
      joinedDate: '10 Aug 2025'
    },
    {
      id: '5',
      name: 'Vanshagrawalgmailcom',
      email: 'van***********',
      phone: '+9********857',
      orders: 0,
      status: 'active',
      joinedDate: '25 Aug 2025'
    }
  ])

  const [activeTab, setActiveTab] = useState<'active' | 'blocked' | 'deleted'>('active')
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null)

  const filteredCustomers = customers.filter(customer => {
    const matchesTab = customer.status === activeTab
    const matchesSearch = customer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         customer.phone.includes(searchTerm)
    return matchesTab && matchesSearch
  })

  const handleBlockCustomer = (customerId: string) => {
    setCustomers(prev => prev.map(customer => 
      customer.id === customerId 
        ? { ...customer, status: 'blocked' as const }
        : customer
    ))
  }

  const handleUnblockCustomer = (customerId: string) => {
    setCustomers(prev => prev.map(customer => 
      customer.id === customerId 
        ? { ...customer, status: 'active' as const }
        : customer
    ))
  }

  const CustomerDetailsModal = ({ customer, onClose }: { customer: Customer, onClose: () => void }) => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Customer Details</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            ×
          </button>
        </div>
        
        <div className="space-y-4">
          <div className="text-center">
            <div className="w-16 h-16 bg-gray-300 rounded-full mx-auto mb-2 flex items-center justify-center">
              <span className="text-gray-600 text-xl">👤</span>
            </div>
            <span className={`inline-block px-2 py-1 rounded-full text-xs font-medium ${
              customer.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
            }`}>
              {customer.status.charAt(0).toUpperCase() + customer.status.slice(1)}
            </span>
            <p className="text-sm text-gray-600 mt-1">Joined on: {customer.joinedDate}</p>
          </div>
          
          <div className="space-y-2">
            <div>
              <span className="text-sm font-medium text-gray-700">Name:</span>
              <p className="text-gray-900">{customer.name}</p>
            </div>
            <div>
              <span className="text-sm font-medium text-gray-700">Email:</span>
              <p className="text-gray-900">{customer.email}</p>
            </div>
            <div>
              <span className="text-sm font-medium text-gray-700">Phone:</span>
              <p className="text-gray-900">{customer.phone}</p>
            </div>
          </div>
          
          <div className="border-t pt-4">
            <h4 className="font-medium text-gray-900 mb-2">Orders</h4>
            <div className="text-sm text-gray-500">No orders found</div>
          </div>
        </div>
      </div>
    </div>
  )

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Customers</h1>
        <p className="text-gray-600 mt-1">Manage customer accounts and information</p>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          {[
            { key: 'active', label: 'Active' },
            { key: 'blocked', label: 'Blocked' },
            { key: 'deleted', label: 'Deleted' }
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

      {/* Search */}
      <div className="flex items-center space-x-4">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder="Search by name or phone number"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
          />
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Sr. no.
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Email
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Phone
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  No. of orders
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Action
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredCustomers.map((customer, index) => (
                <tr key={customer.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center mr-3">
                        <span className="text-gray-600 text-sm">👤</span>
                      </div>
                      <span className="text-sm font-medium text-gray-900">{customer.name}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {customer.email}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {customer.phone}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {customer.orders}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button
                      onClick={() => setSelectedCustomer(customer)}
                      className="w-8 h-8 bg-yellow-100 text-yellow-600 rounded-full flex items-center justify-center hover:bg-yellow-200 transition-colors"
                    >
                      <Eye className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Customer Details Modal */}
      {selectedCustomer && (
        <CustomerDetailsModal 
          customer={selectedCustomer} 
          onClose={() => setSelectedCustomer(null)} 
        />
      )}
    </div>
  )
}
