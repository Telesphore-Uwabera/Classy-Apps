import { useState } from 'react'
import { ArrowLeft, Check, X, Clock, MapPin, Phone, Mail, Building2 } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'

export default function RestaurantDetails() {
  const navigate = useNavigate()
  const { id } = useParams()
  
  // Mock data - in real app, fetch based on id
  const restaurant = {
    id: id || '1',
    name: 'Test',
    phone: '+919494949464',
    address: 'Teleperformance Mohali, Teleperformance Mohali, Industrial Area, Sahibzada Ajit Singh Nagar',
    owner: {
      name: 'Test',
      email: 'shagun567@yopmail.com',
      phone: '+918454646464',
      preferredLanguage: 'English',
      bankAccount: '000123456'
    },
    joinedDate: '2025-08-26',
    status: 'SUBMITTED',
    timings: {
      monday: '05:24 - 23:24',
      tuesday: '05:24 - 23:24',
      wednesday: '05:24 - 23:24',
      thursday: '05:24 - 23:24',
      friday: '05:24 - 23:24',
      saturday: '05:24 - 23:24',
      sunday: '05:24 - 23:24'
    },
    menu: [
      {
        id: 1,
        name: 'Test',
        description: 'Test',
        price: '$20'
      }
    ]
  }

  const handleAccept = () => {
    // Handle accept logic
    console.log('Accepting restaurant:', restaurant.id)
    // Navigate back to list
    navigate('/restaurants-requested')
  }

  const handleReject = () => {
    // Handle reject logic
    console.log('Rejecting restaurant:', restaurant.id)
    // Navigate back to list
    navigate('/restaurants-requested')
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center space-x-4">
        <button
          onClick={() => navigate('/restaurants-requested')}
          className="flex items-center text-gray-600 hover:text-gray-900"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Back
        </button>
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Restaurant Requested</h1>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column - Restaurant Info */}
        <div className="lg:col-span-2 space-y-6">
          {/* Restaurant Profile */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-start space-x-4">
              <div className="w-16 h-16 bg-gradient-to-r from-pink-400 to-rose-500 rounded-full flex items-center justify-center">
                <Building2 className="w-8 h-8 text-white" />
              </div>
              <div className="flex-1">
                <h2 className="text-2xl font-bold text-gray-900">{restaurant.name}</h2>
                <p className="text-gray-600">Joined on: {new Date(restaurant.joinedDate).toLocaleDateString()}</p>
              </div>
            </div>
            
            <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-3">
                <div className="flex items-center">
                  <Phone className="w-4 h-4 text-gray-400 mr-2" />
                  <span className="text-sm text-gray-600">{restaurant.phone}</span>
                </div>
                <div className="flex items-start">
                  <MapPin className="w-4 h-4 text-gray-400 mr-2 mt-1" />
                  <span className="text-sm text-gray-600">{restaurant.address}</span>
                </div>
              </div>
            </div>
          </div>

          {/* Timings */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Timings</h3>
            <div className="space-y-2">
              {Object.entries(restaurant.timings).map(([day, time]) => (
                <div key={day} className="flex justify-between items-center py-2 border-b border-gray-100 last:border-b-0">
                  <span className="text-sm font-medium text-gray-700 capitalize">{day}</span>
                  <span className="text-sm text-gray-600">{time}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Menu */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Menu</h3>
            <h4 className="text-md font-medium text-gray-700 mb-3">Main Course</h4>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="text-left py-2 text-sm font-medium text-gray-500">Sr. no.</th>
                    <th className="text-left py-2 text-sm font-medium text-gray-500">Name</th>
                    <th className="text-left py-2 text-sm font-medium text-gray-500">Description</th>
                    <th className="text-left py-2 text-sm font-medium text-gray-500">Price</th>
                  </tr>
                </thead>
                <tbody>
                  {restaurant.menu.map((item, index) => (
                    <tr key={item.id} className="border-b border-gray-100">
                      <td className="py-2 text-sm text-gray-900">{index + 1}</td>
                      <td className="py-2 text-sm text-gray-900">{item.name}</td>
                      <td className="py-2 text-sm text-gray-900">{item.description}</td>
                      <td className="py-2 text-sm text-gray-900">{item.price}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        {/* Right Column - Owner Details & Actions */}
        <div className="space-y-6">
          {/* Owner Details */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Owner Details</h3>
            <div className="space-y-3">
              <div>
                <label className="text-sm font-medium text-gray-500">Name</label>
                <p className="text-sm text-gray-900">{restaurant.owner.name}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Email</label>
                <p className="text-sm text-gray-900">{restaurant.owner.email}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Preferred Language</label>
                <p className="text-sm text-gray-900">{restaurant.owner.preferredLanguage}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Phone</label>
                <p className="text-sm text-gray-900">{restaurant.owner.phone}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Bank Account No.</label>
                <p className="text-sm text-gray-900">{restaurant.owner.bankAccount}</p>
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="space-y-3">
              <button
                onClick={handleAccept}
                className="w-full flex items-center justify-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
              >
                <Check className="w-4 h-4 mr-2" />
                Accept
              </button>
              <button
                onClick={handleReject}
                className="w-full flex items-center justify-center px-4 py-2 bg-white text-red-600 border border-red-600 rounded-lg hover:bg-red-50 transition-colors"
              >
                <X className="w-4 h-4 mr-2" />
                Reject
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
