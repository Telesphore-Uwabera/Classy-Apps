import { useState } from 'react'
import { Users, Building2, Car, ShoppingCart } from 'lucide-react'

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
  const [stats, setStats] = useState<DashboardStats>({
    customers: { today: 0, thisWeek: 3, thisMonth: 3, overall: 73 },
    restaurants: { today: 0, thisWeek: 0, thisMonth: 0, overall: 33 },
    drivers: { today: 1, thisWeek: 2, thisMonth: 2, overall: 19 },
    orders: { today: 0, thisWeek: 7, thisMonth: 5, overall: 156 }
  })

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

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-1">Welcome to Classy Admin Dashboard</p>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
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
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Restaurants Requested</h3>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Today:</span>
              <span className="font-medium">0</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">This week:</span>
              <span className="font-medium">0</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">This month:</span>
              <span className="font-medium">0</span>
            </div>
            <div className="flex justify-between text-sm font-semibold border-t pt-2">
              <span className="text-gray-800">Overall:</span>
              <span className="text-gray-900">1</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Drivers Requested</h3>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Today:</span>
              <span className="font-medium">0</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">This week:</span>
              <span className="font-medium">0</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">This month:</span>
              <span className="font-medium">0</span>
            </div>
            <div className="flex justify-between text-sm font-semibold border-t pt-2">
              <span className="text-gray-800">Overall:</span>
              <span className="text-gray-900">15</span>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Quick Actions</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <button className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
            <Users className="w-6 h-6 text-blue-600 mx-auto mb-2" />
            <span className="text-sm font-medium text-gray-700">Manage Customers</span>
          </button>
          <button className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
            <Building2 className="w-6 h-6 text-green-600 mx-auto mb-2" />
            <span className="text-sm font-medium text-gray-700">Manage Restaurants</span>
          </button>
          <button className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
            <Car className="w-6 h-6 text-pink-600 mx-auto mb-2" />
            <span className="text-sm font-medium text-gray-700">Manage Drivers</span>
          </button>
          <button className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
            <ShoppingCart className="w-6 h-6 text-purple-600 mx-auto mb-2" />
            <span className="text-sm font-medium text-gray-700">View Orders</span>
          </button>
        </div>
      </div>
    </div>
  )
}
