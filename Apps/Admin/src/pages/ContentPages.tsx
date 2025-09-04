import { useState, useEffect } from 'react'
import { Search, Plus, Edit, Eye, FileText } from 'lucide-react'
import { useNavigate } from 'react-router-dom'

interface ContentPage {
  id: string
  title: string
  updatedAt: string
  type: 'customer' | 'driver' | 'vendor'
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
    }
  ])

  const [activeTab, setActiveTab] = useState<'customer' | 'driver' | 'vendor'>('customer')
  const [searchTerm, setSearchTerm] = useState('')

  const filteredPages = contentPages.filter(page => {
    const matchesTab = page.type === activeTab
    const matchesSearch = page.title.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesTab && matchesSearch
  })

  const handleAddPage = () => {
    // Implement add page functionality
    console.log('Adding new content page...')
  }

  const handleEditPage = (pageId: string) => {
    navigate(`/contents/${pageId}/edit`)
  }

  const handleViewPage = (pageId: string) => {
    navigate(`/contents/${pageId}/edit`)
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Content Pages</h1>
          <p className="text-gray-600 mt-1">Manage static content pages for the application</p>
        </div>
        <button
          onClick={handleAddPage}
          className="flex items-center px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors"
        >
          <Plus className="w-4 h-4 mr-2" />
          Add
        </button>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          {[
            { key: 'customer', label: 'Customer' },
            { key: 'driver', label: 'Driver' },
            { key: 'vendor', label: 'Vendor' }
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
            placeholder="Search content pages"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
          />
        </div>
      </div>

      {/* Content Pages Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Sr. no.
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Title
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Updated at
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Action
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredPages.map((page, index) => (
                <tr key={page.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center mr-3">
                        <FileText className="w-4 h-4 text-gray-600" />
                      </div>
                      <span className="text-sm font-medium text-gray-900">{page.title}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {page.updatedAt}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => handleViewPage(page.id)}
                        className="w-8 h-8 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center hover:bg-blue-200 transition-colors"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleEditPage(page.id)}
                        className="w-8 h-8 bg-yellow-100 text-yellow-600 rounded-full flex items-center justify-center hover:bg-yellow-200 transition-colors"
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
      </div>
    </div>
  )
}
