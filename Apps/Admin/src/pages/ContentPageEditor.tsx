import { useState, useEffect } from 'react'
import { ArrowLeft, Save, Eye, RefreshCw } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'

export default function ContentPageEditor() {
  const navigate = useNavigate()
  const { id } = useParams()
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  
  const [contentData, setContentData] = useState({
    title: '',
    content: '',
    type: 'customer',
    isActive: true,
    slug: ''
  })

  const [isPreview, setIsPreview] = useState(false)

  useEffect(() => {
    if (id && id !== 'add') {
      loadContentPage()
    } else {
      setLoading(false)
    }
  }, [id])

  const loadContentPage = async () => {
    try {
      setLoading(true)
      const page = await firebaseService.getDocument('content_pages', id!)
      
      if (page) {
        setContentData({
          title: page.title || '',
          content: page.content || '',
          type: page.type || 'customer',
          isActive: page.isActive !== false,
          slug: page.slug || ''
        })
      }
    } catch (error) {
      console.error('Error loading content page:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    try {
      setSaving(true)
      
      const pageToSave = {
        ...contentData,
        updatedAt: new Date()
      }
      
      if (id === 'add') {
        // Create new page
        pageToSave.createdAt = new Date()
        pageToSave.slug = contentData.title.toLowerCase().replace(/\s+/g, '-')
        await firebaseService.addDocument('content_pages', pageToSave)
        alert('Content page created successfully!')
      } else {
        // Update existing page
        await firebaseService.updateDocument('content_pages', id!, pageToSave)
        alert('Content page updated successfully!')
      }
      
      navigate('/contents')
    } catch (error) {
      console.error('Error saving content page:', error)
      alert('Error saving content page')
    } finally {
      setSaving(false)
    }
  }

  const handlePreview = () => {
    setIsPreview(!isPreview)
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
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <button
            onClick={() => navigate('/contents')}
            className="flex items-center text-gray-600 hover:text-gray-900"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Content Pages
          </button>
        </div>
        <div className="flex space-x-2">
          <button
            onClick={handlePreview}
            className="flex items-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
          >
            <Eye className="w-4 h-4 mr-2" />
            {isPreview ? 'Edit' : 'Preview'}
          </button>
          <button
            onClick={handleSave}
            disabled={saving}
            className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors disabled:opacity-50"
          >
            <Save className="w-4 h-4 mr-2" />
            {saving ? 'Saving...' : 'Save Page'}
          </button>
        </div>
      </div>

      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">
          {id === 'add' ? 'Add New Content Page' : 'Edit Content Page'}
        </h1>
        <p className="text-gray-600 mt-1">
          {id === 'add' ? 'Create a new content page' : 'Edit content page details'}
        </p>
              </div>

      {!isPreview ? (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Form */}
          <div className="lg:col-span-2 space-y-6">
            {/* Basic Information */}
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Basic Information</h3>
              
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                    Page Title *
                </label>
                <input
                  type="text"
                    value={contentData.title}
                    onChange={(e) => setContentData(prev => ({ ...prev, title: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                    placeholder="Enter page title"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Page Type
                  </label>
                  <select
                    value={contentData.type}
                    onChange={(e) => setContentData(prev => ({ ...prev, type: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                  >
                    <option value="customer">Customer</option>
                    <option value="driver">Driver</option>
                    <option value="vendor">Vendor</option>
                    <option value="general">General</option>
                  </select>
                </div>

                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="isActive"
                    checked={contentData.isActive}
                    onChange={(e) => setContentData(prev => ({ ...prev, isActive: e.target.checked }))}
                    className="h-4 w-4 text-pink-600 focus:ring-pink-500 border-gray-300 rounded"
                  />
                  <label htmlFor="isActive" className="ml-2 block text-sm text-gray-700">
                    Active (visible to users)
                  </label>
                </div>
              </div>
            </div>

            {/* Content */}
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Content</h3>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Page Content *
                </label>
                <textarea
                  value={contentData.content}
                  onChange={(e) => setContentData(prev => ({ ...prev, content: e.target.value }))}
                  rows={15}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                  placeholder="Enter page content (supports markdown)"
                  required
                />
                <p className="text-sm text-gray-500 mt-2">
                  You can use basic HTML tags or markdown formatting.
                </p>
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Page Info */}
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Page Information</h3>
              
              <div className="space-y-3">
                <div>
                  <label className="block text-sm font-medium text-gray-500">URL Slug</label>
                  <p className="text-sm text-gray-900">
                    {contentData.title ? `/${contentData.title.toLowerCase().replace(/\s+/g, '-')}` : '/page-slug'}
                  </p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-500">Status</label>
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                    contentData.isActive 
                      ? 'bg-green-100 text-green-800'
                      : 'bg-red-100 text-red-800'
                  }`}>
                    {contentData.isActive ? 'Active' : 'Inactive'}
                  </span>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-500">Type</label>
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                    contentData.type === 'customer' ? 'bg-blue-100 text-blue-800' :
                    contentData.type === 'driver' ? 'bg-green-100 text-green-800' :
                    contentData.type === 'vendor' ? 'bg-purple-100 text-purple-800' :
                    'bg-gray-100 text-gray-800'
                  }`}>
                    {contentData.type.charAt(0).toUpperCase() + contentData.type.slice(1)}
                  </span>
                </div>
              </div>
            </div>

            {/* Actions */}
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Actions</h3>
              
              <div className="space-y-2">
                <button
                  onClick={handleSave}
                  disabled={saving || !contentData.title || !contentData.content}
                  className="w-full flex items-center justify-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors disabled:opacity-50"
                >
                  <Save className="w-4 h-4 mr-2" />
                  {saving ? 'Saving...' : 'Save Page'}
                </button>
                
                <button
                  onClick={() => navigate('/contents')}
                  className="w-full flex items-center justify-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      ) : (
        /* Preview */
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Preview</h3>
          
          <div className="prose max-w-none">
            <h1 className="text-2xl font-bold text-gray-900 mb-4">{contentData.title}</h1>
            <div className="text-gray-700 whitespace-pre-wrap">
              {contentData.content || 'No content to preview'}
              </div>
            </div>
          </div>
        )}
    </div>
  )
}