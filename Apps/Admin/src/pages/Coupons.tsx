import { useState, useEffect } from 'react'
import { Search, Plus, Gift, Tag, MoreVertical, Trash2, Settings } from 'lucide-react'

interface Coupon {
  id: string
  maxDiscountAmount: number
  discountPercentage: number
  minimumBookingAmount: number
  couponCode: string
  validUpto: string
  status: 'active' | 'inactive'
  type: 'available_on_phone' | 'shared' | 'shared_used'
}

export default function Coupons() {
  const [coupons, setCoupons] = useState<Coupon[]>([
    {
      id: '1',
      maxDiscountAmount: 20,
      discountPercentage: 10,
      minimumBookingAmount: 200,
      couponCode: '1234',
      validUpto: '27 Aug 2025',
      status: 'inactive',
      type: 'available_on_phone'
    },
    {
      id: '2',
      maxDiscountAmount: 100,
      discountPercentage: 50,
      minimumBookingAmount: 200,
      couponCode: 'FLAT50',
      validUpto: '30 Apr 2025',
      status: 'inactive',
      type: 'available_on_phone'
    },
    {
      id: '3',
      maxDiscountAmount: 45,
      discountPercentage: 56,
      minimumBookingAmount: 65,
      couponCode: '24',
      validUpto: '10 Jul 2025',
      status: 'inactive',
      type: 'shared'
    },
    {
      id: '4',
      maxDiscountAmount: 5,
      discountPercentage: 5,
      minimumBookingAmount: 5,
      couponCode: 'ABCDEF',
      validUpto: '03 Apr 2025',
      status: 'inactive',
      type: 'shared'
    }
  ])

  const [activeTab, setActiveTab] = useState<'available_on_phone' | 'shared' | 'shared_used'>('available_on_phone')
  const [searchTerm, setSearchTerm] = useState('')
  const [openDropdown, setOpenDropdown] = useState<string | null>(null)
  const [openSubmenu, setOpenSubmenu] = useState<string | null>(null)

  const filteredCoupons = coupons.filter(coupon => {
    const matchesTab = coupon.type === activeTab
    const matchesSearch = coupon.couponCode.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesTab && matchesSearch
  })

  const getTabLabel = (type: string) => {
    switch (type) {
      case 'available_on_phone':
        return 'Available on phone'
      case 'shared':
        return 'Shared'
      case 'shared_used':
        return 'Shared coupons used'
      default:
        return type
    }
  }

  const getNoteText = () => {
    switch (activeTab) {
      case 'available_on_phone':
        return 'Note -: These coupons will be available for display within the customer app, and any user can redeem them. They are not limited to a single use.'
      case 'shared':
        return 'Note-: These coupons will not be displayed in the app and can be redeemed only once.'
      case 'shared_used':
        return 'Note-: These are shared coupons that have been used by customers.'
      default:
        return ''
    }
  }

  const handleAddCoupon = () => {
    // Implement add coupon functionality
    console.log('Adding new coupon...')
  }

  const handleDeleteCoupon = (couponId: string) => {
    setCoupons(prevCoupons => prevCoupons.filter(coupon => coupon.id !== couponId))
    setOpenDropdown(null)
  }

  const handleStatusChange = (couponId: string, newStatus: 'active' | 'inactive') => {
    setCoupons(prevCoupons => 
      prevCoupons.map(coupon => 
        coupon.id === couponId 
          ? { ...coupon, status: newStatus }
          : coupon
      )
    )
    setOpenSubmenu(null)
    setOpenDropdown(null)
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Coupons</h1>
          <p className="text-gray-600 mt-1">Manage discount coupons and promotional codes</p>
        </div>
        <button
          onClick={handleAddCoupon}
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
            { key: 'available_on_phone', label: 'Available on phone' },
            { key: 'shared', label: 'Shared' },
            { key: 'shared_used', label: 'Shared coupons used' }
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
            placeholder="Search by coupon code"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
          />
        </div>
      </div>

      {/* Coupons Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Sr. no.
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Max discount amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Discount percentage
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Minimum booking amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Coupon code
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Valid upto
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Action
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredCoupons.length > 0 ? (
                filteredCoupons.map((coupon, index) => (
                  <tr key={coupon.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {index + 1}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      ${coupon.maxDiscountAmount}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {coupon.discountPercentage}%
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      ${coupon.minimumBookingAmount}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {coupon.couponCode}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {coupon.validUpto}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-block px-2 py-1 rounded-full text-xs font-medium ${
                        coupon.status === 'active' 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {coupon.status === 'active' ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="relative">
                        <button
                          onClick={() => setOpenDropdown(openDropdown === coupon.id ? null : coupon.id)}
                          className="w-8 h-8 bg-yellow-100 text-yellow-600 rounded-full flex items-center justify-center hover:bg-yellow-200 transition-colors"
                        >
                          <MoreVertical className="w-4 h-4" />
                        </button>
                        {openDropdown === coupon.id && (
                          <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg z-10 border border-gray-200">
                            <div className="py-1">
                              <div className="relative">
                                <button
                                  onClick={() => setOpenSubmenu(openSubmenu === coupon.id ? null : coupon.id)}
                                  className="flex items-center justify-between w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                                >
                                  <span>Change Status</span>
                                  <span>&lt;</span>
                                </button>
                                {openSubmenu === coupon.id && (
                                  <div className="absolute right-full top-0 mt-0 w-32 bg-white rounded-md shadow-lg border border-gray-200">
                                    <div className="py-1">
                                      <button
                                        onClick={() => handleStatusChange(coupon.id, 'active')}
                                        className="flex items-center w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                                      >
                                        <span className="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                                        Active
                                      </button>
                                      <button
                                        onClick={() => handleStatusChange(coupon.id, 'inactive')}
                                        className="flex items-center w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                                      >
                                        <span className="w-2 h-2 bg-red-500 rounded-full mr-2"></span>
                                        Inactive
                                      </button>
                                    </div>
                                  </div>
                                )}
                              </div>
                              <button
                                onClick={() => handleDeleteCoupon(coupon.id)}
                                className="flex items-center w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                              >
                                <Trash2 className="w-4 h-4 mr-2" />
                                Delete coupon
                              </button>
                            </div>
                          </div>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={8} className="px-6 py-12 text-center">
                    <div className="flex flex-col items-center">
                      <div className="w-16 h-16 bg-gray-100 rounded-lg flex items-center justify-center mb-4">
                        <Gift className="w-8 h-8 text-gray-400" />
                      </div>
                      <p className="text-gray-500 text-lg">No data</p>
                      <p className="text-gray-400 text-sm">No coupons found for the selected type</p>
                    </div>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Note */}
      {getNoteText() && (
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <p className="text-sm text-blue-800">{getNoteText()}</p>
        </div>
      )}
    </div>
  )
}
