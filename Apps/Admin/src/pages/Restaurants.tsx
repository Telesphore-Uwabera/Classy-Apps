import { useState, useEffect } from 'react'
import { Search, Eye, Building2, Phone, Star } from 'lucide-react'

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
  const [restaurants, setRestaurants] = useState<Restaurant[]>([
    {
      id: '1',
      name: 'Anjappar Multicuisine Restauran',
      phone: '+9********311',
      totalOrders: 35,
      rating: 5,
      status: 'active',
      joinedDate: '22 Jul 2025',
      address: 'QH8X+3HM, Kotwali, Kotwali, Bhaga chowk, Badkuwa',
      ownerName: 'Ritik Rathod',
      ownerEmail: 'ritikr361@gmail.com',
      ownerPhone: '+918959384509',
      bankAccount: '000123456'
    },
    {
      id: '2',
      name: 'Prem restaurant',
      phone: '+9********386',
      totalOrders: 1,
      rating: null,
      status: 'active',
      joinedDate: '15 Aug 2025',
      address: 'Industrial Area, Sector 75',
      ownerName: 'Prem Kumar',
      ownerEmail: 'prem@example.com',
      ownerPhone: '+919876543210',
      bankAccount: '000123457'
    },
    {
      id: '3',
      name: 'nsjs',
      phone: '+9********544',
      totalOrders: 0,
      rating: null,
      status: 'active',
      joinedDate: '10 Aug 2025',
      address: 'City Center',
      ownerName: 'NSJS Owner',
      ownerEmail: 'nsjs@example.com',
      ownerPhone: '+919876543211',
      bankAccount: '000123458'
    },
    {
      id: '4',
      name: 'Pickle Corner',
      phone: '+9********992',
      totalOrders: 6,
      rating: null,
      status: 'active',
      joinedDate: '05 Aug 2025',
      address: 'Food Street',
      ownerName: 'Pickle Owner',
      ownerEmail: 'pickle@example.com',
      ownerPhone: '+919876543212',
      bankAccount: '000123459'
    },
    {
      id: '5',
      name: 'Pawanveg Delivery Service',
      phone: '+9********590',
      totalOrders: 10,
      rating: 5,
      status: 'active',
      joinedDate: '01 Aug 2025',
      address: 'Veg Market',
      ownerName: 'Pawan Veg',
      ownerEmail: 'pawan@example.com',
      ownerPhone: '+919876543213',
      bankAccount: '000123460'
    },
    {
      id: '6',
      name: 'pritam da dhabha',
      phone: '+9********436',
      totalOrders: 0,
      rating: null,
      status: 'active',
      joinedDate: '28 Jul 2025',
      address: 'Dhaba Street',
      ownerName: 'Pritam Singh',
      ownerEmail: 'pritam@example.com',
      ownerPhone: '+919876543214',
      bankAccount: '000123461'
    }
  ])

  const [activeTab, setActiveTab] = useState<'active' | 'blocked' | 'deleted'>('active')
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedRestaurant, setSelectedRestaurant] = useState<Restaurant | null>(null)

  const filteredRestaurants = restaurants.filter(restaurant => {
    const matchesTab = restaurant.status === activeTab
    const matchesSearch = restaurant.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         restaurant.phone.includes(searchTerm)
    return matchesTab && matchesSearch
  })

  const RestaurantDetailsModal = ({ restaurant, onClose }: { restaurant: Restaurant, onClose: () => void }) => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Restaurant Details</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            ×
          </button>
        </div>
        
        <div className="space-y-6">
          <div className="flex items-start space-x-4">
            <div className="w-20 h-20 bg-gray-300 rounded-lg flex items-center justify-center">
              <Building2 className="w-8 h-8 text-gray-600" />
            </div>
            <div className="flex-1">
              <h4 className="text-xl font-semibold text-gray-900">{restaurant.name}</h4>
              <p className="text-sm text-gray-600">Joined on: {restaurant.joinedDate}</p>
              <div className="flex items-center mt-2">
                <span className="text-sm text-gray-600">Total orders: {restaurant.totalOrders}</span>
                {restaurant.rating && (
                  <div className="flex items-center ml-4">
                    <Star className="w-4 h-4 text-yellow-400 fill-current" />
                    <span className="text-sm text-gray-600 ml-1">{restaurant.rating}</span>
                  </div>
                )}
              </div>
            </div>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h5 className="font-medium text-gray-900 mb-3">Restaurant Information</h5>
              <div className="space-y-2">
                <div>
                  <span className="text-sm font-medium text-gray-700">Name:</span>
                  <p className="text-gray-900">{restaurant.name}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Phone:</span>
                  <p className="text-gray-900">{restaurant.phone}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Address:</span>
                  <p className="text-gray-900">{restaurant.address}</p>
                </div>
              </div>
            </div>
            
            <div>
              <h5 className="font-medium text-gray-900 mb-3">Owner Details</h5>
              <div className="space-y-2">
                <div>
                  <span className="text-sm font-medium text-gray-700">Name:</span>
                  <p className="text-gray-900">{restaurant.ownerName}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Email:</span>
                  <p className="text-gray-900">{restaurant.ownerEmail}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Phone:</span>
                  <p className="text-gray-900">{restaurant.ownerPhone}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Bank Account:</span>
                  <p className="text-gray-900">{restaurant.bankAccount}</p>
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
        <h1 className="text-3xl font-bold text-gray-900">Restaurants</h1>
        <p className="text-gray-600 mt-1">Manage restaurant accounts and information</p>
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
            placeholder="Search by restaurant name or phone number"
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
                  Phone
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Total Orders
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
              {filteredRestaurants.map((restaurant, index) => (
                <tr key={restaurant.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center mr-3">
                        <Building2 className="w-4 h-4 text-gray-600" />
                      </div>
                      <span className="text-sm font-medium text-gray-900">{restaurant.name}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {restaurant.phone}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {restaurant.totalOrders}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {restaurant.rating ? (
                      <div className="flex items-center">
                        <Star className="w-4 h-4 text-yellow-400 fill-current" />
                        <span className="ml-1">{restaurant.rating}</span>
                      </div>
                    ) : (
                      <span className="text-gray-400">N/A</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button
                      onClick={() => setSelectedRestaurant(restaurant)}
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

      {/* Restaurant Details Modal */}
      {selectedRestaurant && (
        <RestaurantDetailsModal 
          restaurant={selectedRestaurant} 
          onClose={() => setSelectedRestaurant(null)} 
        />
      )}
    </div>
  )
}
