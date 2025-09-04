import { useState } from 'react'
import { Building2, Eye, Search, Filter, FileCheck } from 'lucide-react'

export default function RestaurantsDocsUpdated() {
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('pending')
  
  const [docsUpdated] = useState([
    {
      id: 1,
      restaurantName: 'Bella Vista Restaurant',
      ownerName: 'John Smith',
      email: 'john@bellavista.com',
      phone: '+1 (555) 123-4567',
      status: 'submitted',
      updatedDate: '2025-01-15',
      documents: ['Business License', 'Health Certificate', 'Insurance']
    },
    {
      id: 2,
      restaurantName: 'Spice Garden',
      ownerName: 'Maria Garcia',
      email: 'maria@spicegarden.com',
      phone: '+1 (555) 987-6543',
      status: 'submitted',
      updatedDate: '2025-01-14',
      documents: ['Business License', 'Health Certificate']
    }
  ])

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
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Restaurants Docs Updated</h1>
        <p className="text-gray-600 mt-1">Review updated restaurant documents</p>
      </div>

      {/* Status Tabs */}
      <div className="flex space-x-1 bg-gray-100 p-1 rounded-lg w-fit">
        <button
          className={`px-4 py-2 text-sm font-medium rounded-md transition-colors ${
            statusFilter === 'pending'
              ? 'bg-white text-gray-900 shadow-sm'
              : 'text-gray-600 hover:text-gray-900'
          }`}
          onClick={() => setStatusFilter('pending')}
        >
          Pending
        </button>
        <button
          className={`px-4 py-2 text-sm font-medium rounded-md transition-colors ${
            statusFilter === 'rejected'
              ? 'bg-white text-gray-900 shadow-sm'
              : 'text-gray-600 hover:text-gray-900'
          }`}
          onClick={() => setStatusFilter('rejected')}
        >
          Rejected
        </button>
      </div>

      {/* Search */}
      <div className="flex items-center space-x-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder="Search by phone number or name"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
          />
        </div>
        <button className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors">
          <Search className="w-4 h-4 mr-2" />
          Search
        </button>
      </div>

      {/* Docs Updated Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Sr. no.
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Phone
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Updated on
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Action
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
                    <div>
                      <div className="text-sm font-medium text-gray-900">{doc.restaurantName}</div>
                      <div className="text-sm text-gray-500">{doc.ownerName}</div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {doc.phone}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {new Date(doc.updatedDate).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button className="text-pink-600 hover:text-pink-900">
                      <Eye className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {filteredDocs.length === 0 && (
        <div className="text-center py-12">
          <FileCheck className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No data</h3>
          <p className="text-gray-600">No restaurant document updates found.</p>
        </div>
      )}
    </div>
  )
}
