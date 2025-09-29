import { useState, useEffect } from 'react'
import { Building2, Eye, Search, Filter, FileCheck, RefreshCw } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'

interface RestaurantDoc {
  id: string
  restaurantName: string
  ownerName: string
  email: string
  phone: string
  status: string
  updatedDate: string
  documents: string[]
}

export default function RestaurantsDocsUpdated() {
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('pending')
  const [docsUpdated, setDocsUpdated] = useState<RestaurantDoc[]>([])
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    loadRestaurantDocs()
  }, [])

  const loadRestaurantDocs = async () => {
    try {
      setLoading(true)
      const vendors = await firebaseService.getVendors()
      
      // Filter vendors that have recently updated documents
      const docsWithUpdates = vendors.filter((vendor: any) => 
        vendor.documentsUpdated === true || 
        vendor.status === 'pending' ||
        vendor.lastDocumentUpdate
      )
      
      const docsWithDetails = docsWithUpdates.map((vendor: any) => ({
        id: vendor.id,
        restaurantName: vendor.name || 'Unknown Restaurant',
        ownerName: vendor.ownerName || 'Unknown Owner',
        email: vendor.ownerEmail || 'No email',
        phone: vendor.phone || 'No phone',
        status: vendor.status || 'pending',
        updatedDate: vendor.lastDocumentUpdate?.toDate?.()?.toLocaleDateString() || 
                    vendor.updatedAt?.toDate?.()?.toLocaleDateString() || 
                    'Unknown',
        documents: vendor.documents || ['Business License', 'Health Certificate']
      }))
      
      setDocsUpdated(docsWithDetails)
    } catch (error) {
      console.error('Error loading restaurant docs:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredDocs = docsUpdated.filter(doc =>
    doc.restaurantName.toLowerCase().includes(searchTerm.toLowerCase()) ||
    doc.ownerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
    doc.phone.includes(searchTerm)
  )

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'submitted': return 'bg-blue-100 text-blue-800'
      case 'approved': return 'bg-green-100 text-green-800'
      case 'rejected': return 'bg-red-100 text-red-800'
      case 'pending': return 'bg-yellow-100 text-yellow-800'
      default: return 'bg-gray-100 text-gray-800'
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
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Restaurants Docs Updated</h1>
          <p className="text-gray-600 mt-1">Review updated restaurant documents from Firebase</p>
        </div>
        <button 
          onClick={loadRestaurantDocs}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh
        </button>
      </div>

      {/* Status Filters */}
      <div className="flex space-x-2">
        {[
          { key: 'pending', label: 'Pending' },
          { key: 'submitted', label: 'Submitted' },
          { key: 'approved', label: 'Approved' },
          { key: 'rejected', label: 'Rejected' }
        ].map((filter) => (
          <button
            key={filter.key}
            onClick={() => setStatusFilter(filter.key)}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
              statusFilter === filter.key
                ? 'bg-pink-100 text-pink-800'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {filter.label}
          </button>
        ))}
      </div>

      {/* Search */}
      <div className="flex items-center space-x-4">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder="Search by phone number or name"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
          />
        </div>
        <button className="px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors">
          <Search className="w-4 h-4" />
        </button>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  SR. NO.
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  NAME
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  PHONE
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  UPDATED ON
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  STATUS
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ACTION
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredDocs.map((doc, index) => (
                <tr key={doc.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10">
                        <div className="h-10 w-10 rounded-full bg-pink-100 flex items-center justify-center">
                          <Building2 className="w-5 h-5 text-pink-600" />
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{doc.restaurantName}</div>
                        <div className="text-sm text-gray-500">{doc.ownerName}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {doc.phone}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {doc.updatedDate}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(doc.status)}`}>
                      {doc.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button className="text-purple-600 hover:text-purple-900">
                      <Eye className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {filteredDocs.length === 0 && (
          <div className="text-center py-12">
            <div className="text-gray-500">No restaurant document updates found</div>
          </div>
        )}
      </div>
    </div>
  )
}