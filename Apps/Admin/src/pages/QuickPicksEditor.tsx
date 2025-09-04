import { useState } from 'react'
import { ArrowLeft, Save, Star } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'

export default function QuickPicksEditor() {
  const navigate = useNavigate()
  const { id } = useParams()
  
  // Mock quick pick data - in real app, fetch based on id
  const quickPickData = {
    '1': {
      name: 'Pizza Margherita',
      restaurant: 'Mario\'s Pizza',
      category: 'Italian',
      price: 15.99,
      rating: 4.8,
      featured: true
    },
    '2': {
      name: 'Chicken Burger',
      restaurant: 'Burger Palace',
      category: 'Fast Food',
      price: 12.50,
      rating: 4.5,
      featured: true
    },
    '3': {
      name: 'Sushi Roll',
      restaurant: 'Tokyo Sushi',
      category: 'Japanese',
      price: 18.99,
      rating: 4.9,
      featured: false
    }
  }

  const currentPick = quickPickData[id as keyof typeof quickPickData] || {
    name: '',
    restaurant: '',
    category: '',
    price: 0,
    rating: 0,
    featured: false
  }

  const [name, setName] = useState(currentPick.name)
  const [restaurant, setRestaurant] = useState(currentPick.restaurant)
  const [category, setCategory] = useState(currentPick.category)
  const [price, setPrice] = useState(currentPick.price.toString())
  const [rating, setRating] = useState(currentPick.rating.toString())
  const [featured, setFeatured] = useState(currentPick.featured)

  const handleSave = () => {
    // Handle save logic
    console.log('Saving quick pick:', { name, restaurant, category, price, rating, featured })
    // Navigate back to quick picks
    navigate('/quick-picks')
  }

  const isNewPick = !id || id === 'new'

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <button
            onClick={() => navigate('/quick-picks')}
            className="flex items-center text-gray-600 hover:text-gray-900"
          >
            <ArrowLeft className="w-5 h-5 mr-2" />
            Back
          </button>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              {isNewPick ? 'Add New Quick Pick' : 'Edit Quick Pick'}
            </h1>
            <p className="text-gray-600 mt-1">
              {isNewPick ? 'Create a new featured item' : 'Update quick pick information'}
            </p>
          </div>
        </div>
        <button
          onClick={handleSave}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <Save className="w-4 h-4 mr-2" />
          {isNewPick ? 'Create Quick Pick' : 'Save Changes'}
        </button>
      </div>

      {/* Quick Pick Form */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Left Column - Form Fields */}
          <div className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Item Name *
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                placeholder="Enter item name"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Restaurant *
              </label>
              <input
                type="text"
                value={restaurant}
                onChange={(e) => setRestaurant(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                placeholder="Enter restaurant name"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Category *
              </label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                required
              >
                <option value="">Select category</option>
                <option value="Italian">Italian</option>
                <option value="Fast Food">Fast Food</option>
                <option value="Japanese">Japanese</option>
                <option value="Chinese">Chinese</option>
                <option value="Indian">Indian</option>
                <option value="Mexican">Mexican</option>
                <option value="Desserts">Desserts</option>
                <option value="Beverages">Beverages</option>
              </select>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Price ($) *
                </label>
                <input
                  type="number"
                  step="0.01"
                  value={price}
                  onChange={(e) => setPrice(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                  placeholder="0.00"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Rating *
                </label>
                <input
                  type="number"
                  step="0.1"
                  min="0"
                  max="5"
                  value={rating}
                  onChange={(e) => setRating(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                  placeholder="4.5"
                  required
                />
              </div>
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="featured"
                checked={featured}
                onChange={(e) => setFeatured(e.target.checked)}
                className="h-4 w-4 text-pink-600 focus:ring-pink-500 border-gray-300 rounded"
              />
              <label htmlFor="featured" className="ml-2 block text-sm text-gray-900">
                <div className="flex items-center">
                  <Star className="w-4 h-4 text-yellow-500 mr-1" />
                  Mark as Featured
                </div>
              </label>
            </div>
          </div>

          {/* Right Column - Preview */}
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Preview</h3>
              <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
                <div className="flex justify-between items-start mb-4">
                  <div className="flex items-center">
                    {featured && (
                      <Star className="w-5 h-5 text-yellow-500 fill-current mr-2" />
                    )}
                    <h3 className="text-lg font-semibold text-gray-900">
                      {name || 'Item Name'}
                    </h3>
                  </div>
                </div>
                
                <div className="space-y-2">
                  <p className="text-sm text-gray-600">
                    <span className="font-medium">Restaurant:</span> {restaurant || 'Restaurant Name'}
                  </p>
                  <p className="text-sm text-gray-600">
                    <span className="font-medium">Category:</span> {category || 'Category'}
                  </p>
                  <p className="text-sm text-gray-600">
                    <span className="font-medium">Price:</span> ${price || '0.00'}
                  </p>
                  <div className="flex items-center">
                    <Star className="w-4 h-4 text-yellow-500 fill-current mr-1" />
                    <span className="text-sm text-gray-600">{rating || '0.0'}</span>
                  </div>
                </div>
                
                <div className="mt-4 pt-4 border-t border-gray-200">
                  <button
                    className={`w-full py-2 px-4 rounded-lg text-sm font-medium transition-colors ${
                      featured
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-gray-100 text-gray-700'
                    }`}
                  >
                    {featured ? 'Featured' : 'Not Featured'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
