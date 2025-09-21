import { useState, useEffect } from 'react'
import { Search, Plus, Edit, Eye, FileText, RefreshCw } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'

interface ContentPage {
  id: string
  title: string
  updatedAt: string
  type: 'customer' | 'driver' | 'vendor'
  content?: string
  slug?: string
  isActive?: boolean
}

export default function ContentPages() {
  const navigate = useNavigate()
  const [contentPages, setContentPages] = useState<ContentPage[]>([
    {
      id: '1',
      title: 'About us',
      updatedAt: '15 May 2025',
      type: 'customer'
    },
    {
      id: '2',
      title: 'Privacy Policy',
      updatedAt: '15 May 2025',
      type: 'customer'
    },
    {
      id: '3',
      title: 'Terms & Conditions',
      updatedAt: '15 May 2025',
      type: 'customer'
    },
    {
      id: '4',
      title: 'Driver Guidelines',
      updatedAt: '15 May 2025',
      type: 'driver'
    },
    {
      id: '5',
      title: 'Safety Procedures',
      updatedAt: '15 May 2025',
      type: 'driver'
    },
    {
      id: '6',
      title: 'Partner Agreement',
      updatedAt: '15 May 2025',
      type: 'vendor'
    },
    {
      id: '7',
      title: 'Menu Guidelines',
      updatedAt: '15 May 2025',
      type: 'vendor'
    }
  ])
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<'customer' | 'driver' | 'vendor'>('customer')
  const [searchTerm, setSearchTerm] = useState('')

  const loadContentPagesFromFirebase = async () => {
    try {
      setLoading(true)
      const contentPagesData = await firebaseService.getCollection('content_pages')
      
      if (contentPagesData && contentPagesData.length > 0) {
        const pagesWithDetails = contentPagesData.map((page: any) => ({
          id: page.id,
          title: page.title || 'Untitled Page',
          updatedAt: page.updatedAt?.toDate?.()?.toLocaleDateString() || 
                    page.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
          type: page.type || 'customer',
          content: page.content || '',
          slug: page.slug || page.title?.toLowerCase().replace(/\s+/g, '-') || '',
          isActive: page.isActive !== false
        }))
        
        setContentPages(pagesWithDetails)
      }
    } catch (error) {
      console.error('Error loading content pages from Firebase:', error)
      // Keep the default mock data if Firebase fails
    } finally {
      setLoading(false)
    }
  }

  const deleteContentPage = async (pageId: string) => {
    if (window.confirm('Are you sure you want to delete this content page?')) {
      try {
        // Try to delete from Firebase first
        await firebaseService.deleteDocument('content_pages', pageId)
        setContentPages(prev => prev.filter(page => page.id !== pageId))
      } catch (error) {
        console.error('Error deleting content page from Firebase:', error)
        // If Firebase fails, just remove from local state
        setContentPages(prev => prev.filter(page => page.id !== pageId))
      }
    }
  }

  const filteredPages = contentPages.filter(page => {
    const matchesTab = page.type === activeTab
    const matchesSearch = page.title.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesTab && matchesSearch
  })

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'customer': return 'bg-blue-100 text-blue-800'
      case 'driver': return 'bg-green-100 text-green-800'
      case 'vendor': return 'bg-purple-100 text-purple-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusColor = (isActive: boolean) => {
    return isActive 
      ? 'bg-green-100 text-green-800'
      : 'bg-red-100 text-red-800'
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Content Pages</h1>
          <p className="text-gray-600 mt-1">Manage app content pages</p>
        </div>
        <div className="flex space-x-2">
          <button 
            onClick={loadContentPagesFromFirebase}
            disabled={loading}
            className="flex items-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Load from Firebase
          </button>
          <button 
            onClick={() => navigate('/contents/add')}
            className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
          >
            <Plus className="w-4 h-4 mr-2" />
            Add Page
          </button>
        </div>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          {[
            { key: 'customer', label: 'Customer Pages', count: contentPages.filter(p => p.type === 'customer').length },
            { key: 'driver', label: 'Driver Pages', count: contentPages.filter(p => p.type === 'driver').length },
            { key: 'vendor', label: 'Vendor Pages', count: contentPages.filter(p => p.type === 'vendor').length }
          ].map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key as any)}
              className={`py-2 px-1 border-b-2 font-medium text-sm flex items-center ${
                activeTab === tab.key
                  ? 'border-yellow-500 text-yellow-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              {tab.label}
              <span className={`ml-2 py-0.5 px-2 rounded-full text-xs ${
                activeTab === tab.key ? 'bg-yellow-100 text-yellow-800' : 'bg-gray-100 text-gray-600'
              }`}>
                {tab.count}
              </span>
            </button>
          ))}
        </nav>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search content pages..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
        />
      </div>

      {/* Content Pages Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Title
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Updated At
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredPages.map((page) => (
                <tr key={page.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-8 w-8">
                        <div className="h-8 w-8 rounded-full bg-pink-100 flex items-center justify-center">
                          <FileText className="w-4 h-4 text-pink-600" />
                        </div>
                      </div>
                      <div className="ml-3">
                        <div className="text-sm font-medium text-gray-900">{page.title}</div>
                        {page.slug && (
                          <div className="text-sm text-gray-500">/{page.slug}</div>
                        )}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getTypeColor(page.type)}`}>
                      {page.type}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(page.isActive !== false)}`}>
                      {page.isActive !== false ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {page.updatedAt}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button 
                        onClick={() => navigate(`/contents/${page.id}`)}
                        className="text-blue-600 hover:text-blue-900"
                        title="View Page"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button 
                        onClick={() => navigate(`/contents/${page.id}/edit`)}
                        className="text-green-600 hover:text-green-900"
                        title="Edit Page"
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {filteredPages.length === 0 && (
          <div className="text-center py-12">
            <FileText className="w-12 h-12 text-gray-400 mx-auto mb-2" />
            <div className="text-gray-500">No content pages found for {activeTab}s</div>
          </div>
        )}
      </div>
    </div>
  )
}