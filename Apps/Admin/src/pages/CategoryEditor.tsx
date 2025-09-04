import { useState } from 'react'
import { ArrowLeft, Save, Upload, X } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'

export default function CategoryEditor() {
  const navigate = useNavigate()
  const { id } = useParams()
  
  // Mock category data - in real app, fetch based on id
  const categoryData = {
    '1': { name: 'Main Course', image: '/api/placeholder/64/64' },
    '2': { name: 'Desserts', image: '/api/placeholder/64/64' },
    '3': { name: 'Breakfast', image: '/api/placeholder/64/64' },
    '4': { name: 'Burger', image: '/api/placeholder/64/64' },
    '5': { name: 'Pasta', image: '/api/placeholder/64/64' },
    '6': { name: 'Chicken', image: '/api/placeholder/64/64' }
  }

  const currentCategory = categoryData[id as keyof typeof categoryData] || {
    name: 'New Category',
    image: ''
  }

  const [name, setName] = useState(currentCategory.name)
  const [image, setImage] = useState(currentCategory.image)
  const [imageFile, setImageFile] = useState<File | null>(null)
  const [imagePreview, setImagePreview] = useState<string | null>(null)

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
    setImage('')
  }

  const handleSave = () => {
    // Handle save logic
    console.log('Saving category:', { name, image: imageFile || image })
    // Navigate back to categories
    navigate('/categories')
  }

  const isNewCategory = !id || id === 'new'

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <button
            onClick={() => navigate('/categories')}
            className="flex items-center text-gray-600 hover:text-gray-900"
          >
            <ArrowLeft className="w-5 h-5 mr-2" />
            Back
          </button>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              {isNewCategory ? 'Add New Category' : 'Edit Category'}
            </h1>
            <p className="text-gray-600 mt-1">
              {isNewCategory ? 'Create a new food category' : 'Update category information'}
            </p>
          </div>
        </div>
        <button
          onClick={handleSave}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <Save className="w-4 h-4 mr-2" />
          {isNewCategory ? 'Create Category' : 'Save Changes'}
        </button>
      </div>

      {/* Category Form */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Left Column - Form Fields */}
          <div className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Category Name *
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                placeholder="Enter category name"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Category Image
              </label>
              <div className="space-y-4">
                {/* Image Upload */}
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-pink-400 transition-colors">
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleImageUpload}
                    className="hidden"
                    id="image-upload"
                  />
                  <label
                    htmlFor="image-upload"
                    className="cursor-pointer flex flex-col items-center"
                  >
                    <Upload className="w-8 h-8 text-gray-400 mb-2" />
                    <span className="text-sm text-gray-600">
                      Click to upload image or drag and drop
                    </span>
                    <span className="text-xs text-gray-500 mt-1">
                      PNG, JPG, GIF up to 10MB
                    </span>
                  </label>
                </div>

                {/* Current Image Display */}
                {(imagePreview || image) && (
                  <div className="relative inline-block">
                    <img
                      src={imagePreview || image}
                      alt="Category preview"
                      className="w-32 h-32 object-cover rounded-lg border border-gray-200"
                    />
                    <button
                      onClick={handleRemoveImage}
                      className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full flex items-center justify-center hover:bg-red-600 transition-colors"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Right Column - Preview */}
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Preview</h3>
              <div className="border border-gray-200 rounded-lg p-4 bg-gray-50">
                <div className="flex items-center space-x-3">
                  <div className="w-12 h-12 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
                    {imagePreview || image ? (
                      <img
                        src={imagePreview || image}
                        alt={name}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <span className="text-gray-500 text-sm">No Image</span>
                    )}
                  </div>
                  <div>
                    <h4 className="font-medium text-gray-900">
                      {name || 'Category Name'}
                    </h4>
                    <p className="text-sm text-gray-500">Food Category</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Category Information */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Category Information</h3>
              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Category ID:</span>
                  <span className="text-sm text-gray-900">{id || 'Auto-generated'}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Status:</span>
                  <span className="text-sm text-green-600">Active</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Created:</span>
                  <span className="text-sm text-gray-900">
                    {isNewCategory ? 'Will be set on creation' : '14 Aug 2025'}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Tips */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-blue-900 mb-2">Tips for creating categories:</h4>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>• Use clear, descriptive names that customers will understand</li>
          <li>• Choose high-quality images that represent the category well</li>
          <li>• Keep category names concise but informative</li>
          <li>• Consider how categories will appear in the customer app</li>
        </ul>
      </div>
    </div>
  )
}
