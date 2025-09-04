import { useState } from 'react'
import { Star, Plus, Edit, Trash2, Search } from 'lucide-react'
import { useNavigate } from 'react-router-dom'

export default function QuickPicks() {
  const navigate = useNavigate()
  const [searchTerm, setSearchTerm] = useState('')
  const [quickPicks] = useState([
    {
      id: 1,
      name: 'Pizza Margherita',
      restaurant: 'Mario\'s Pizza',
      category: 'Italian',
      price: 15.99,
      rating: 4.8,
      featured: true
    },
    {
      id: 2,
      name: 'Chicken Burger',
      restaurant: 'Burger Palace',
      category: 'Fast Food',
      price: 12.50,
      rating: 4.5,
      featured: true
    },
    {
      id: 3,
      name: 'Sushi Roll',
      restaurant: 'Tokyo Sushi',
      category: 'Japanese',
      price: 18.99,
      rating: 4.9,
      featured: false
    }
  ])

  const filteredPicks = quickPicks.filter(pick =>
    pick.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    pick.restaurant.toLowerCase().includes(searchTerm.toLowerCase())
  )

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Quick Picks</h1>
          <p className="text-gray-600 mt-1">Manage featured items and quick picks</p>
        </div>
        <button 
          onClick={() => navigate('/quick-picks/new')}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <Plus className="w-4 h-4 mr-2" />
          Add Quick Pick
        </button>
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
          <div key={pick.id} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex justify-between items-start mb-4">
              <div className="flex items-center">
                {pick.featured && (
                  <Star className="w-5 h-5 text-yellow-500 fill-current mr-2" />
                )}
                <h3 className="text-lg font-semibold text-gray-900">{pick.name}</h3>
              </div>
                                    <div className="flex space-x-2">
                        <button 
                          onClick={() => navigate(`/quick-picks/${pick.id}/edit`)}
                          className="p-1 text-gray-400 hover:text-pink-500"
                        >
                          <Edit className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => {
                            if (window.confirm('Are you sure you want to delete this quick pick?')) {
                              console.log('Deleting quick pick:', pick.id)
                            }
                          }}
                          className="p-1 text-gray-400 hover:text-red-500"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
            </div>
            
            <div className="space-y-2">
              <p className="text-sm text-gray-600">
                <span className="font-medium">Restaurant:</span> {pick.restaurant}
              </p>
              <p className="text-sm text-gray-600">
                <span className="font-medium">Category:</span> {pick.category}
              </p>
              <p className="text-sm text-gray-600">
                <span className="font-medium">Price:</span> ${pick.price}
              </p>
              <div className="flex items-center">
                <Star className="w-4 h-4 text-yellow-500 fill-current mr-1" />
                <span className="text-sm text-gray-600">{pick.rating}</span>
              </div>
            </div>
            
            <div className="mt-4 pt-4 border-t border-gray-200">
              <button
                className={`w-full py-2 px-4 rounded-lg text-sm font-medium transition-colors ${
                  pick.featured
                    ? 'bg-yellow-100 text-yellow-800 hover:bg-yellow-200'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {pick.featured ? 'Featured' : 'Make Featured'}
              </button>
            </div>
          </div>
        ))}
      </div>

      {filteredPicks.length === 0 && (
        <div className="text-center py-12">
          <Star className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No quick picks found</h3>
          <p className="text-gray-600">Try adjusting your search terms or add new quick picks.</p>
        </div>
      )}
    </div>
  )
}