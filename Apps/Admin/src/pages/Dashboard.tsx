import { useState, useEffect } from 'react'
import { Users, Building2, Car, ShoppingCart } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'
import { COLLECTIONS } from '../config/firebase'

interface DashboardStats {
  customers: {
    today: number
    thisWeek: number
    thisMonth: number
    overall: number
  }
  restaurants: {
    today: number
    thisWeek: number
    thisMonth: number
    overall: number
  }
  vendors: {
    today: number
    thisWeek: number
    thisMonth: number
    overall: number
  }
  drivers: {
    today: number
    thisWeek: number
    thisMonth: number
    overall: number
  }
  orders: {
    today: number
    thisWeek: number
    thisMonth: number
    overall: number
  }
}

export default function Dashboard() {
  const navigate = useNavigate()
  const [stats, setStats] = useState<DashboardStats>({
    customers: { today: 0, thisWeek: 0, thisMonth: 0, overall: 0 },
    restaurants: { today: 0, thisWeek: 0, thisMonth: 0, overall: 0 },
    vendors: { today: 0, thisWeek: 0, thisMonth: 0, overall: 0 },
    drivers: { today: 0, thisWeek: 0, thisMonth: 0, overall: 0 },
    orders: { today: 0, thisWeek: 0, thisMonth: 0, overall: 0 }
  })

  const [loading, setLoading] = useState(true)
  const [pendingVendors, setPendingVendors] = useState(0)
  const [pendingDrivers, setPendingDrivers] = useState(0)
  const [pendingRestaurants, setPendingRestaurants] = useState(0)
  const [totalVendors, setTotalVendors] = useState(0)
  const [totalRestaurants, setTotalRestaurants] = useState(0)
  const [totalDrivers, setTotalDrivers] = useState(0)

  useEffect(() => {
    loadDashboardData()
    testFirebaseConnection()
  }, [])

  const testFirebaseConnection = async () => {
    try {
      console.log('Testing Firebase connection...')
      const testData = await firebaseService.getCollection('users')
      console.log('Firebase connection test successful:', testData.length, 'users found')
    } catch (error) {
      console.error('Firebase connection test failed:', error)
    }
  }

  const loadDashboardData = async () => {
    try {
      setLoading(true)
      
      // Get all data from Firebase
      const [customers, allVendors, allRestaurants, allDrivers, allOrders, pendingVendorsData, pendingDriversData] = await Promise.all([
        firebaseService.getCustomers(),
        firebaseService.getCollection(COLLECTIONS.VENDORS).catch(() => []), // Fetch from vendors collection
        firebaseService.getCollection(COLLECTIONS.RESTAURANTS).catch(() => []), // Add restaurants collection
        firebaseService.getCollection('drivers').catch(() => []), // Fetch from drivers collection
        firebaseService.getCollection('orders').catch(() => []), // Fetch from orders collection
        firebaseService.getPendingVendors(),
        firebaseService.getPendingDrivers()
      ])

      // Debug logging to see what data we're getting
      console.log('Firebase Data Loaded:');
      console.log('Customers:', customers);
      console.log('Vendors:', allVendors);
      console.log('Restaurants:', allRestaurants);
      console.log('Drivers:', allDrivers);
      console.log('Orders:', allOrders);
      
      // Data is already separated by collection

      // Calculate today's date
      const today = new Date()
      const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate())
      
      // Calculate this week's start
      const thisWeekStart = new Date(today)
      thisWeekStart.setDate(today.getDate() - today.getDay())
      thisWeekStart.setHours(0, 0, 0, 0)
      
      // Calculate this month's start
      const thisMonthStart = new Date(today.getFullYear(), today.getMonth(), 1)

      // Helper function to filter data by date
      const filterByDate = (data: any[], dateField: string, startDate: Date) => {
        return data.filter(item => {
          // Try different possible field names for creation date
          const dateValue = item[dateField] || item.created_at || item.createdAt || item.updated_at || item.updatedAt
          if (!dateValue) return false
          
          let itemDate: Date
          if (dateValue.toDate) {
            // Firebase Timestamp
            itemDate = dateValue.toDate()
          } else if (typeof dateValue === 'number') {
            // Unix timestamp
            itemDate = new Date(dateValue)
          } else {
            // String date
            itemDate = new Date(dateValue)
          }
          
          return itemDate >= startDate
        }).length
      }

          // Update stats with real Firebase data
          setStats({
            customers: {
              today: filterByDate(customers, 'created_at', todayStart),
              thisWeek: filterByDate(customers, 'created_at', thisWeekStart),
              thisMonth: filterByDate(customers, 'created_at', thisMonthStart),
              overall: customers.length
            },
            restaurants: {
              today: filterByDate(allRestaurants.filter(r => 
                r.status === 'active' || r.status === 'approved' || r.is_active === true
              ), 'created_at', todayStart),
              thisWeek: filterByDate(allRestaurants.filter(r => 
                r.status === 'active' || r.status === 'approved' || r.is_active === true
              ), 'created_at', thisWeekStart),
              thisMonth: filterByDate(allRestaurants.filter(r => 
                r.status === 'active' || r.status === 'approved' || r.is_active === true
              ), 'created_at', thisMonthStart),
              overall: allRestaurants.filter(r => 
                r.status === 'active' || r.status === 'approved' || r.is_active === true
              ).length
            },
            vendors: {
              today: filterByDate(allVendors.filter(v => 
                v.status === 'active' || v.status === 'approved' || v.status === 'online'
              ), 'created_at', todayStart),
              thisWeek: filterByDate(allVendors.filter(v => 
                v.status === 'active' || v.status === 'approved' || v.status === 'online'
              ), 'created_at', thisWeekStart),
              thisMonth: filterByDate(allVendors.filter(v => 
                v.status === 'active' || v.status === 'approved' || v.status === 'online'
              ), 'created_at', thisMonthStart),
              overall: allVendors.filter(v => 
                v.status === 'active' || v.status === 'approved' || v.status === 'online'
              ).length
            },
        drivers: {
          today: filterByDate(allDrivers.filter(d => 
            d.status === 'active' || d.status === 'approved' || 
            (d.is_active === true && !d.status)
          ), 'created_at', todayStart),
          thisWeek: filterByDate(allDrivers.filter(d => 
            d.status === 'active' || d.status === 'approved' || 
            (d.is_active === true && !d.status)
          ), 'created_at', thisWeekStart),
          thisMonth: filterByDate(allDrivers.filter(d => 
            d.status === 'active' || d.status === 'approved' || 
            (d.is_active === true && !d.status)
          ), 'created_at', thisMonthStart),
          overall: allDrivers.filter(d => 
            d.status === 'active' || d.status === 'approved' || 
            (d.is_active === true && !d.status)
          ).length
        },
            orders: {
              today: filterByDate(allOrders, 'created_at', todayStart),
              thisWeek: filterByDate(allOrders, 'created_at', thisWeekStart),
              thisMonth: filterByDate(allOrders, 'created_at', thisMonthStart),
              overall: allOrders.length
            }
      })

          // Separate pending vendors and restaurants
          // For vendors: check for pending status
          const pendingVendorsCount = allVendors.filter(v => 
            v.status === 'pending' || 
            v.status === 'offline' || // Firebase uses 'offline' for pending
            (v.status !== 'active' && v.status !== 'approved' && v.status !== 'online')
          ).length
          setPendingVendors(pendingVendorsCount)
          
          // For restaurants: check for pending status
          const pendingRestaurantsCount = allRestaurants.filter(r => 
            r.status === 'pending' || 
            r.status === 'offline' ||
            (r.status !== 'active' && r.status !== 'approved' && r.is_active !== true)
          ).length
          setPendingRestaurants(pendingRestaurantsCount)
      setPendingDrivers(pendingDriversData.length)
      
      // Set total counts for UI
      setTotalVendors(allVendors.length)
      setTotalRestaurants(allRestaurants.length)
      setTotalDrivers(allDrivers.length)
      
    } catch (error) {
      console.error('Error loading dashboard data:', error)
    } finally {
      setLoading(false)
    }
  }

  const StatCard = ({ 
    title, 
    icon: Icon, 
    data, 
    color = 'blue' 
  }: { 
    title: string
    icon: React.ComponentType<any>
    data: { today: number; thisWeek: number; thisMonth: number; overall: number }
    color?: string
  }) => {
    const colorClasses = {
      blue: 'bg-blue-50 border-blue-200',
      green: 'bg-green-50 border-green-200',
      orange: 'bg-orange-50 border-orange-200',
      pink: 'bg-pink-50 border-pink-200',
      purple: 'bg-purple-50 border-purple-200'
    }

    return (
      <div className={`rounded-lg border-2 p-6 ${colorClasses[color as keyof typeof colorClasses]}`}>
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold text-gray-800 mb-4">{title}</h3>
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Today:</span>
                <span className="font-medium">{data.today}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">This week:</span>
                <span className="font-medium">{data.thisWeek}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">This month:</span>
                <span className="font-medium">{data.thisMonth}</span>
              </div>
              <div className="flex justify-between text-sm font-semibold border-t pt-2">
                <span className="text-gray-800">Overall:</span>
                <span className="text-gray-900">{data.overall}</span>
              </div>
            </div>
          </div>
          <div className="w-12 h-12 bg-white rounded-lg flex items-center justify-center shadow-sm">
            <Icon className="w-6 h-6 text-gray-600" />
          </div>
        </div>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600 mt-1">Loading data from Firebase...</p>
        </div>
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
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600 mt-1">Real-time data from Firebase</p>
        </div>
        <button 
          onClick={loadDashboardData}
          className="px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          Refresh Data
        </button>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">
        <StatCard
          title="Customers"
          icon={Users}
          data={stats.customers}
          color="blue"
        />
        <StatCard
          title="Restaurants"
          icon={Building2}
          data={stats.restaurants}
          color="green"
        />
        <StatCard
          title="Vendors"
          icon={Building2}
          data={stats.vendors}
          color="orange"
        />
        <StatCard
          title="Drivers"
          icon={Car}
          data={stats.drivers}
          color="pink"
        />
        <StatCard
          title="Orders"
          icon={ShoppingCart}
          data={stats.orders}
          color="purple"
        />
      </div>

      {/* Additional Stats */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Restaurants Requested</h3>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Pending Approval:</span>
              <span className="font-medium text-orange-600">{pendingRestaurants}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Approved:</span>
              <span className="font-medium text-green-600">{stats.restaurants.overall - pendingRestaurants}</span>
            </div>
            <div className="flex justify-between text-sm font-semibold border-t pt-2">
              <span className="text-gray-800">Total:</span>
              <span className="text-gray-900">{totalRestaurants}</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Vendors Requested</h3>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Pending Approval:</span>
              <span className="font-medium text-orange-600">{pendingVendors}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Approved:</span>
              <span className="font-medium text-green-600">{stats.vendors.overall}</span>
            </div>
            <div className="flex justify-between text-sm font-semibold border-t pt-2">
              <span className="text-gray-800">Total:</span>
              <span className="text-gray-900">{totalVendors}</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Drivers Requested</h3>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Pending Approval:</span>
              <span className="font-medium text-orange-600">{pendingDrivers}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Approved:</span>
              <span className="font-medium text-green-600">{stats.drivers.overall - pendingDrivers}</span>
            </div>
            <div className="flex justify-between text-sm font-semibold border-t pt-2">
              <span className="text-gray-800">Total:</span>
              <span className="text-gray-900">{totalDrivers}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Quick Actions</h3>
        <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
          <button 
            onClick={() => navigate('/customers')}
            className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer"
          >
            <Users className="w-6 h-6 text-blue-600 mx-auto mb-2" />
            <span className="text-sm font-medium text-gray-700">Manage Customers</span>
          </button>
          <button 
            onClick={() => navigate('/restaurants')}
            className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer"
          >
            <Building2 className="w-6 h-6 text-green-600 mx-auto mb-2" />
            <span className="text-sm font-medium text-gray-700">Manage Restaurants</span>
          </button>
          <button 
            onClick={() => navigate('/vendors')}
            className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer"
          >
            <Building2 className="w-6 h-6 text-orange-600 mx-auto mb-2" />
            <span className="text-sm font-medium text-gray-700">Manage Vendors</span>
          </button>
          <button 
            onClick={() => navigate('/drivers')}
            className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer"
          >
            <Car className="w-6 h-6 text-pink-600 mx-auto mb-2" />
            <span className="text-sm font-medium text-gray-700">Manage Drivers</span>
          </button>
          <button 
            onClick={() => navigate('/orders')}
            className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer"
          >
            <ShoppingCart className="w-6 h-6 text-purple-600 mx-auto mb-2" />
            <span className="text-sm font-medium text-gray-700">View Orders</span>
          </button>
        </div>
      </div>
    </div>
  )
}
