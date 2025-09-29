import { useState, useEffect } from 'react'
import { ArrowLeft, Save, Star, RefreshCw } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'

interface QuickPickData {
  name: string
  restaurant: string
  category: string
  price: number
  rating: number
  featured: boolean
  description?: string
  image?: string
}

export default function QuickPicksEditor() {
  const navigate = useNavigate()
  const { id } = useParams()
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  
  const [quickPickData, setQuickPickData] = useState<QuickPickData>({
    name: '',
    restaurant: '',
    category: '',
    price: 0,
    rating: 0,
    featured: false,
    description: '',
    image: ''
  })

  useEffect(() => {
    if (id && id !== 'add') {
      loadQuickPick()
    } else {
      setLoading(false)
    }
  }, [id])

  const loadQuickPick = async () => {
    try {
      setLoading(true)
      const product = await firebaseService.getDocument('products', id!)
      
      if (product) {
        let restaurantName = 'Unknown Restaurant'
        
        try {
          if (product.vendorId) {
            const vendor = await firebaseService.getDocument('vendors', product.vendorId)
            restaurantName = vendor?.name || 'Unknown Restaurant'
          }
        } catch (error) {
          console.error('Error loading vendor details:', error)
        }
        
        setQuickPickData({
          name: product.name || '',
          restaurant: restaurantName,
          category: product.category || '',
          price: product.price || 0,
          rating: product.rating || 0,
          featured: product.featured || false,
          description: product.description || '',
          image: product.image || ''
        })
      }
    } catch (error) {
      console.error('Error loading quick pick:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    try {
      setSaving(true)
      
      if (id === 'add') {
        // Create new quick pick
        const newProduct = {
          ...quickPickData,
          createdAt: new Date(),
          updatedAt: new Date()
        }
        await firebaseService.addDocument('products', newProduct)
        alert('Quick pick created successfully!')
      } else {
        // Update existing quick pick
        const updatedProduct = {
          ...quickPickData,
          updatedAt: new Date()
        }
        await firebaseService.updateDocument('products', id!, updatedProduct)
        alert('Quick pick updated successfully!')
      }
      
    navigate('/quick-picks')
    } catch (error) {
      console.error('Error saving quick pick:', error)
      alert('Error saving quick pick')
    } finally {
      setSaving(false)
    }
  }

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
      <div className="flex items-center justify-between">
        <div className="flex items-center">
          <button
            onClick={() => navigate('/quick-picks')}
            className="flex items-center text-gray-600 hover:text-gray-900 mr-4"
          >
            <ArrowLeft className="w-4 h-4 mr-1" />
            Back to Quick Picks
          </button>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              {id === 'add' ? 'Add Quick Pick' : 'Edit Quick Pick'}
            </h1>
            <p className="text-gray-600 mt-1">
              {id === 'add' ? 'Create a new featured item' : 'Update quick pick details from Firebase'}
            </p>
          </div>
        </div>
        <button
          onClick={loadQuickPick}
          className="flex items-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh
        </button>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Product Name</label>
              <input
                type="text"
              value={quickPickData.name}
              onChange={(e) => setQuickPickData(prev => ({ ...prev, name: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              placeholder="Enter product name"
              />
            </div>

            <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Restaurant</label>
              <input
                type="text"
              value={quickPickData.restaurant}
              onChange={(e) => setQuickPickData(prev => ({ ...prev, restaurant: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                placeholder="Enter restaurant name"
              />
            </div>

            <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Category</label>
            <input
              type="text"
              value={quickPickData.category}
              onChange={(e) => setQuickPickData(prev => ({ ...prev, category: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              placeholder="Enter category"
            />
            </div>

              <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Price ($)</label>
                <input
                  type="number"
                  step="0.01"
              value={quickPickData.price}
              onChange={(e) => setQuickPickData(prev => ({ ...prev, price: parseFloat(e.target.value) || 0 }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              placeholder="Enter price"
                />
              </div>

              <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Rating</label>
                <input
                  type="number"
                  step="0.1"
                  min="0"
                  max="5"
              value={quickPickData.rating}
              onChange={(e) => setQuickPickData(prev => ({ ...prev, rating: parseFloat(e.target.value) || 0 }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              placeholder="Enter rating (0-5)"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Image URL</label>
            <input
              type="url"
              value={quickPickData.image}
              onChange={(e) => setQuickPickData(prev => ({ ...prev, image: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              placeholder="Enter image URL"
                />
              </div>
            </div>

        <div className="mt-6">
          <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
          <textarea
            value={quickPickData.description}
            onChange={(e) => setQuickPickData(prev => ({ ...prev, description: e.target.value }))}
            rows={4}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
            placeholder="Enter product description"
          />
        </div>

        <div className="mt-6">
          <label className="flex items-center">
              <input
                type="checkbox"
              checked={quickPickData.featured}
              onChange={(e) => setQuickPickData(prev => ({ ...prev, featured: e.target.checked }))}
              className="rounded border-gray-300 text-pink-600 shadow-sm focus:border-pink-300 focus:ring focus:ring-pink-200 focus:ring-opacity-50"
            />
            <span className="ml-2 text-sm text-gray-700 flex items-center">
              <Star className="w-4 h-4 mr-1" />
              Featured Item
            </span>
              </label>
                </div>
                
        <div className="mt-8 flex justify-end">
                  <button
            onClick={handleSave}
            disabled={saving}
            className="flex items-center px-6 py-3 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {saving ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Saving...
              </>
            ) : (
              <>
                <Save className="w-4 h-4 mr-2" />
                {id === 'add' ? 'Create Quick Pick' : 'Update Quick Pick'}
              </>
            )}
                  </button>
        </div>
      </div>
    </div>
  )
}