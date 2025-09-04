import { useState } from 'react'
import { Car, Eye, Search, Check, X } from 'lucide-react'
import { useNavigate } from 'react-router-dom'

export default function DriversRequested() {
  const navigate = useNavigate()
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('pending')
  
  const [drivers] = useState([
    {
      id: 1,
      name: 'Fhcjxhc',
      email: 'N/A',
      phone: '+91 7597956769',
      vehicle: 'Motorcycle',
      status: 'pending',
      requestedDate: '2025-09-03',
      location: 'Haridwar, Uttarakhand, India'
    },
    {
      id: 2,
      name: 'Gaurav',
      email: 'abcz@yahoo.com',
      phone: '+91 9868583264',
      vehicle: 'Car',
      status: 'pending',
      requestedDate: '2025-08-29',
      location: 'Mumbai, Maharashtra, India'
    },
    {
      id: 3,
      name: 'Swamy',
      email: 'shsd88165@gmail.com',
      phone: '+91 7899467758',
      vehicle: 'Motorcycle',
      status: 'pending',
      requestedDate: '2025-08-20',
      location: 'Bangalore, Karnataka, India'
    },
    {
      id: 4,
      name: 'Khaja',
      email: 'khjjjj@ail.com',
      phone: '+91 7989081826',
      vehicle: 'Car',
      status: 'pending',
      requestedDate: '2025-08-18',
      location: 'Delhi, India'
    },
    {
      id: 5,
      name: 'Haga',
      email: 'babba@yahoo.com',
      phone: '+91 9868583285',
      vehicle: 'Motorcycle',
      status: 'pending',
      requestedDate: '2025-08-18',
      location: 'Pune, Maharashtra, India'
    },
    {
      id: 6,
      name: 'Hasan',
      email: 'shagun12348@yopmail.com',
      phone: '+91 8754646467',
      vehicle: 'Car',
      status: 'pending',
      requestedDate: '2025-08-14',
      location: 'Chennai, Tamil Nadu, India'
    }
  ])

  const filteredDrivers = drivers.filter(driver =>
    driver.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    driver.phone.includes(searchTerm) ||
    driver.email.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved': return 'bg-green-100 text-green-800'
      case 'rejected': return 'bg-red-100 text-red-800'
      case 'pending': return 'bg-yellow-100 text-yellow-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Drivers Requested</h1>
        <p className="text-gray-600 mt-1">Review and manage driver registration requests</p>
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
            placeholder="Search by name or phone number"
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

      {/* Drivers Table */}
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
                  Email
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Phone
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Requested on
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Action
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredDrivers.map((driver, index) => (
                <tr key={driver.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div className="text-sm font-medium text-gray-900">{driver.name}</div>
                      <div className="text-sm text-gray-500">{driver.vehicle}</div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {driver.email}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {driver.phone}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {new Date(driver.requestedDate).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button 
                        onClick={() => navigate(`/drivers-requested/${driver.id}/view`)}
                        className="text-pink-600 hover:text-pink-900"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      {driver.status === 'pending' && (
                        <>
                          <button className="text-green-600 hover:text-green-900">
                            <Check className="w-4 h-4" />
                          </button>
                          <button className="text-red-600 hover:text-red-900">
                            <X className="w-4 h-4" />
                          </button>
                        </>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {filteredDrivers.length === 0 && (
        <div className="text-center py-12">
          <Car className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No driver requests found</h3>
          <p className="text-gray-600">Try adjusting your search or filter criteria.</p>
        </div>
      )}
    </div>
  )
}
