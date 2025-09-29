import { useState, useEffect } from 'react'
import { Search, Eye, ShoppingCart, MapPin, Clock, DollarSign, MoreVertical, RefreshCw, X } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'

interface Order {
  id: string
  orderId: string
  customerName: string
  orderStatus: 'pending' | 'confirmed' | 'ready_for_pickup' | 'delivered' | 'cancelled'
  deliveryAddress: string
  dateTime: string
  amount: number
  restaurantName: string
  driverName?: string
  driverTip: number
  restaurantAddress: string
  receiverName: string
  receiverPhone: string
  items: OrderItem[]
}

interface OrderItem {
  name: string
  quantity: number
  variant: string
  addons: string
  cookingRequest: string
  price: number
}

export default function Orders() {
  const [orders, setOrders] = useState<Order[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null)
  const [showOrderModal, setShowOrderModal] = useState(false)

  useEffect(() => {
    loadOrders()
  }, [])

  const loadOrders = async () => {
    try {
      setLoading(true)
      const ordersData = await firebaseService.getOrders()
      
      // Get customer and vendor details for each order
      const ordersWithDetails = await Promise.all(
        ordersData.map(async (order: any) => {
          let customerName = 'Unknown Customer'
          let customerPhone = 'No phone'
          let restaurantName = 'Unknown Restaurant'
          
          try {
            if (order.userId) {
              const customer = await firebaseService.getDocument('users', order.userId)
              customerName = customer.name || 'Unknown Customer'
              customerPhone = customer.phone || 'No phone'
            }
            
            if (order.vendorId) {
              const vendor = await firebaseService.getDocument('vendors', order.vendorId)
              restaurantName = vendor.name || 'Unknown Restaurant'
            }
          } catch (error) {
            console.error('Error loading customer/vendor details:', error)
          }
          
          return {
            id: order.id,
            orderId: order.orderNumber || `#${order.id}`,
            customerName,
            orderStatus: order.status || 'pending',
            deliveryAddress: order.deliveryAddress || 'No address',
            dateTime: order.createdAt?.toDate?.()?.toLocaleString() || 'Unknown date',
            amount: order.totalAmount || 0,
            restaurantName,
            driverName: order.driverName || 'Unassigned',
            driverTip: order.driverTip || 0,
            restaurantAddress: order.restaurantAddress || 'No address',
            receiverName: order.receiverName || customerName,
            receiverPhone: order.receiverPhone || customerPhone,
            items: order.items || []
          }
        })
      )
      
      setOrders(ordersWithDetails)
    } catch (error) {
      console.error('Error loading orders:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleStatusChange = async (orderId: string, newStatus: string) => {
    try {
      await firebaseService.updateOrderStatus(orderId, newStatus)
      setOrders(prev => 
        prev.map(order => 
        order.id === orderId 
            ? { ...order, orderStatus: newStatus as any }
          : order
      )
    )
    } catch (error) {
      console.error('Error updating order status:', error)
    }
  }

  const handleViewOrder = (order: Order) => {
    setSelectedOrder(order)
    setShowOrderModal(true)
  }

  const filteredOrders = orders.filter(order => {
    const matchesSearch = order.customerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         order.orderId.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         order.restaurantName.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === 'all' || order.orderStatus === statusFilter
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
      <div className="flex justify-between items-center">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Orders</h1>
          <p className="text-gray-600 mt-1">Manage orders from Firebase</p>
      </div>
            <button
          onClick={loadOrders}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh
            </button>
      </div>

      {/* Search and Filter */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
              placeholder="Search orders..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-transparent"
            />
          </div>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-transparent"
          >
            <option value="all">All Status</option>
            <option value="pending">Pending</option>
            <option value="confirmed">Confirmed</option>
            <option value="preparing">Preparing</option>
            <option value="ready_for_pickup">Ready for Pickup</option>
            <option value="delivered">Delivered</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>
      </div>

      {/* Orders Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Order ID
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Customer
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Restaurant
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredOrders.map((order) => (
                <tr key={order.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{order.orderId}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{order.customerName}</div>
                    <div className="text-sm text-gray-500">{order.receiverPhone}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{order.restaurantName}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">${order.amount}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      order.orderStatus === 'delivered' 
                        ? 'bg-green-100 text-green-800'
                        : order.orderStatus === 'cancelled'
                        ? 'bg-red-100 text-red-800'
                        : order.orderStatus === 'ready_for_pickup'
                        ? 'bg-blue-100 text-blue-800'
                        : order.orderStatus === 'confirmed'
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {order.orderStatus.replace('_', ' ')}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {order.dateTime}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button
                        onClick={() => handleViewOrder(order)}
                        className="text-blue-600 hover:text-blue-900"
                        title="View Order Details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <select
                        value={order.orderStatus}
                        onChange={(e) => handleStatusChange(order.id, e.target.value)}
                        className="text-sm border border-gray-300 rounded px-2 py-1"
                      >
                        <option value="pending">Pending</option>
                        <option value="confirmed">Confirmed</option>
                        <option value="preparing">Preparing</option>
                        <option value="ready_for_pickup">Ready</option>
                        <option value="delivered">Delivered</option>
                        <option value="cancelled">Cancelled</option>
                      </select>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {filteredOrders.length === 0 && (
          <div className="text-center py-12">
            <div className="text-gray-500">No orders found</div>
          </div>
        )}
      </div>

      {/* Order Details Modal */}
      {showOrderModal && selectedOrder && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center p-6 border-b border-gray-200">
              <h3 className="text-lg font-semibold text-gray-900">Order Details</h3>
              <button
                onClick={() => setShowOrderModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="p-6 space-y-6">
              {/* Order Header */}
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-3">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Order ID</label>
                    <p className="text-sm text-gray-900">{selectedOrder.orderId}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Customer</label>
                    <p className="text-sm text-gray-900">{selectedOrder.customerName}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Receiver</label>
                    <p className="text-sm text-gray-900">{selectedOrder.receiverName}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Phone</label>
                    <p className="text-sm text-gray-900">{selectedOrder.receiverPhone}</p>
                  </div>
                </div>
                
                <div className="space-y-3">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Restaurant</label>
                    <p className="text-sm text-gray-900">{selectedOrder.restaurantName}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Driver</label>
                    <p className="text-sm text-gray-900">{selectedOrder.driverName || 'Not assigned'}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Total Amount</label>
                    <p className="text-sm text-gray-900 font-semibold">${selectedOrder.amount}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Status</label>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      selectedOrder.orderStatus === 'delivered' 
                        ? 'bg-green-100 text-green-800'
                        : selectedOrder.orderStatus === 'cancelled'
                        ? 'bg-red-100 text-red-800'
                        : selectedOrder.orderStatus === 'ready_for_pickup'
                        ? 'bg-blue-100 text-blue-800'
                        : selectedOrder.orderStatus === 'confirmed'
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {selectedOrder.orderStatus.replace('_', ' ')}
                    </span>
                  </div>
                </div>
              </div>

              {/* Delivery Address */}
              <div>
                <label className="text-sm font-medium text-gray-500">Delivery Address</label>
                <p className="text-sm text-gray-900">{selectedOrder.deliveryAddress}</p>
              </div>

              {/* Order Items */}
              <div>
                <label className="text-sm font-medium text-gray-500 mb-3 block">Order Items</label>
                <div className="space-y-3">
                  {selectedOrder.items.map((item, index) => (
                    <div key={index} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <h4 className="font-medium text-gray-900">{item.name}</h4>
                          <p className="text-sm text-gray-500">Quantity: {item.quantity}</p>
                          {item.variant && (
                            <p className="text-sm text-gray-500">Variant: {item.variant}</p>
                          )}
                          {item.addons && (
                            <p className="text-sm text-gray-500">Add-ons: {item.addons}</p>
                          )}
                          {item.cookingRequest && (
                            <p className="text-sm text-gray-500">Special Request: {item.cookingRequest}</p>
                          )}
                        </div>
                        <div className="text-sm font-medium text-gray-900">
                          ${item.price}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Order Date */}
              <div>
                <label className="text-sm font-medium text-gray-500">Order Date</label>
                <p className="text-sm text-gray-900">{selectedOrder.dateTime}</p>
              </div>
            </div>
            
            <div className="flex justify-end space-x-3 p-6 border-t border-gray-200">
              <button
                onClick={() => setShowOrderModal(false)}
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
