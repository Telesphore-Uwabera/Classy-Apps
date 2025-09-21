import { useState, useEffect } from 'react'
import { Car, Eye, Search, Check, X, RefreshCw } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'

interface DriverRequest {
  id: string
  name: string
  email: string
  phone: string
  vehicle: string
  status: string
  requestedDate: string
  location: string
  serviceType: string
}

export default function DriversRequested() {
  const navigate = useNavigate()
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('pending')
  const [drivers, setDrivers] = useState<DriverRequest[]>([])
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    loadPendingDrivers()
  }, [])

  const loadPendingDrivers = async () => {
    try {
      setLoading(true)
      
      // Filter for pending drivers
      const allDrivers = await firebaseService.getCollection('drivers')
      const pendingDrivers = allDrivers.filter(driver => 
        driver.status === 'pending' || 
        (driver.status !== 'active' && driver.status !== 'approved' && driver.is_active !== true)
      )
      
      const driversWithDetails = pendingDrivers.map((driver: any) => ({
        id: driver.id,
        name: driver.name || 'Unknown Driver',
        email: driver.email || 'No email',
        phone: driver.phone || 'No phone',
        vehicle: driver.serviceType === 'car_driver' ? 'Car' : 'Motorcycle',
        status: driver.status || 'pending',
        requestedDate: driver.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
        location: driver.location || 'No location', // Keep as is, we'll handle rendering in JSX
        serviceType: driver.serviceType || 'car_driver'
      }))
      
      setDrivers(driversWithDetails)
    } catch (error) {
      console.error('Error loading pending drivers:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = async (driverId: string) => {
    try {
      await firebaseService.updateDriverStatus(driverId, 'active')
      setDrivers(prev => prev.filter(driver => driver.id !== driverId))
    } catch (error) {
      console.error('Error approving driver:', error)
    }
  }

  const handleReject = async (driverId: string) => {
    try {
      await firebaseService.updateDriverStatus(driverId, 'blocked')
      setDrivers(prev => prev.filter(driver => driver.id !== driverId))
    } catch (error) {
      console.error('Error rejecting driver:', error)
    }
  }

  const filteredDrivers = drivers.filter(driver => {
    const matchesSearch = driver.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         driver.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         driver.phone.includes(searchTerm) ||
                         driver.location.toLowerCase().includes(searchTerm.toLowerCase())
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
          <h1 className="text-3xl font-bold text-gray-900">Driver Requests</h1>
          <p className="text-gray-600 mt-1">Review and approve pending driver applications from Firebase</p>
      </div>
        <button
          onClick={loadPendingDrivers}
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
            <option value="pending">Pending</option>
            <option value="all">All Status</option>
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
                  Vehicle
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Location
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Requested Date
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
                          <Car className="w-5 h-5 text-blue-600" />
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
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      {driver.vehicle}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {typeof driver.location === 'object' && driver.location 
                        ? `${driver.location.latitude?.toFixed(4) || 'N/A'}, ${driver.location.longitude?.toFixed(4) || 'N/A'}`
                        : driver.location || 'No location'
                      }
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {driver.requestedDate}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button 
                        onClick={() => navigate(`/drivers/${driver.id}`)}
                        className="text-blue-600 hover:text-blue-900"
                        title="View Details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button 
                        onClick={() => handleApprove(driver.id)}
                        className="text-green-600 hover:text-green-900"
                        title="Approve Driver"
                      >
                            <Check className="w-4 h-4" />
                          </button>
                      <button 
                        onClick={() => handleReject(driver.id)}
                        className="text-red-600 hover:text-red-900"
                        title="Reject Driver"
                      >
                            <X className="w-4 h-4" />
                          </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
      </div>

      {filteredDrivers.length === 0 && (
        <div className="text-center py-12">
            <div className="text-gray-500">No pending driver requests found</div>
        </div>
      )}
      </div>
    </div>
  )
}