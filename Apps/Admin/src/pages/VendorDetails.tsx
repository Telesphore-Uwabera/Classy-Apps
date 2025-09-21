import { useState, useEffect } from 'react'
import { ArrowLeft, Check, X, Building2, Phone, Mail, MapPin, Calendar, FileText } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'
import { COLLECTIONS } from '../config/firebase'

interface VendorDetails {
  id: string
  businessName: string
  email: string
  phone: string
  address: string
  status: string
  isActive: boolean
  rating: number
  totalOrders: number
  createdAt: any
  updatedAt: any
  ownerName?: string
  ownerEmail?: string
  ownerPhone?: string
  businessType?: string
  licenseNumber?: string
  documents?: string[]
}

export default function VendorDetails() {
  const navigate = useNavigate()
  const { id } = useParams()
  const [vendor, setVendor] = useState<VendorDetails | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (id) {
      loadVendorDetails()
    }
  }, [id])

  const loadVendorDetails = async () => {
    try {
      setLoading(true)
      const vendorData = await firebaseService.getDocument(COLLECTIONS.VENDORS, id!)
      if (vendorData) {
        setVendor({
          id: vendorData.id,
          businessName: vendorData.businessName || 'Unknown Business',
          email: vendorData.email || 'No email',
          phone: vendorData.phone || 'No phone',
          address: vendorData.address || 'No address',
          status: vendorData.status || 'unknown',
          isActive: vendorData.isActive || false,
          rating: vendorData.rating || 0,
          totalOrders: vendorData.totalOrders || 0,
          createdAt: vendorData.createdAt,
          updatedAt: vendorData.updatedAt,
          ownerName: vendorData.ownerName,
          ownerEmail: vendorData.ownerEmail,
          ownerPhone: vendorData.ownerPhone,
          businessType: vendorData.businessType,
          licenseNumber: vendorData.licenseNumber,
          documents: vendorData.documents
        })
      }
    } catch (error) {
      console.error('Error loading vendor details:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = async () => {
    if (window.confirm('Are you sure you want to approve this vendor?')) {
      try {
        await firebaseService.updateDocument(COLLECTIONS.VENDORS, id!, { 
          status: 'active',
          isActive: true,
          updatedAt: new Date()
        })
        alert('Vendor approved successfully!')
        navigate('/vendors-requested')
      } catch (error) {
        console.error('Error approving vendor:', error)
        alert('Error approving vendor.')
      }
    }
  }

  const handleReject = async () => {
    if (window.confirm('Are you sure you want to reject this vendor?')) {
      try {
        await firebaseService.updateDocument(COLLECTIONS.VENDORS, id!, { 
          status: 'rejected',
          isActive: false,
          updatedAt: new Date()
        })
        alert('Vendor rejected successfully!')
        navigate('/vendors-requested')
      } catch (error) {
        console.error('Error rejecting vendor:', error)
        alert('Error rejecting vendor.')
      }
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

  if (!vendor) {
    return (
      <div className="space-y-6">
        <div className="flex items-center space-x-4">
          <button onClick={() => navigate('/vendors-requested')} className="text-gray-500 hover:text-gray-700">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-3xl font-bold text-gray-900">Vendor Not Found</h1>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <button onClick={() => navigate('/vendors-requested')} className="text-gray-500 hover:text-gray-700">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-3xl font-bold text-gray-900">Vendor Details</h1>
        </div>
        <div className="flex space-x-2">
          <button
            onClick={handleReject}
            className="flex items-center px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
          >
            <X className="w-4 h-4 mr-2" />
            Reject
          </button>
          <button
            onClick={handleApprove}
            className="flex items-center px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
          >
            <Check className="w-4 h-4 mr-2" />
            Approve
          </button>
        </div>
      </div>

      {/* Vendor Information */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="flex items-center space-x-4 mb-6">
          <div className="h-16 w-16 rounded-full bg-orange-100 flex items-center justify-center">
            <Building2 className="w-8 h-8 text-orange-600" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-gray-900">{vendor.businessName}</h2>
            <p className="text-gray-600">{vendor.email}</p>
            <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium mt-2 ${
              vendor.status === 'active' || vendor.status === 'online'
                ? 'bg-green-100 text-green-800'
                : vendor.status === 'offline' || vendor.status === 'pending'
                ? 'bg-yellow-100 text-yellow-800'
                : vendor.status === 'rejected'
                ? 'bg-red-100 text-red-800'
                : 'bg-gray-100 text-gray-800'
            }`}>
              {vendor.status}
            </span>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Basic Information */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800">Basic Information</h3>
            <div className="space-y-3">
              <div className="flex items-center space-x-3">
                <Building2 className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Business Name</p>
                  <p className="font-medium text-gray-900">{vendor.businessName}</p>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <Mail className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Email</p>
                  <p className="font-medium text-gray-900">{vendor.email}</p>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <Phone className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Phone</p>
                  <p className="font-medium text-gray-900">{vendor.phone}</p>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <MapPin className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Address</p>
                  <p className="font-medium text-gray-900">{vendor.address}</p>
                </div>
              </div>
            </div>
          </div>

          {/* Additional Information */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800">Additional Information</h3>
            <div className="space-y-3">
              {vendor.ownerName && (
                <div>
                  <p className="text-sm text-gray-500">Owner Name</p>
                  <p className="font-medium text-gray-900">{vendor.ownerName}</p>
                </div>
              )}
              {vendor.ownerEmail && (
                <div>
                  <p className="text-sm text-gray-500">Owner Email</p>
                  <p className="font-medium text-gray-900">{vendor.ownerEmail}</p>
                </div>
              )}
              {vendor.ownerPhone && (
                <div>
                  <p className="text-sm text-gray-500">Owner Phone</p>
                  <p className="font-medium text-gray-900">{vendor.ownerPhone}</p>
                </div>
              )}
              {vendor.businessType && (
                <div>
                  <p className="text-sm text-gray-500">Business Type</p>
                  <p className="font-medium text-gray-900">{vendor.businessType}</p>
                </div>
              )}
              {vendor.licenseNumber && (
                <div>
                  <p className="text-sm text-gray-500">License Number</p>
                  <p className="font-medium text-gray-900">{vendor.licenseNumber}</p>
                </div>
              )}
              <div className="flex items-center space-x-3">
                <Calendar className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Created</p>
                  <p className="font-medium text-gray-900">
                    {vendor.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown'}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Statistics */}
        <div className="mt-6 pt-6 border-t border-gray-200">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Statistics</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-blue-50 rounded-lg p-4">
              <p className="text-sm text-blue-600">Total Orders</p>
              <p className="text-2xl font-bold text-blue-900">{vendor.totalOrders}</p>
            </div>
            <div className="bg-yellow-50 rounded-lg p-4">
              <p className="text-sm text-yellow-600">Rating</p>
              <p className="text-2xl font-bold text-yellow-900">{vendor.rating || 'N/A'}</p>
            </div>
            <div className="bg-green-50 rounded-lg p-4">
              <p className="text-sm text-green-600">Status</p>
              <p className="text-2xl font-bold text-green-900 capitalize">{vendor.status}</p>
            </div>
          </div>
        </div>

        {/* Documents */}
        {vendor.documents && vendor.documents.length > 0 && (
          <div className="mt-6 pt-6 border-t border-gray-200">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Documents</h3>
            <div className="space-y-2">
              {vendor.documents.map((doc, index) => (
                <div key={index} className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
                  <FileText className="w-5 h-5 text-gray-400" />
                  <span className="text-sm text-gray-900">{doc}</span>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
