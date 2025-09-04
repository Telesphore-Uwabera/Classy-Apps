import { useState } from 'react'
import { ArrowLeft, Edit, Car, MapPin, Phone, Mail, FileCheck } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'

export default function DriverDocsDetails() {
  const navigate = useNavigate()
  const { id } = useParams()
  
  // Mock data - in real app, fetch based on id
  const driver = {
    id: id || '1',
    name: 'MRbiz',
    phone: '+9********111',
    email: 'mrb*************',
    vehicle: 'Electric Vehicle (EV)',
    status: 'submitted',
    createdDate: '2025-08-26',
    drivingLicense: {
      expiresOn: '30 Aug 2025',
      frontImages: [
        { id: 1, name: 'Desserts', type: 'food' },
        { id: 2, name: 'Burger', type: 'food' },
        { id: 3, name: 'Chicken', type: 'food' },
        { id: 4, name: 'Main Course', type: 'food' }
      ],
      backImages: [
        { id: 1, name: 'Desserts', type: 'food' },
        { id: 2, name: 'Burger', type: 'food' },
        { id: 3, name: 'Chicken', type: 'food' },
        { id: 4, name: 'Main Course', type: 'food' }
      ]
    }
  }

  const handleEdit = () => {
    // Handle edit logic
    console.log('Editing driver docs:', driver.id)
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center space-x-4">
        <button
          onClick={() => navigate('/drivers-docs-updated')}
          className="flex items-center text-gray-600 hover:text-gray-900"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Back
        </button>
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Docs Updated Details</h1>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column - Driver Info */}
        <div className="lg:col-span-2 space-y-6">
          {/* Driver Profile */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-start space-x-4">
              <div className="w-16 h-16 bg-gradient-to-r from-pink-400 to-rose-500 rounded-full flex items-center justify-center">
                <Car className="w-8 h-8 text-white" />
              </div>
              <div className="flex-1">
                <h2 className="text-2xl font-bold text-gray-900">{driver.name}</h2>
                <p className="text-gray-600">Created on: {new Date(driver.createdDate).toLocaleDateString()}</p>
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
              </div>
            </div>
          </div>

          {/* Driving License */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Driving License</h3>
              <div className="flex items-center space-x-2">
                <span className="px-2 py-1 bg-green-100 text-green-800 text-xs font-semibold rounded-full">
                  Updated
                </span>
                <button
                  onClick={handleEdit}
                  className="px-3 py-1 bg-pink-500 text-white text-sm rounded-lg hover:bg-pink-600 transition-colors"
                >
                  Edit
                </button>
              </div>
            </div>
            
            <div className="mb-4">
              <span className="text-sm text-gray-600">Expires on: {driver.drivingLicense.expiresOn}</span>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-3">Front image</label>
                <div className="grid grid-cols-2 gap-2">
                  {driver.drivingLicense.frontImages.map((image) => (
                    <div key={image.id} className="relative">
                      <div className="w-full h-20 bg-gray-100 rounded-lg flex items-center justify-center border border-gray-200">
                        <span className="text-xs text-gray-500">{image.name}</span>
                      </div>
                      {image.name === 'Burger' && (
                        <div className="absolute top-1 right-1 w-4 h-4 bg-blue-500 rounded-full flex items-center justify-center">
                          <span className="text-white text-xs">👁</span>
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-3">Back image</label>
                <div className="grid grid-cols-2 gap-2">
                  {driver.drivingLicense.backImages.map((image) => (
                    <div key={image.id} className="relative">
                      <div className="w-full h-20 bg-gray-100 rounded-lg flex items-center justify-center border border-gray-200">
                        <span className="text-xs text-gray-500">{image.name}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Quick Picks Section */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center space-x-2 mb-4">
              <div className="w-1 h-6 bg-pink-500 rounded"></div>
              <h3 className="text-lg font-semibold text-gray-900">Quick Picks For You</h3>
            </div>
            <div className="flex items-center space-x-4">
              <div className="w-12 h-12 bg-gray-200 rounded-full flex items-center justify-center">
                <span className="text-gray-600 text-sm">👳</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">More content available...</p>
              </div>
            </div>
          </div>
        </div>

        {/* Right Column - Actions */}
        <div className="space-y-6">
          {/* Status Card */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Document Status</h3>
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Status</span>
                <span className="px-2 py-1 bg-blue-100 text-blue-800 text-xs font-semibold rounded-full">
                  {driver.status.charAt(0).toUpperCase() + driver.status.slice(1)}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Last Updated</span>
                <span className="text-sm text-gray-900">{new Date(driver.createdDate).toLocaleDateString()}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
