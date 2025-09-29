import { useState } from 'react'
import { ArrowLeft, Check, X, Car, MapPin, Phone, Mail, Calendar } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'

export default function DriverDetails() {
  const navigate = useNavigate()
  const { id } = useParams()
  
  // Mock data - in real app, fetch based on id
  const driver = {
    id: id || '1',
    name: 'Fhcjxhc',
    phone: '+9********769',
    email: 'N/A',
    vehicle: 'Motorcycle / Scooty',
    workLocation: 'Haridwar, Uttarakhand, India',
    status: 'pending',
    requestedDate: '2025-09-03',
    logo: 'Eshanva', // This would be the driver's logo/brand
    drivingLicense: {
      expiresOn: 'Set expiry date',
      frontImage: null,
      backImage: null
    }
  }

  const handleAccept = () => {
    // Handle accept logic
    console.log('Accepting driver:', driver.id)
    // Navigate back to list
    navigate('/drivers-requested')
  }

  const handleReject = () => {
    // Handle reject logic
    console.log('Rejecting driver:', driver.id)
    // Navigate back to list
    navigate('/drivers-requested')
  }

  const handleSetExpiryDate = () => {
    // Handle set expiry date logic
    console.log('Setting expiry date for driver:', driver.id)
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center space-x-4">
        <button
          onClick={() => navigate('/drivers-requested')}
          className="flex items-center text-gray-600 hover:text-gray-900"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Back
        </button>
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Drivers Requested Details</h1>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column - Driver Info */}
        <div className="lg:col-span-2 space-y-6">
          {/* Driver Profile */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-start space-x-4">
              <div className="w-16 h-16 bg-black rounded-full flex items-center justify-center">
                <span className="text-white font-bold text-lg">E</span>
              </div>
              <div className="flex-1">
                <h2 className="text-2xl font-bold text-gray-900">{driver.name}</h2>
                <p className="text-gray-600">Requested on: {new Date(driver.requestedDate).toLocaleDateString()}</p>
              </div>
            </div>
            
            <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-3">
                <div className="flex items-center">
                  <Phone className="w-4 h-4 text-gray-400 mr-2" />
                  <span className="text-sm text-gray-600">{driver.phone}</span>
                </div>
                <div className="flex items-center">
                  <Mail className="w-4 h-4 text-gray-400 mr-2" />
                  <span className="text-sm text-gray-600">{driver.email}</span>
                </div>
                <div className="flex items-center">
                  <Car className="w-4 h-4 text-gray-400 mr-2" />
                  <span className="text-sm text-gray-600">{driver.vehicle}</span>
                </div>
                <div className="flex items-start">
                  <MapPin className="w-4 h-4 text-gray-400 mr-2 mt-1" />
                  <span className="text-sm text-gray-600">{driver.workLocation}</span>
                </div>
              </div>
            </div>
          </div>

          {/* Driving License */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Driving License</h3>
              <span className="px-2 py-1 bg-green-100 text-green-800 text-xs font-semibold rounded-full">
                Updated
              </span>
            </div>
            
            <div className="mb-4">
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Expires on: {driver.drivingLicense.expiresOn}</span>
                <button
                  onClick={handleSetExpiryDate}
                  className="px-3 py-1 bg-pink-500 text-white text-sm rounded-lg hover:bg-pink-600 transition-colors"
                >
                  Set date
                </button>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Front image</label>
                <div className="w-full h-32 bg-gray-100 rounded-lg flex items-center justify-center border-2 border-dashed border-gray-300">
                  <span className="text-gray-500 text-sm">No image uploaded</span>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Back image</label>
                <div className="w-full h-32 bg-gray-100 rounded-lg flex items-center justify-center border-2 border-dashed border-gray-300">
                  <span className="text-gray-500 text-sm">No image uploaded</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Right Column - Actions */}
        <div className="space-y-6">
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
