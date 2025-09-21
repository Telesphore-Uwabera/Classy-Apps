import { useState, useEffect } from 'react'
import { Search, Eye, Car, Phone, Star, User, RefreshCw, CheckCircle, XCircle, X } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'

interface Driver {
  id: string
  name: string
  email: string
  phone: string
  orders: number
  rating: number | null
  status: 'active' | 'blocked' | 'deleted' | 'expired' | 'pending'
  joinedDate: string
  serviceType: 'car_driver' | 'boda_rider'
  isOnline: boolean
  totalEarnings: number
}

export default function Drivers() {
  const [drivers, setDrivers] = useState<Driver[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [selectedDriver, setSelectedDriver] = useState<Driver | null>(null)
  const [showDriverModal, setShowDriverModal] = useState(false)

  useEffect(() => {
    loadDrivers()
  }, [])

  const loadDrivers = async () => {
    try {
      setLoading(true)
      
      // Filter for active/approved drivers
      const allDrivers = await firebaseService.getCollection('drivers')
      const driversData = allDrivers.filter(driver => 
        driver.status === 'active' || 
        driver.status === 'approved' || 
        (driver.is_active === true && !driver.status) // Only if explicitly active
      )
      
      // Get orders for each driver to count their orders
      const driversWithOrders = await Promise.all(
        driversData.map(async (driver: any) => {
          const driverOrders = await firebaseService.queryCollection('orders', [
            { field: 'driverId', operator: '==', value: driver.id }
          ])
          
          return {
            id: driver.id,
            name: driver.name || 'Unknown Driver',
            email: driver.email || 'No email',
            phone: driver.phone || 'No phone',
            orders: driverOrders.length,
            rating: driver.rating || null,
            status: driver.status || 'active',
            joinedDate: driver.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
            serviceType: driver.serviceType || 'car_driver',
            isOnline: driver.isOnline || false,
            totalEarnings: driver.totalEarnings || 0
          }
        })
      )
      
      setDrivers(driversWithOrders)
    } catch (error) {
      console.error('Error loading drivers:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleStatusChange = async (driverId: string, newStatus: string) => {
    try {
      await firebaseService.updateDriverStatus(driverId, newStatus)
      setDrivers(prev => 
        prev.map(driver => 
          driver.id === driverId 
            ? { ...driver, status: newStatus as 'active' | 'blocked' | 'deleted' | 'expired' | 'pending' }
            : driver
        )
      )
    } catch (error) {
      console.error('Error updating driver status:', error)
    }
  }

  const handleViewDriver = (driver: Driver) => {
    setSelectedDriver(driver)
    setShowDriverModal(true)
  }

  const filteredDrivers = drivers.filter(driver => {
    const matchesSearch = driver.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         driver.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         driver.phone.includes(searchTerm)
    const matchesStatus = statusFilter === 'all' || driver.status === statusFilter
    return matchesSearch && matchesStatus
  })

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
        <h1 className="text-3xl font-bold text-gray-900">Drivers</h1>
          <p className="text-gray-600 mt-1">Manage driver accounts from Firebase</p>
      </div>
            <button
          onClick={loadDrivers}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh
            </button>
      </div>

      {/* Search and Filter */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
              placeholder="Search drivers..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-transparent"
            />
          </div>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-transparent"
          >
            <option value="all">All Status</option>
            <option value="pending">Pending Approval</option>
            <option value="active">Active</option>
            <option value="blocked">Blocked</option>
            <option value="deleted">Deleted</option>
            <option value="expired">Expired</option>
          </select>
        </div>
      </div>

      {/* Drivers Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Driver
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Contact
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Service
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Orders
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Rating
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Online
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Earnings
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredDrivers.map((driver) => (
                <tr key={driver.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10">
                        <div className="h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center">
                          <User className="w-5 h-5 text-blue-600" />
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{driver.name}</div>
                        <div className="text-sm text-gray-500">ID: {driver.id}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{driver.email}</div>
                    <div className="text-sm text-gray-500">{driver.phone}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <Car className="w-4 h-4 text-gray-400 mr-1" />
                      <span className="text-sm text-gray-900 capitalize">
                        {driver.serviceType.replace('_', ' ')}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      {driver.orders} orders
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {driver.rating ? (
                      <div className="flex items-center">
                        <Star className="w-4 h-4 text-yellow-400 fill-current" />
                        <span className="ml-1 text-sm text-gray-900">{driver.rating}</span>
                      </div>
                    ) : (
                      <span className="text-sm text-gray-500">No rating</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      driver.status === 'active' 
                        ? 'bg-green-100 text-green-800'
                        : driver.status === 'blocked'
                        ? 'bg-red-100 text-red-800'
                        : driver.status === 'pending'
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {driver.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      driver.isOnline 
                        ? 'bg-green-100 text-green-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {driver.isOnline ? 'Online' : 'Offline'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    ${driver.totalEarnings}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                    <button
                        onClick={() => handleViewDriver(driver)}
                        className="text-blue-600 hover:text-blue-900"
                        title="View Driver Details"
                    >
                      <Eye className="w-4 h-4" />
                    </button>
                      {driver.status === 'active' ? (
                        <button 
                          onClick={() => handleStatusChange(driver.id, 'blocked')}
                          className="text-red-600 hover:text-red-900"
                          title="Block Driver"
                        >
                          <XCircle className="w-4 h-4" />
                        </button>
                      ) : (
                        <button 
                          onClick={() => handleStatusChange(driver.id, 'active')}
                          className="text-green-600 hover:text-green-900"
                          title="Unblock Driver"
                        >
                          <CheckCircle className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {filteredDrivers.length === 0 && (
          <div className="text-center py-12">
            <div className="text-gray-500">No drivers found</div>
          </div>
        )}
      </div>

      {/* Driver Details Modal */}
      {showDriverModal && selectedDriver && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4">
            <div className="flex justify-between items-center p-6 border-b border-gray-200">
              <h3 className="text-lg font-semibold text-gray-900">Driver Details</h3>
              <button
                onClick={() => setShowDriverModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="p-6 space-y-6">
              <div className="flex items-center space-x-4">
                <div className="h-12 w-12 rounded-full bg-pink-100 flex items-center justify-center">
                  <Car className="w-6 h-6 text-pink-600" />
                </div>
                <div>
                  <h4 className="text-lg font-medium text-gray-900">{selectedDriver.name}</h4>
                  <p className="text-sm text-gray-500">ID: {selectedDriver.id}</p>
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Email</label>
                    <p className="text-sm text-gray-900">{selectedDriver.email}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Phone</label>
                    <p className="text-sm text-gray-900">{selectedDriver.phone}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Service Type</label>
                    <p className="text-sm text-gray-900">
                      {selectedDriver.serviceType === 'car_driver' ? 'Car Driver' : 'Boda Rider'}
                    </p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Online Status</label>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      selectedDriver.isOnline 
                        ? 'bg-green-100 text-green-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {selectedDriver.isOnline ? 'Online' : 'Offline'}
                    </span>
                  </div>
                </div>
                
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Total Orders</label>
                    <p className="text-sm text-gray-900">{selectedDriver.totalOrders} orders</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Rating</label>
                    <p className="text-sm text-gray-900">★ {selectedDriver.rating}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Total Earnings</label>
                    <p className="text-sm text-gray-900 font-semibold">${selectedDriver.totalEarnings}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Status</label>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      selectedDriver.status === 'active' 
                        ? 'bg-green-100 text-green-800'
                        : selectedDriver.status === 'blocked'
                        ? 'bg-red-100 text-red-800'
                        : selectedDriver.status === 'pending'
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {selectedDriver.status}
                    </span>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="flex justify-end space-x-3 p-6 border-t border-gray-200">
              <button
                onClick={() => setShowDriverModal(false)}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}