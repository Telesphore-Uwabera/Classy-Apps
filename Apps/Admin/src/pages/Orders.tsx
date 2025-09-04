import { useState, useEffect } from 'react'
import { Search, Eye, ShoppingCart, MapPin, Clock, DollarSign, MoreVertical } from 'lucide-react'

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
  const [orders, setOrders] = useState<Order[]>([
    {
      id: '1',
      orderId: '#HFFD9696512',
      customerName: 'Nehmat Test',
      orderStatus: 'ready_for_pickup',
      deliveryAddress: 'C196, Phase 8B, Industrial Area, Sahibzada Ajit Singh Nagar',
      dateTime: '02 Sep 2025 (4:49PM)',
      amount: 40,
      restaurantName: 'City Restaurant',
      driverName: 'Nehmatt',
      driverTip: 0,
      restaurantAddress: 'Teleperformance Mohali, Industrial Area, Sector 75, Sahibzada Ajit Singh Nagar, Punjab 140308, India',
      receiverName: 'Nehmat Test',
      receiverPhone: '+919843194643',
      items: [
        {
          name: 'Aalo pyaz parantha ($40)',
          quantity: 1,
          variant: 'N/A',
          addons: 'N/A',
          cookingRequest: 'N/A',
          price: 40
        }
      ]
    },
    {
      id: '2',
      orderId: '#HFFD9418880',
      customerName: 'Anuj Hf',
      orderStatus: 'confirmed',
      deliveryAddress: 'C196, Phase 8B, Industrial Area, Sahibzada Ajit Singh Nagar',
      dateTime: '20 Aug 2025 (6:49AM)',
      amount: 65,
      restaurantName: 'Pizza Corner',
      driverName: 'John Doe',
      driverTip: 5,
      restaurantAddress: 'Food Street, Sector 75',
      receiverName: 'Anuj Hf',
      receiverPhone: '+919876543210',
      items: [
        {
          name: 'Margherita Pizza',
          quantity: 1,
          variant: 'Large',
          addons: 'Extra Cheese',
          cookingRequest: 'Well Done',
          price: 65
        }
      ]
    },
    {
      id: '3',
      orderId: '#HFFD4942976',
      customerName: 'Shagun Jaswal',
      orderStatus: 'ready_for_pickup',
      deliveryAddress: 'C-196A, 4th floor, Industrial Area, Sahibzada Ajit Singh Nagar',
      dateTime: '11 Aug 2025 (2:29PM)',
      amount: 120,
      restaurantName: 'Burger Palace',
      driverName: 'Mike Smith',
      driverTip: 10,
      restaurantAddress: 'Burger Street, Sector 75',
      receiverName: 'Shagun Jaswal',
      receiverPhone: '+919876543211',
      items: [
        {
          name: 'Chicken Burger Combo',
          quantity: 2,
          variant: 'Spicy',
          addons: 'Extra Sauce',
          cookingRequest: 'N/A',
          price: 120
        }
      ]
    }
  ])

  const [activeTab, setActiveTab] = useState<'active' | 'delivered' | 'cancelled'>('active')
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null)
  const [openDropdown, setOpenDropdown] = useState<string | null>(null)

  const filteredOrders = orders.filter(order => {
    const matchesTab = activeTab === 'active' ? 
      ['pending', 'confirmed', 'ready_for_pickup'].includes(order.orderStatus) :
      order.orderStatus === activeTab
    const matchesSearch = order.orderId.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         order.customerName.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesTab && matchesSearch
  })

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending':
        return 'bg-yellow-100 text-yellow-800'
      case 'confirmed':
        return 'bg-blue-100 text-blue-800'
      case 'ready_for_pickup':
        return 'bg-orange-100 text-orange-800'
      case 'delivered':
        return 'bg-green-100 text-green-800'
      case 'cancelled':
        return 'bg-red-100 text-red-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'ready_for_pickup':
        return 'Ready for pickup'
      case 'confirmed':
        return 'Order confirmed'
      default:
        return status.charAt(0).toUpperCase() + status.slice(1).replace('_', ' ')
    }
  }

  const handleStatusChange = (orderId: string, newStatus: 'delivered' | 'cancelled') => {
    setOrders(prevOrders => 
      prevOrders.map(order => 
        order.id === orderId 
          ? { ...order, orderStatus: newStatus }
          : order
      )
    )
    setOpenDropdown(null)
  }

  const OrderDetailsModal = ({ order, onClose }: { order: Order, onClose: () => void }) => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-4xl w-full mx-4 max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Order Details</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            ×
          </button>
        </div>
        
        <div className="space-y-6">
          {/* Order Information */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <h5 className="font-medium text-gray-900 mb-3">Order Information</h5>
              <div className="space-y-2">
                <div>
                  <span className="text-sm font-medium text-gray-700">Order ID:</span>
                  <p className="text-gray-900">{order.orderId}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Status:</span>
                  <span className={`inline-block px-2 py-1 rounded-full text-xs font-medium ml-2 ${getStatusColor(order.orderStatus)}`}>
                    {getStatusLabel(order.orderStatus)}
                  </span>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Restaurant:</span>
                  <p className="text-gray-900">{order.restaurantName}</p>
                </div>
              </div>
            </div>
            
            <div>
              <h5 className="font-medium text-gray-900 mb-3">Customer Information</h5>
              <div className="space-y-2">
                <div>
                  <span className="text-sm font-medium text-gray-700">Customer:</span>
                  <p className="text-gray-900">{order.customerName}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Receiver:</span>
                  <p className="text-gray-900">{order.receiverName}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Phone:</span>
                  <p className="text-gray-900">{order.receiverPhone}</p>
                </div>
              </div>
            </div>
            
            <div>
              <h5 className="font-medium text-gray-900 mb-3">Delivery Information</h5>
              <div className="space-y-2">
                <div>
                  <span className="text-sm font-medium text-gray-700">Driver:</span>
                  <p className="text-gray-900">{order.driverName || 'Not assigned'}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Driver Tip:</span>
                  <p className="text-gray-900">${order.driverTip}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-700">Date & Time:</span>
                  <p className="text-gray-900">{order.dateTime}</p>
                </div>
              </div>
            </div>
          </div>
          
          {/* Addresses */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h5 className="font-medium text-gray-900 mb-3">Restaurant Address</h5>
              <p className="text-sm text-gray-700">{order.restaurantAddress}</p>
            </div>
            <div>
              <h5 className="font-medium text-gray-900 mb-3">Delivery Address</h5>
              <p className="text-sm text-gray-700">{order.deliveryAddress}</p>
            </div>
          </div>
          
          {/* Order Items */}
          <div>
            <h5 className="font-medium text-gray-900 mb-3">Cart Items</h5>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Quantity</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Variant</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Add-ons</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cooking Request</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Price</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {order.items.map((item, index) => (
                    <tr key={index}>
                      <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-900">{item.name}</td>
                      <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-900">{item.quantity}</td>
                      <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-900">{item.variant}</td>
                      <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-900">{item.addons}</td>
                      <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-900">{item.cookingRequest}</td>
                      <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-900">${item.price}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  )

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Orders</h1>
        <p className="text-gray-600 mt-1">Manage and track customer orders</p>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          {[
            { key: 'active', label: 'Active' },
            { key: 'delivered', label: 'Delivered' },
            { key: 'cancelled', label: 'Cancelled' }
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
            placeholder="Search by order id"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
          />
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Sr. no.
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Order id
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Customer name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Order status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Delivery address
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date and time
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Action
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredOrders.map((order, index) => (
                <tr key={order.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {order.orderId}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {order.customerName}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-block px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(order.orderStatus)}`}>
                      {getStatusLabel(order.orderStatus)}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate">
                    {order.deliveryAddress}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {order.dateTime}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => setSelectedOrder(order)}
                        className="w-8 h-8 bg-yellow-100 text-yellow-600 rounded-full flex items-center justify-center hover:bg-yellow-200 transition-colors"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <div className="relative">
                        <button
                          onClick={() => setOpenDropdown(openDropdown === order.id ? null : order.id)}
                          className="w-8 h-8 bg-yellow-100 text-yellow-600 rounded-full flex items-center justify-center hover:bg-yellow-200 transition-colors"
                        >
                          <MoreVertical className="w-4 h-4" />
                        </button>
                        {openDropdown === order.id && (
                          <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg z-10 border border-gray-200">
                            <div className="py-1">
                              <button
                                onClick={() => handleStatusChange(order.id, 'delivered')}
                                className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                              >
                                Delivered
                              </button>
                              <button
                                onClick={() => handleStatusChange(order.id, 'cancelled')}
                                className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                              >
                                Cancelled
                              </button>
                            </div>
                          </div>
                        )}
                      </div>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Order Details Modal */}
      {selectedOrder && (
        <OrderDetailsModal 
          order={selectedOrder} 
          onClose={() => setSelectedOrder(null)} 
        />
      )}
    </div>
  )
}
