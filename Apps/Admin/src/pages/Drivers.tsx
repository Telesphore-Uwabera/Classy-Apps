import { useState, useEffect } from 'react'
import { Search, Eye, Car, Phone, Star, User } from 'lucide-react'

interface Driver {
  id: string
  name: string
  email: string
  phone: string
  orders: number
  rating: number | null
  status: 'active' | 'blocked' | 'deleted' | 'expired'
  joinedDate: string
  serviceType: 'car_driver' | 'boda_rider'
  isOnline: boolean
  totalEarnings: number
}

export default function Drivers() {
  const [drivers, setDrivers] = useState<Driver[]>([
    {
      id: '1',
      name: 'Telesphore',
      email: 'tel*********',
      phone: '+2** ******355',
      orders: 0,
      rating: null,
      status: 'active',
      joinedDate: '01 Sep 2025',
      serviceType: 'car_driver',
      isOnline: false,
      totalEarnings: 0
    },
    {
      id: '2',
      name: 'Telesphore Uwabera',
      email: 'tel*********',
      phone: '+2** ******355',
      orders: 0,
      rating: null,
      status: 'active',
      joinedDate: '15 Aug 2025',
      serviceType: 'boda_rider',
      isOnline: true,
      totalEarnings: 150
    },
    {
      id: '3',
      name: 'Qwerty',
      email: 'pus*********',
      phone: '+9* ******446',
      orders: 1,
      rating: null,
      status: 'active',
      joinedDate: '20 Aug 2025',
      serviceType: 'car_driver',
      isOnline: false,
      totalEarnings: 50
    },
    {
      id: '4',
      name: 'Test',
      email: 'sha*********',
      phone: '+9* ***** 464',
      orders: 1,
      rating: null,
      status: 'active',
      joinedDate: '10 Aug 2025',
      serviceType: 'boda_rider',
      isOnline: true,
      totalEarnings: 75
    },
    {
      id: '5',
      name: 'Deep',
      email: 'N/A',
      phone: '+9* *******570',
      orders: 0,
      rating: null,
      status: 'active',
      joinedDate: '25 Aug 2025',
      serviceType: 'car_driver',
      isOnline: false,
      totalEarnings: 0
    }
  ])

  const [activeTab, setActiveTab] = useState<'active' | 'blocked' | 'deleted' | 'expired'>('active')
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedDriver, setSelectedDriver] = useState<Driver | null>(null)

  const filteredDrivers = drivers.filter(driver => {
    const matchesTab = driver.status === activeTab
    const matchesSearch = driver.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         driver.phone.includes(searchTerm)
    return matchesTab && matchesSearch
  })

  const getServiceTypeIcon = (serviceType: string) => {
    return serviceType === 'car_driver' ? '🚗' : '🏍️'
  }

  const getServiceTypeLabel = (serviceType: string) => {
    return serviceType === 'car_driver' ? 'Car Driver' : 'Boda Rider'
  }

  const DriverDetailsModal = ({ driver, onClose }: { driver: Driver, onClose: () => void }) => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Driver Details</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            ×
          </button>
        </div>
        
        <div className="space-y-6">
          <div className="flex items-start space-x-4">
            <div className="w-20 h-20 bg-gray-300 rounded-lg flex items-center justify-center">
              <User className="w-8 h-8 text-gray-600" />
            </div>
            <div className="flex-1">
              <h4 className="text-xl font-semibold text-gray-900">{driver.name}</h4>
              <p className="text-sm text-gray-600">Joined on: {driver.joinedDate}</p>
              <div className="flex items-center mt-2 space-x-4">
                <span className="text-sm text-gray-600">Orders: {driver.orders}</span>
                <span className="text-sm text-gray-600">Earnings: ${driver.totalEarnings}</span>
                <span className={`inline-block px-2 py-1 rounded-full text-xs font-medium ${
                  driver.isOnline ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                }`}>
                  {driver.isOnline ? 'Online' : 'Offline'}
                </span>
              </div>
            </div>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h5 className="font-medium text-gray-900 mb-3">Driver Information</h5>
              <div className="space-y-2">
                <div>
                  <span className="text-sm font-medium text-gray-700">Name:</span>
                  <p className="text-gray-900">{driver.name}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Email:</span>
                  <p className="text-gray-900">{driver.email}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Phone:</span>
                  <p className="text-gray-900">{driver.phone}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Service Type:</span>
                  <p className="text-gray-900 flex items-center">
                    <span className="mr-2">{getServiceTypeIcon(driver.serviceType)}</span>
                    {getServiceTypeLabel(driver.serviceType)}
                  </p>
                </div>
              </div>
            </div>
            
            <div>
              <h5 className="font-medium text-gray-900 mb-3">Performance</h5>
              <div className="space-y-2">
                <div>
                  <span className="text-sm font-medium text-gray-700">Total Orders:</span>
                  <p className="text-gray-900">{driver.orders}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Rating:</span>
                  <p className="text-gray-900">
                    {driver.rating ? (
                      <div className="flex items-center">
                        <Star className="w-4 h-4 text-yellow-400 fill-current" />
                        <span className="ml-1">{driver.rating}</span>
                      </div>
                    ) : (
                      'N/A'
                    )}
                  </p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Total Earnings:</span>
                  <p className="text-gray-900">${driver.totalEarnings}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Status:</span>
                  <p className="text-gray-900 capitalize">{driver.status}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Drivers</h1>
        <p className="text-gray-600 mt-1">Manage driver accounts and information</p>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          {[
            { key: 'active', label: 'Active' },
            { key: 'blocked', label: 'Blocked' },
            { key: 'deleted', label: 'Deleted' },
            { key: 'expired', label: 'Expired' }
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
                  Orders
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ratings
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Action
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredDrivers.map((driver, index) => (
                <tr key={driver.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center mr-3">
                        <span className="text-sm">{getServiceTypeIcon(driver.serviceType)}</span>
                      </div>
                      <span className="text-sm font-medium text-gray-900">{driver.name}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {driver.email}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {driver.phone}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {driver.orders}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {driver.rating ? (
                      <div className="flex items-center">
                        <Star className="w-4 h-4 text-yellow-400 fill-current" />
                        <span className="ml-1">{driver.rating}</span>
                      </div>
                    ) : (
                      <span className="text-gray-400">N/A</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button
                      onClick={() => setSelectedDriver(driver)}
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

      {/* Driver Details Modal */}
      {selectedDriver && (
        <DriverDetailsModal 
          driver={selectedDriver} 
          onClose={() => setSelectedDriver(null)} 
        />
      )}
    </div>
  )
}
