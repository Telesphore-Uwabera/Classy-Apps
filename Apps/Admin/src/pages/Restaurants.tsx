import { useState, useEffect } from 'react'
import { Search, Eye, Building2, Phone, Star, RefreshCw, CheckCircle, XCircle, X } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'
import { COLLECTIONS } from '../config/firebase'

interface Restaurant {
  id: string
  name: string
  phone: string
  totalOrders: number
  rating: number | null
  status: 'active' | 'blocked' | 'deleted'
  joinedDate: string
  address: string
  ownerName: string
  ownerEmail: string
  ownerPhone: string
  bankAccount: string
}

export default function Restaurants() {
  const [restaurants, setRestaurants] = useState<Restaurant[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [selectedRestaurant, setSelectedRestaurant] = useState<Restaurant | null>(null)
  const [showRestaurantModal, setShowRestaurantModal] = useState(false)

  useEffect(() => {
    loadRestaurants()
  }, [])

  const loadRestaurants = async () => {
    try {
      setLoading(true)
      
      // Filter for active/approved restaurants ONLY (not vendors)
      const allRestaurants = await firebaseService.getCollection(COLLECTIONS.RESTAURANTS).catch(() => [])
      
      console.log('🔍 Debug Restaurants Data:')
      console.log('All restaurants from restaurants collection:', allRestaurants)
      
      // Only filter restaurants collection for active/approved restaurants
      const restaurantsData = allRestaurants.filter(restaurant => 
        restaurant.status === 'active' || 
        restaurant.status === 'approved' || 
        (restaurant.is_active === true && !restaurant.status) // Only if explicitly active
      )
      
      console.log('Filtered active restaurants:', restaurantsData)
      
      // Get orders for each restaurant to count their orders
      const restaurantsWithOrders = await Promise.all(
        restaurantsData.map(async (restaurant: any) => {
          const restaurantOrders = await firebaseService.queryCollection('orders', [
            { field: 'restaurantId', operator: '==', value: restaurant.id }
          ])
          
          return {
            id: restaurant.id,
            name: restaurant.name || restaurant.businessName || 'Unknown Restaurant',
            phone: restaurant.phone || 'No phone',
            totalOrders: restaurantOrders.length,
            rating: restaurant.rating || null,
            status: restaurant.status || (restaurant.is_active ? 'active' : 'inactive'),
            joinedDate: restaurant.created_at?.toDate?.()?.toLocaleDateString() || 
                       restaurant.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
            address: restaurant.address || 'No address',
            ownerName: restaurant.ownerName || restaurant.email || 'Unknown Owner',
            ownerEmail: restaurant.email || restaurant.ownerEmail || 'No email',
            ownerPhone: restaurant.ownerPhone || restaurant.phone || 'No phone',
            bankAccount: restaurant.bankAccount || 'No account'
          }
        })
      )
      
      setRestaurants(restaurantsWithOrders)
    } catch (error) {
      console.error('Error loading restaurants:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleStatusChange = async (restaurantId: string, newStatus: string) => {
    try {
      await firebaseService.updateVendorStatus(restaurantId, newStatus)
      setRestaurants(prev => 
        prev.map(restaurant => 
          restaurant.id === restaurantId 
            ? { ...restaurant, status: newStatus as 'active' | 'blocked' | 'deleted' }
            : restaurant
        )
      )
    } catch (error) {
      console.error('Error updating restaurant status:', error)
    }
  }

  const handleViewRestaurant = (restaurant: Restaurant) => {
    setSelectedRestaurant(restaurant)
    setShowRestaurantModal(true)
  }

  const filteredRestaurants = restaurants.filter(restaurant => {
    const matchesSearch = restaurant.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         restaurant.ownerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         restaurant.phone.includes(searchTerm)
    const matchesStatus = statusFilter === 'all' || restaurant.status === statusFilter
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
        <h1 className="text-3xl font-bold text-gray-900">Restaurants</h1>
          <p className="text-gray-600 mt-1">Manage restaurant accounts from Firebase</p>
      </div>
            <button
          onClick={loadRestaurants}
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
            <option value="all">All Status</option>
            <option value="pending">Pending Approval</option>
            <option value="active">Active</option>
            <option value="blocked">Blocked</option>
            <option value="deleted">Deleted</option>
          </select>
        </div>
      </div>

      {/* Restaurants Table */}
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
                  Orders
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Rating
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Joined
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredRestaurants.map((restaurant) => (
                <tr key={restaurant.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10">
                        <div className="h-10 w-10 rounded-full bg-pink-100 flex items-center justify-center">
                          <Building2 className="w-5 h-5 text-pink-600" />
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{restaurant.name}</div>
                        <div className="text-sm text-gray-500">{restaurant.address}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{restaurant.ownerName}</div>
                    <div className="text-sm text-gray-500">{restaurant.ownerEmail}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{restaurant.phone}</div>
                    <div className="text-sm text-gray-500">{restaurant.ownerPhone}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      {restaurant.totalOrders} orders
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {restaurant.rating ? (
                      <div className="flex items-center">
                        <Star className="w-4 h-4 text-yellow-400 fill-current" />
                        <span className="ml-1 text-sm text-gray-900">{restaurant.rating}</span>
                      </div>
                    ) : (
                      <span className="text-sm text-gray-500">No rating</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      restaurant.status === 'active' 
                        ? 'bg-green-100 text-green-800'
                        : restaurant.status === 'blocked'
                        ? 'bg-red-100 text-red-800'
                        : restaurant.status === 'pending'
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {restaurant.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {restaurant.joinedDate}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                    <button
                        onClick={() => handleViewRestaurant(restaurant)}
                        className="text-blue-600 hover:text-blue-900"
                        title="View Restaurant Details"
                    >
                      <Eye className="w-4 h-4" />
                    </button>
                      {restaurant.status === 'active' ? (
                        <button 
                          onClick={() => handleStatusChange(restaurant.id, 'blocked')}
                          className="text-red-600 hover:text-red-900"
                          title="Block Restaurant"
                        >
                          <XCircle className="w-4 h-4" />
                        </button>
                      ) : (
                        <button 
                          onClick={() => handleStatusChange(restaurant.id, 'active')}
                          className="text-green-600 hover:text-green-900"
                          title="Unblock Restaurant"
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
        
        {filteredRestaurants.length === 0 && (
          <div className="text-center py-12">
            <div className="text-gray-500">No restaurants found</div>
          </div>
        )}
      </div>

      {/* Restaurant Details Modal */}
      {showRestaurantModal && selectedRestaurant && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4">
            <div className="flex justify-between items-center p-6 border-b border-gray-200">
              <h3 className="text-lg font-semibold text-gray-900">Restaurant Details</h3>
              <button
                onClick={() => setShowRestaurantModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="p-6 space-y-6">
              <div className="flex items-center space-x-4">
                <div className="h-12 w-12 rounded-full bg-pink-100 flex items-center justify-center">
                  <Building2 className="w-6 h-6 text-pink-600" />
                </div>
                <div>
                  <h4 className="text-lg font-medium text-gray-900">{selectedRestaurant.name}</h4>
                  <p className="text-sm text-gray-500">{selectedRestaurant.address}</p>
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Owner Name</label>
                    <p className="text-sm text-gray-900">{selectedRestaurant.ownerName}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Owner Email</label>
                    <p className="text-sm text-gray-900">{selectedRestaurant.ownerEmail}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Owner Phone</label>
                    <p className="text-sm text-gray-900">{selectedRestaurant.ownerPhone}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Restaurant Phone</label>
                    <p className="text-sm text-gray-900">{selectedRestaurant.phone}</p>
                  </div>
                </div>
                
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Total Orders</label>
                    <p className="text-sm text-gray-900">{selectedRestaurant.totalOrders} orders</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Rating</label>
                    <p className="text-sm text-gray-900">
                      {selectedRestaurant.rating ? `${selectedRestaurant.rating} ⭐` : 'No rating'}
                    </p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Status</label>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      selectedRestaurant.status === 'active' 
                        ? 'bg-green-100 text-green-800'
                        : selectedRestaurant.status === 'blocked'
                        ? 'bg-red-100 text-red-800'
                        : selectedRestaurant.status === 'pending'
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {selectedRestaurant.status}
                    </span>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Joined</label>
                    <p className="text-sm text-gray-900">{selectedRestaurant.joinedDate}</p>
                  </div>
                </div>
              </div>
              
              <div>
                <label className="text-sm font-medium text-gray-500">Bank Account</label>
                <p className="text-sm text-gray-900">{selectedRestaurant.bankAccount}</p>
              </div>
            </div>
            
            <div className="flex justify-end space-x-3 p-6 border-t border-gray-200">
              <button
                onClick={() => setShowRestaurantModal(false)}
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
