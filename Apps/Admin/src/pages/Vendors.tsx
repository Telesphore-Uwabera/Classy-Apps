import { useState, useEffect } from 'react'
import { Search, Eye, Building2, Phone, Star, RefreshCw, CheckCircle, XCircle, X } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'
import { COLLECTIONS } from '../config/firebase'

interface Vendor {
  id: string
  name: string
  phone: string
  totalOrders: number
  rating: number | null
  status: 'active' | 'blocked' | 'deleted' | 'pending'
  joinedDate: string
  address: string
  ownerName: string
  ownerEmail: string
  ownerPhone: string
  bankAccount: string
  businessType: string
  licenseNumber: string
}

export default function Vendors() {
  const [vendors, setVendors] = useState<Vendor[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [selectedVendor, setSelectedVendor] = useState<Vendor | null>(null)
  const [showVendorModal, setShowVendorModal] = useState(false)

  useEffect(() => {
    loadVendors()
  }, [])

  const loadVendors = async () => {
    try {
      setLoading(true)
      
      // Get only approved/active vendors from vendors collection
      const allVendors = await firebaseService.getCollection(COLLECTIONS.VENDORS)
      const vendorsData = allVendors.filter(vendor => 
        vendor.status === 'active' || 
        vendor.status === 'approved' || 
        vendor.status === 'online'
      )
      
      console.log('🔍 Debug Vendors Data:')
      console.log('All vendors from vendors collection:', allVendors)
      console.log('Filtered active vendors:', vendorsData)
      
      // Get orders for each vendor to count their orders
      const vendorsWithOrders = await Promise.all(
        vendorsData.map(async (vendor: any) => {
          const vendorOrders = await firebaseService.queryCollection('orders', [
            { field: 'vendorId', operator: '==', value: vendor.id }
          ])
          
          return {
            id: vendor.id,
            name: vendor.businessName || vendor.name || 'Unknown Vendor',
            phone: vendor.phone || 'No phone',
            totalOrders: vendorOrders.length,
            rating: vendor.rating || null,
            status: vendor.status || 'active',
            joinedDate: vendor.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
            address: vendor.address || 'No address',
            ownerName: vendor.ownerName || vendor.email || 'Unknown Owner',
            ownerEmail: vendor.email || vendor.ownerEmail || 'No email',
            ownerPhone: vendor.ownerPhone || vendor.phone || 'No phone',
            bankAccount: vendor.bankAccount || 'No account',
            businessType: vendor.businessType || 'Unknown',
            licenseNumber: vendor.licenseNumber || 'No license'
          }
        })
      )
      
      setVendors(vendorsWithOrders)
    } catch (error) {
      console.error('Error loading vendors:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleStatusChange = async (vendorId: string, newStatus: string) => {
    try {
      await firebaseService.updateVendorStatus(vendorId, newStatus)
      setVendors(prev => 
        prev.map(vendor => 
          vendor.id === vendorId 
            ? { ...vendor, status: newStatus as 'active' | 'blocked' | 'deleted' }
            : vendor
        )
      )
    } catch (error) {
      console.error('Error updating vendor status:', error)
    }
  }

  const handleViewVendor = (vendor: Vendor) => {
    setSelectedVendor(vendor)
    setShowVendorModal(true)
  }

  const filteredVendors = vendors.filter(vendor => {
    const matchesSearch = vendor.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         vendor.ownerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         vendor.phone.includes(searchTerm)
    const matchesStatus = statusFilter === 'all' || vendor.status === statusFilter
    return matchesSearch && matchesStatus
  })

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
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Vendors</h1>
          <p className="text-gray-600 mt-1">Manage vendor accounts from Firebase</p>
        </div>
        <div className="flex space-x-2">
          <button 
            onClick={loadVendors}
            className="flex items-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
          >
            <RefreshCw className="w-4 h-4 mr-2" />
            Refresh
          </button>
        </div>
      </div>

      {/* Search and Filter */}
      <div className="flex flex-col sm:flex-row gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder="Search vendors..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
          />
        </div>
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
        >
          <option value="all">All Status</option>
          <option value="active">Active</option>
          <option value="blocked">Blocked</option>
          <option value="pending">Pending</option>
        </select>
      </div>

      {/* Vendors Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Vendor
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Owner
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Contact
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Business Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Orders
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Rating
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Joined
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredVendors.map((vendor) => (
                <tr key={vendor.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10">
                        <div className="h-10 w-10 rounded-full bg-green-100 flex items-center justify-center">
                          <Building2 className="w-5 h-5 text-green-600" />
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{vendor.name}</div>
                        <div className="text-sm text-gray-500">{vendor.address}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{vendor.ownerName}</div>
                    <div className="text-sm text-gray-500">{vendor.ownerEmail}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{vendor.phone}</div>
                    <div className="text-sm text-gray-500">{vendor.ownerPhone}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                      {vendor.businessType}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      {vendor.totalOrders} orders
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {vendor.rating ? (
                      <div className="flex items-center">
                        <Star className="w-4 h-4 text-yellow-400 fill-current" />
                        <span className="ml-1 text-sm text-gray-900">{vendor.rating}</span>
                      </div>
                    ) : (
                      <span className="text-sm text-gray-500">No rating</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      vendor.status === 'active' 
                        ? 'bg-green-100 text-green-800'
                        : vendor.status === 'blocked'
                        ? 'bg-red-100 text-red-800'
                        : vendor.status === 'pending'
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {vendor.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {vendor.joinedDate}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button 
                        onClick={() => handleViewVendor(vendor)}
                        className="text-blue-600 hover:text-blue-900"
                        title="View Vendor Details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      {vendor.status === 'active' ? (
                        <button 
                          onClick={() => handleStatusChange(vendor.id, 'blocked')}
                          className="text-red-600 hover:text-red-900"
                          title="Block Vendor"
                        >
                          <XCircle className="w-4 h-4" />
                        </button>
                      ) : (
                        <button 
                          onClick={() => handleStatusChange(vendor.id, 'active')}
                          className="text-green-600 hover:text-green-900"
                          title="Unblock Vendor"
                        >
                          <CheckCircle className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {filteredVendors.length === 0 && (
          <div className="text-center py-12">
            <div className="text-gray-500">No vendors found</div>
          </div>
        )}
      </div>

      {/* Vendor Details Modal */}
      {showVendorModal && selectedVendor && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4">
            <div className="flex justify-between items-center p-6 border-b border-gray-200">
              <h3 className="text-lg font-semibold text-gray-900">Vendor Details</h3>
              <button
                onClick={() => setShowVendorModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="p-6 space-y-6">
              <div className="flex items-center space-x-4">
                <div className="h-12 w-12 rounded-full bg-green-100 flex items-center justify-center">
                  <Building2 className="w-6 h-6 text-green-600" />
                </div>
                <div>
                  <h4 className="text-lg font-medium text-gray-900">{selectedVendor.name}</h4>
                  <p className="text-sm text-gray-500">{selectedVendor.address}</p>
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Owner Name</label>
                    <p className="text-sm text-gray-900">{selectedVendor.ownerName}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Owner Email</label>
                    <p className="text-sm text-gray-900">{selectedVendor.ownerEmail}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Owner Phone</label>
                    <p className="text-sm text-gray-900">{selectedVendor.ownerPhone}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Business Phone</label>
                    <p className="text-sm text-gray-900">{selectedVendor.phone}</p>
                  </div>
                </div>
                
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Business Type</label>
                    <p className="text-sm text-gray-900">{selectedVendor.businessType}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">License Number</label>
                    <p className="text-sm text-gray-900">{selectedVendor.licenseNumber}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Total Orders</label>
                    <p className="text-sm text-gray-900">{selectedVendor.totalOrders} orders</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Rating</label>
                    <p className="text-sm text-gray-900">
                      {selectedVendor.rating ? `${selectedVendor.rating} ⭐` : 'No rating'}
                    </p>
                  </div>
                </div>
              </div>
              
              <div>
                <label className="text-sm font-medium text-gray-500">Status</label>
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                  selectedVendor.status === 'active' 
                    ? 'bg-green-100 text-green-800'
                    : selectedVendor.status === 'blocked'
                    ? 'bg-red-100 text-red-800'
                    : selectedVendor.status === 'pending'
                    ? 'bg-yellow-100 text-yellow-800'
                    : 'bg-gray-100 text-gray-800'
                }`}>
                  {selectedVendor.status}
                </span>
              </div>
              
              <div>
                <label className="text-sm font-medium text-gray-500">Bank Account</label>
                <p className="text-sm text-gray-900">{selectedVendor.bankAccount}</p>
              </div>
              
              <div>
                <label className="text-sm font-medium text-gray-500">Joined</label>
                <p className="text-sm text-gray-900">{selectedVendor.joinedDate}</p>
              </div>
            </div>
            
            <div className="flex justify-end space-x-3 p-6 border-t border-gray-200">
              <button
                onClick={() => setShowVendorModal(false)}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
