import { useState, useEffect } from 'react'
import { Building2, Check, X, Eye, Search, RefreshCw } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'
import { COLLECTIONS } from '../config/firebase'

interface VendorRequest {
  id: string
  vendorName: string
  ownerName: string
  email: string
  phone: string
  address: string
  businessType: string
  status: string
  submittedDate: string
  documents: any[]
  licenseNumber: string
}

export default function VendorsRequested() {
  const [requests, setRequests] = useState<VendorRequest[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const navigate = useNavigate()

  useEffect(() => {
    loadPendingVendors()
  }, [])

  const loadPendingVendors = async () => {
    try {
      setLoading(true)
      
      // Get pending vendors from vendors collection
      const allVendors = await firebaseService.getCollection(COLLECTIONS.VENDORS)
      const pendingVendors = allVendors.filter(vendor => 
        vendor.status === 'pending' || 
        vendor.status === 'offline' || // Firebase uses 'offline' for pending
        !vendor.status || // Default to pending if no status
        (vendor.status !== 'active' && vendor.status !== 'approved' && vendor.status !== 'online')
      )
      
      console.log('🔍 Debug Pending Vendors:')
      console.log('All vendors from vendors collection:', allVendors)
      console.log('Pending vendors found:', pendingVendors)
      
      const vendorsWithDetails = pendingVendors.map((vendor: any) => ({
        id: vendor.id,
        vendorName: vendor.businessName || vendor.name || 'Unknown Vendor',
        ownerName: vendor.ownerName || vendor.email || 'Unknown Owner',
        email: vendor.email || vendor.ownerEmail || 'No email',
        phone: vendor.phone || 'No phone',
        address: vendor.address || 'No address',
        businessType: vendor.businessType || 'Not specified',
        status: vendor.status || 'pending',
        submittedDate: vendor.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
        documents: vendor.documents || [],
        licenseNumber: vendor.licenseNumber || 'No license'
      }))
      
      setRequests(vendorsWithDetails)
    } catch (error) {
      console.error('Error loading pending vendors:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = async (vendorId: string) => {
    try {
      await firebaseService.updateVendorStatus(vendorId, 'active')
      setRequests(prev => prev.filter(request => request.id !== vendorId))
      alert('Vendor approved successfully!')
    } catch (error) {
      console.error('Error approving vendor:', error)
      alert('Error approving vendor')
    }
  }

  const handleReject = async (vendorId: string) => {
    try {
      await firebaseService.updateVendorStatus(vendorId, 'rejected')
      setRequests(prev => prev.filter(request => request.id !== vendorId))
      alert('Vendor rejected successfully!')
    } catch (error) {
      console.error('Error rejecting vendor:', error)
      alert('Error rejecting vendor')
    }
  }

  const handleViewDetails = (vendorId: string) => {
    navigate(`/vendors-requested/${vendorId}/view`)
  }

  const filteredRequests = requests.filter(request => {
    const matchesSearch = request.vendorName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         request.ownerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         request.email.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === 'all' || request.status === statusFilter
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
          <h1 className="text-3xl font-bold text-gray-900">Vendor Requests</h1>
          <p className="text-gray-600 mt-1">Review and approve pending vendor applications from Firebase</p>
        </div>
        <button 
          onClick={loadPendingVendors}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh
        </button>
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
          <option value="pending">Pending</option>
          <option value="approved">Approved</option>
          <option value="rejected">Rejected</option>
        </select>
      </div>

      {/* Requests Table */}
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
                  License
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Submitted Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredRequests.map((request) => (
                <tr key={request.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10">
                        <div className="h-10 w-10 rounded-full bg-green-100 flex items-center justify-center">
                          <Building2 className="w-5 h-5 text-green-600" />
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{request.vendorName}</div>
                        <div className="text-sm text-gray-500">{request.address}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{request.ownerName}</div>
                    <div className="text-sm text-gray-500">{request.email}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{request.phone}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                      {request.businessType}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{request.licenseNumber}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {request.submittedDate}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button 
                        onClick={() => handleViewDetails(request.id)}
                        className="text-blue-600 hover:text-blue-900"
                        title="View Details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button 
                        onClick={() => handleApprove(request.id)}
                        className="text-green-600 hover:text-green-900"
                        title="Approve Vendor"
                      >
                        <Check className="w-4 h-4" />
                      </button>
                      <button 
                        onClick={() => handleReject(request.id)}
                        className="text-red-600 hover:text-red-900"
                        title="Reject Vendor"
                      >
                        <X className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {filteredRequests.length === 0 && (
          <div className="text-center py-12">
            <div className="text-gray-500">No pending vendor requests found</div>
          </div>
        )}
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <Building2 className="h-8 w-8 text-orange-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Pending Approval</p>
              <p className="text-2xl font-semibold text-orange-600">
                {requests.filter(r => r.status === 'pending' || r.status === 'offline').length}
              </p>
            </div>
          </div>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <Check className="h-8 w-8 text-green-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Approved</p>
              <p className="text-2xl font-semibold text-green-600">
                {requests.filter(r => r.status === 'approved' || r.status === 'active').length}
              </p>
            </div>
          </div>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <Building2 className="h-8 w-8 text-gray-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Total</p>
              <p className="text-2xl font-semibold text-gray-900">
                {requests.length}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
