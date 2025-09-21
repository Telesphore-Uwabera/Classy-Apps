import { useState, useEffect } from 'react'
import { Star, Plus, Edit, Trash2, Search, RefreshCw } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'

interface QuickPick {
  id: string
  name: string
  restaurant: string
  category: string
  price: number
  rating: number
  featured: boolean
  image?: string
}

export default function QuickPicks() {
  const navigate = useNavigate()
  const [searchTerm, setSearchTerm] = useState('')
  const [quickPicks, setQuickPicks] = useState<QuickPick[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadQuickPicks()
  }, [])

  const loadQuickPicks = async () => {
    try {
      setLoading(true)
      const products = await firebaseService.getProducts()
      
      // Get vendor details for each product
      const picksWithDetails = await Promise.all(
        products.slice(0, 10).map(async (product: any) => {
          let restaurantName = 'Unknown Restaurant'
          
          try {
            if (product.vendorId) {
              const vendor = await firebaseService.getDocument('vendors', product.vendorId)
              restaurantName = vendor.name || 'Unknown Restaurant'
            }
          } catch (error) {
            console.error('Error loading vendor details:', error)
          }
          
          return {
            id: product.id,
            name: product.name || 'Unknown Product',
            restaurant: restaurantName,
            category: product.category || 'General',
            price: product.price || 0,
            rating: product.rating || 0,
            featured: product.featured || false,
            image: product.image || ''
          }
        })
      )
      
      setQuickPicks(picksWithDetails)
    } catch (error) {
      console.error('Error loading quick picks:', error)
    } finally {
      setLoading(false)
    }
  }

  const toggleFeatured = async (pickId: string, currentFeatured: boolean) => {
    try {
      await firebaseService.updateDocument('products', pickId, {
        featured: !currentFeatured
      })
      
      setQuickPicks(prev => 
        prev.map(pick => 
          pick.id === pickId 
            ? { ...pick, featured: !currentFeatured }
            : pick
        )
      )
    } catch (error) {
      console.error('Error updating featured status:', error)
    }
  }

  const deleteQuickPick = async (pickId: string) => {
    if (window.confirm('Are you sure you want to delete this quick pick?')) {
      try {
        await firebaseService.deleteDocument('products', pickId)
        setQuickPicks(prev => prev.filter(pick => pick.id !== pickId))
      } catch (error) {
        console.error('Error deleting quick pick:', error)
      }
    }
  }

  const filteredPicks = quickPicks.filter(pick =>
    pick.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    pick.restaurant.toLowerCase().includes(searchTerm.toLowerCase())
  )

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
          <h1 className="text-3xl font-bold text-gray-900">Quick Picks</h1>
          <p className="text-gray-600 mt-1">Manage featured items and quick picks from Firebase</p>
        </div>
        <div className="flex space-x-2">
          <button 
            onClick={loadQuickPicks}
            className="flex items-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
          >
            <RefreshCw className="w-4 h-4 mr-2" />
            Refresh
          </button>
        <button 
            onClick={() => navigate('/quick-picks/add')}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <Plus className="w-4 h-4 mr-2" />
          Add Quick Pick
        </button>
        </div>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search quick picks..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
        />
      </div>

      {/* Quick Picks Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredPicks.map((pick) => (
          <div key={pick.id} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start mb-4">
              <div className="flex items-center">
                {pick.featured && <Star className="w-4 h-4 text-yellow-500 fill-current mr-1" />}
                <h3 className="text-lg font-semibold text-gray-900">{pick.name}</h3>
              </div>
                                    <div className="flex space-x-2">
                        <button 
                          onClick={() => navigate(`/quick-picks/${pick.id}/edit`)}
                  className="text-gray-400 hover:text-blue-600 transition-colors"
                        >
                          <Edit className="w-4 h-4" />
                        </button>
                        <button 
                  onClick={() => deleteQuickPick(pick.id)}
                  className="text-gray-400 hover:text-red-600 transition-colors"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
            </div>
            
            <div className="space-y-2 mb-4">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Restaurant:</span>
                <span className="text-gray-900">{pick.restaurant}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Category:</span>
                <span className="text-gray-900">{pick.category}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Price:</span>
                <span className="text-gray-900">${pick.price}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Rating:</span>
              <div className="flex items-center">
                  <Star className="w-3 h-3 text-yellow-400 fill-current mr-1" />
                  <span className="text-gray-900">{pick.rating}</span>
                </div>
              </div>
            </div>
            
              <button
              onClick={() => toggleFeatured(pick.id, pick.featured)}
                className={`w-full py-2 px-4 rounded-lg text-sm font-medium transition-colors ${
                  pick.featured
                    ? 'bg-yellow-100 text-yellow-800 hover:bg-yellow-200'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                {pick.featured ? 'Featured' : 'Make Featured'}
              </button>
          </div>
        ))}
      </div>

      {filteredPicks.length === 0 && (
        <div className="text-center py-12">
          <div className="text-gray-500">No quick picks found</div>
        </div>
      )}
    </div>
  )
}