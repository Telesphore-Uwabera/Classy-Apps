import { useState, useEffect } from 'react'
import { ArrowLeft, Save, Upload, X, RefreshCw } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'

interface CategoryData {
  name: string
  image: string
  description?: string
  isActive?: boolean
}

export default function CategoryEditor() {
  const navigate = useNavigate()
  const { id } = useParams()
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  
  const [categoryData, setCategoryData] = useState<CategoryData>({
    name: '',
    image: '',
    description: '',
    isActive: true
  })
  
  const [imageFile, setImageFile] = useState<File | null>(null)
  const [imagePreview, setImagePreview] = useState<string | null>(null)

  useEffect(() => {
    if (id && id !== 'add' && id !== 'new') {
      loadCategory()
    } else {
      setLoading(false)
    }
  }, [id])

  const loadCategory = async () => {
    try {
      setLoading(true)
      const category = await firebaseService.getDocument('categories', id!)
      
      if (category) {
        setCategoryData({
          name: category.name || '',
          image: category.image || '',
          description: category.description || '',
          isActive: category.isActive !== false
        })
        
        if (category.image) {
          setImagePreview(category.image)
        }
      }
    } catch (error) {
      console.error('Error loading category:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleImageUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      setImageFile(file)
      const reader = new FileReader()
      reader.onload = (e) => {
        setImagePreview(e.target?.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const handleRemoveImage = () => {
    setImageFile(null)
    setImagePreview(null)
    setCategoryData(prev => ({ ...prev, image: '' }))
  }

  const handleSave = async () => {
    try {
      setSaving(true)
      
      const categoryToSave = {
        ...categoryData,
        updatedAt: new Date()
      }
      
      if (id === 'add' || id === 'new') {
        // Create new category
        categoryToSave.createdAt = new Date()
        await firebaseService.addDocument('categories', categoryToSave)
        alert('Category created successfully!')
      } else {
        // Update existing category
        await firebaseService.updateDocument('categories', id!, categoryToSave)
        alert('Category updated successfully!')
      }
      
    navigate('/categories')
    } catch (error) {
      console.error('Error saving category:', error)
      alert('Error saving category')
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
            onClick={() => navigate('/categories')}
            className="flex items-center text-gray-600 hover:text-gray-900 mr-4"
          >
            <ArrowLeft className="w-4 h-4 mr-1" />
            Back to Categories
          </button>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              {id === 'add' ? 'Add Category' : 'Edit Category'}
            </h1>
            <p className="text-gray-600 mt-1">
              {id === 'add' ? 'Create a new food category' : 'Update category details from Firebase'}
            </p>
          </div>
        </div>
        <button
          onClick={loadCategory}
          className="flex items-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh
        </button>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <div className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Category Name</label>
              <input
                type="text"
                value={categoryData.name}
                onChange={(e) => setCategoryData(prev => ({ ...prev, name: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                placeholder="Enter category name"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
              <textarea
                value={categoryData.description}
                onChange={(e) => setCategoryData(prev => ({ ...prev, description: e.target.value }))}
                rows={4}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                placeholder="Enter category description"
              />
            </div>

            <div>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={categoryData.isActive}
                  onChange={(e) => setCategoryData(prev => ({ ...prev, isActive: e.target.checked }))}
                  className="rounded border-gray-300 text-pink-600 shadow-sm focus:border-pink-300 focus:ring focus:ring-pink-200 focus:ring-opacity-50"
                />
                <span className="ml-2 text-sm text-gray-700">Active Category</span>
              </label>
            </div>
          </div>

          <div className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Category Image</label>
              
              {imagePreview ? (
                <div className="relative">
                  <img
                    src={imagePreview}
                    alt="Category preview"
                    className="w-full h-48 object-cover rounded-lg border border-gray-300"
                  />
                  <button
                    onClick={handleRemoveImage}
                    className="absolute top-2 right-2 p-1 bg-red-500 text-white rounded-full hover:bg-red-600 transition-colors"
                  >
                    <X className="w-4 h-4" />
                  </button>
                </div>
              ) : (
                <div className="w-full h-48 border-2 border-dashed border-gray-300 rounded-lg flex items-center justify-center">
                  <div className="text-center">
                    <Upload className="w-8 h-8 text-gray-400 mx-auto mb-2" />
                    <p className="text-sm text-gray-500">No image selected</p>
                  </div>
                </div>
              )}

              <div className="mt-4">
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleImageUpload}
                    className="hidden"
                    id="image-upload"
                  />
                  <label
                    htmlFor="image-upload"
                  className="flex items-center justify-center w-full px-4 py-2 border border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
                >
                  <Upload className="w-4 h-4 mr-2" />
                  {imagePreview ? 'Change Image' : 'Upload Image'}
                  </label>
          </div>

              <div className="mt-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">Or Image URL</label>
                <input
                  type="url"
                  value={categoryData.image}
                  onChange={(e) => {
                    setCategoryData(prev => ({ ...prev, image: e.target.value }))
                    if (e.target.value) {
                      setImagePreview(e.target.value)
                    }
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                  placeholder="Enter image URL"
                />
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8 flex justify-end">
          <button
            onClick={handleSave}
            disabled={saving || !categoryData.name.trim()}
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
                {id === 'add' ? 'Create Category' : 'Update Category'}
              </>
            )}
          </button>
      </div>
      </div>
    </div>
  )
}