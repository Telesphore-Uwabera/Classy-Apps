import { useState, useEffect } from 'react'
import { Search, Plus, Gift, Tag, MoreVertical, Trash2, Settings, RefreshCw } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'

interface Coupon {
  id: string
  maxDiscountAmount: number
  discountPercentage: number
  minimumBookingAmount: number
  couponCode: string
  validUpto: string
  status: 'active' | 'inactive'
  type: 'available_on_phone' | 'shared' | 'shared_used'
  description?: string
  usageCount?: number
  maxUsage?: number
}

export default function Coupons() {
  const [coupons, setCoupons] = useState<Coupon[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all')

  useEffect(() => {
    loadCoupons()
  }, [])

  const loadCoupons = async () => {
    try {
      setLoading(true)
      const couponsData = await firebaseService.getCollection('coupons')
      
      const couponsWithDetails = couponsData.map((coupon: any) => ({
        id: coupon.id,
        maxDiscountAmount: coupon.maxDiscountAmount || 0,
        discountPercentage: coupon.discountPercentage || 0,
        minimumBookingAmount: coupon.minimumBookingAmount || 0,
        couponCode: coupon.couponCode || 'Unknown',
        validUpto: coupon.validUpto?.toDate?.()?.toLocaleDateString() || 'Unknown',
        status: coupon.status || 'inactive',
        type: coupon.type || 'available_on_phone',
        description: coupon.description || '',
        usageCount: coupon.usageCount || 0,
        maxUsage: coupon.maxUsage || 100
      }))
      
      setCoupons(couponsWithDetails)
    } catch (error) {
      console.error('Error loading coupons:', error)
    } finally {
      setLoading(false)
    }
  }

  const toggleCouponStatus = async (couponId: string, currentStatus: string) => {
    try {
      const newStatus = currentStatus === 'active' ? 'inactive' : 'active'
      await firebaseService.updateDocument('coupons', couponId, { status: newStatus })
      
      setCoupons(prev => 
        prev.map(coupon => 
          coupon.id === couponId 
            ? { ...coupon, status: newStatus as 'active' | 'inactive' }
            : coupon
        )
      )
    } catch (error) {
      console.error('Error updating coupon status:', error)
    }
  }

  const deleteCoupon = async (couponId: string) => {
    if (window.confirm('Are you sure you want to delete this coupon?')) {
      try {
        await firebaseService.deleteDocument('coupons', couponId)
        setCoupons(prev => prev.filter(coupon => coupon.id !== couponId))
      } catch (error) {
        console.error('Error deleting coupon:', error)
      }
    }
  }

  const filteredCoupons = coupons.filter(coupon => {
    const matchesSearch = coupon.couponCode.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         coupon.description?.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === 'all' || coupon.status === statusFilter
    return matchesSearch && matchesStatus
  })

  const getStatusColor = (status: string) => {
    return status === 'active' 
      ? 'bg-green-100 text-green-800' 
      : 'bg-red-100 text-red-800'
  }

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'available_on_phone': return 'bg-blue-100 text-blue-800'
      case 'shared': return 'bg-purple-100 text-purple-800'
      case 'shared_used': return 'bg-gray-100 text-gray-800'
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
          <h1 className="text-3xl font-bold text-gray-900">Coupons</h1>
          <p className="text-gray-600 mt-1">Manage discount coupons from Firebase</p>
        </div>
        <div className="flex space-x-2">
        <button
            onClick={loadCoupons}
            className="flex items-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
        >
            <RefreshCw className="w-4 h-4 mr-2" />
            Refresh
          </button>
          <button className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors">
          <Plus className="w-4 h-4 mr-2" />
            Add Coupon
        </button>
      </div>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-4">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder="Search coupons..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
          />
        </div>
        <div className="flex space-x-2">
          {[
            { key: 'all', label: 'All' },
            { key: 'active', label: 'Active' },
            { key: 'inactive', label: 'Inactive' }
          ].map((filter) => (
            <button
              key={filter.key}
              onClick={() => setStatusFilter(filter.key as any)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                statusFilter === filter.key
                  ? 'bg-pink-100 text-pink-800'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {filter.label}
            </button>
          ))}
        </div>
      </div>

      {/* Coupons Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredCoupons.map((coupon) => (
          <div key={coupon.id} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start mb-4">
              <div className="flex items-center">
                <Gift className="w-5 h-5 text-pink-600 mr-2" />
                <h3 className="text-lg font-semibold text-gray-900">{coupon.couponCode}</h3>
              </div>
              <div className="flex space-x-1">
                        <button
                  onClick={() => toggleCouponStatus(coupon.id, coupon.status)}
                  className="text-gray-400 hover:text-blue-600 transition-colors"
                  title="Toggle Status"
                >
                  <Settings className="w-4 h-4" />
                                      </button>
                                      <button
                  onClick={() => deleteCoupon(coupon.id)}
                  className="text-gray-400 hover:text-red-600 transition-colors"
                  title="Delete Coupon"
                                      >
                  <Trash2 className="w-4 h-4" />
                                      </button>
                                    </div>
                                  </div>
            
            <div className="space-y-3 mb-4">
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-600">Discount:</span>
                <span className="text-sm font-medium text-gray-900">
                  {coupon.discountPercentage}% (Max ${coupon.maxDiscountAmount})
                </span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-600">Min. Amount:</span>
                <span className="text-sm font-medium text-gray-900">${coupon.minimumBookingAmount}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-600">Valid Until:</span>
                <span className="text-sm font-medium text-gray-900">{coupon.validUpto}</span>
                              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-600">Usage:</span>
                <span className="text-sm font-medium text-gray-900">
                  {coupon.usageCount}/{coupon.maxUsage}
                </span>
                            </div>
                          </div>
            
            <div className="flex justify-between items-center">
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(coupon.status)}`}>
                {coupon.status}
              </span>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getTypeColor(coupon.type)}`}>
                <Tag className="w-3 h-3 mr-1" />
                {coupon.type.replace('_', ' ')}
              </span>
                      </div>
            
            {coupon.description && (
              <div className="mt-3 pt-3 border-t border-gray-200">
                <p className="text-sm text-gray-600">{coupon.description}</p>
                    </div>
              )}
        </div>
        ))}
      </div>

      {filteredCoupons.length === 0 && (
        <div className="text-center py-12">
          <Gift className="w-12 h-12 text-gray-400 mx-auto mb-2" />
          <div className="text-gray-500">No coupons found</div>
        </div>
      )}
    </div>
  )
}