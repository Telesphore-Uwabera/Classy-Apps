import { useState, useEffect } from 'react'
import { Building2, Check, X, Eye, Search, RefreshCw } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'
import { COLLECTIONS } from '../config/firebase'

interface RestaurantRequest {
  id: string
  restaurantName: string
  ownerName: string
  email: string
  phone: string
  address: string
  cuisine: string
  status: string
  submittedDate: string
  documents: string[]
}

export default function RestaurantsRequested() {
  const navigate = useNavigate()
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [requests, setRequests] = useState<RestaurantRequest[]>([])
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    loadPendingRestaurants()
  }, [])

  const loadPendingRestaurants = async () => {
    try {
      setLoading(true)
      
      // Filter for pending restaurants ONLY (not vendors)
      const allRestaurants = await firebaseService.getCollection(COLLECTIONS.RESTAURANTS).catch(() => [])
      
      // Only filter restaurants collection for pending restaurants
      const pendingRestaurants = allRestaurants.filter(restaurant => 
        restaurant.status === 'pending' || 
        restaurant.status === 'offline' || // Firebase uses 'offline' for pending
        (restaurant.status !== 'active' && restaurant.status !== 'approved' && restaurant.is_active !== true)
      )
      
      const restaurantsWithDetails = pendingRestaurants.map((restaurant: any) => ({
        id: restaurant.id,
        restaurantName: restaurant.name || restaurant.businessName || 'Unknown Restaurant',
        ownerName: restaurant.ownerName || restaurant.email || 'Unknown Owner',
        email: restaurant.email || restaurant.ownerEmail || 'No email',
        phone: restaurant.phone || 'No phone',
        address: restaurant.address || 'No address',
        cuisine: restaurant.cuisine || restaurant.category_id || 'Not specified',
        status: restaurant.status || 'pending',
        submittedDate: restaurant.created_at?.toDate?.()?.toLocaleDateString() || 
                      restaurant.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
        documents: restaurant.documents || []
      }))
      
      setRequests(restaurantsWithDetails)
    } catch (error) {
      console.error('Error loading pending restaurants:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = async (restaurantId: string) => {
    try {
      await firebaseService.updateVendorStatus(restaurantId, 'active')
      setRequests(prev => prev.filter(request => request.id !== restaurantId))
    } catch (error) {
      console.error('Error approving restaurant:', error)
    }
  }

  const handleReject = async (restaurantId: string) => {
    try {
      await firebaseService.updateVendorStatus(restaurantId, 'blocked')
      setRequests(prev => prev.filter(request => request.id !== restaurantId))
    } catch (error) {
      console.error('Error rejecting restaurant:', error)
    }
  }

  const filteredRequests = requests.filter(request => {
    const matchesSearch = request.restaurantName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         request.ownerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         request.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         request.address.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === 'all' || request.status === statusFilter
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
          <h1 className="text-3xl font-bold text-gray-900">Restaurant Requests</h1>
          <p className="text-gray-600 mt-1">Review and approve pending restaurant applications from Firebase</p>
        </div>
        <button 
          onClick={loadPendingRestaurants}
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
              placeholder="Search restaurants..."
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

      {/* Requests Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Restaurant
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Owner
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Contact
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cuisine
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Submitted Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredRequests.map((request) => (
                <tr key={request.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10">
                        <div className="h-10 w-10 rounded-full bg-pink-100 flex items-center justify-center">
                          <Building2 className="w-5 h-5 text-pink-600" />
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{request.restaurantName}</div>
                        <div className="text-sm text-gray-500">{request.address}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{request.ownerName}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{request.email}</div>
                    <div className="text-sm text-gray-500">{request.phone}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      {request.cuisine}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {request.submittedDate}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button 
                        onClick={() => navigate(`/restaurants/${request.id}`)}
                        className="text-blue-600 hover:text-blue-900"
                        title="View Details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button 
                        onClick={() => handleApprove(request.id)}
                        className="text-green-600 hover:text-green-900"
                        title="Approve Restaurant"
                      >
                        <Check className="w-4 h-4" />
                      </button>
                      <button 
                        onClick={() => handleReject(request.id)}
                        className="text-red-600 hover:text-red-900"
                        title="Reject Restaurant"
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
        
        {filteredRequests.length === 0 && (
          <div className="text-center py-12">
            <div className="text-gray-500">No pending restaurant requests found</div>
          </div>
        )}
      </div>
    </div>
  )
}