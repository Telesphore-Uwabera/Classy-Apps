import { useState, useEffect } from 'react'
import { Send, Users, Mail, Smartphone, RefreshCw } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'

export default function CloudMessaging() {
  const [formData, setFormData] = useState({
    selectedUsers: '',
    notificationMethod: '',
    title: '',
    description: ''
  })

  const [characterCount, setCharacterCount] = useState(0)
  const [loading, setLoading] = useState(false)
  const [userCounts, setUserCounts] = useState({
    customers: 0,
    drivers: 0,
    vendors: 0,
    all: 0
  })
  const maxCharacters = 120

  useEffect(() => {
    loadUserCounts()
  }, [])

  const loadUserCounts = async () => {
    try {
      const [customers, drivers, vendors] = await Promise.all([
        firebaseService.getCustomers(),
        firebaseService.getDrivers(),
        firebaseService.getVendors()
      ])
      
      setUserCounts({
        customers: customers.length,
        drivers: drivers.length,
        vendors: vendors.length,
        all: customers.length + drivers.length + vendors.length
      })
    } catch (error) {
      console.error('Error loading user counts:', error)
    }
  }

  const handleInputChange = (field: string, value: string) => {
    if (field === 'description') {
      setCharacterCount(value.length)
      if (value.length > maxCharacters) return
    }
    setFormData(prev => ({
      ...prev,
      [field]: value
    }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    
    try {
      // Send notification to Firebase
      const notificationData = {
        title: formData.title,
        description: formData.description,
        targetUsers: formData.selectedUsers,
        method: formData.notificationMethod,
        sentAt: new Date(),
        sentBy: 'admin'
      }
      
      await firebaseService.sendNotification(notificationData)
      
      // Reset form
      setFormData({
        selectedUsers: '',
        notificationMethod: '',
        title: '',
        description: ''
      })
      setCharacterCount(0)
      
      alert('Notification sent successfully!')
    } catch (error) {
      console.error('Error sending notification:', error)
      alert('Failed to send notification. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const isFormValid = formData.selectedUsers && formData.notificationMethod && formData.title && formData.description

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Cloud Messaging</h1>
          <p className="text-gray-600 mt-1">Send notifications to users via Firebase Cloud Messaging</p>
        </div>
        <button 
          onClick={loadUserCounts}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh Counts
        </button>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Select Users */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Select users : <span className="text-red-500">*</span>
            </label>
            <div className="space-y-2">
              {[
                { value: 'customers', label: 'Customers', icon: Users, count: userCounts.customers },
                { value: 'drivers', label: 'Drivers', icon: Users, count: userCounts.drivers },
                { value: 'vendors', label: 'Vendors', icon: Users, count: userCounts.vendors },
                { value: 'all', label: 'All Users', icon: Users, count: userCounts.all }
              ].map((option) => {
                const Icon = option.icon
                return (
                  <label key={option.value} className="flex items-center">
                    <input
                      type="radio"
                      name="selectedUsers"
                      value={option.value}
                      checked={formData.selectedUsers === option.value}
                      onChange={(e) => handleInputChange('selectedUsers', e.target.value)}
                      className="mr-3 text-yellow-600 focus:ring-yellow-500"
                    />
                    <Icon className="w-4 h-4 mr-2 text-gray-600" />
                    <span className="text-sm text-gray-700">{option.label}</span>
                  </label>
                )
              })}
            </div>
          </div>

          {/* Send Notification Via */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Send notification via : <span className="text-red-500">*</span>
            </label>
            <div className="space-y-2">
              {[
                { value: 'push', label: 'Push', icon: Smartphone },
                { value: 'email', label: 'Email', icon: Mail }
              ].map((option) => {
                const Icon = option.icon
                return (
                  <label key={option.value} className="flex items-center">
                    <input
                      type="radio"
                      name="notificationMethod"
                      value={option.value}
                      checked={formData.notificationMethod === option.value}
                      onChange={(e) => handleInputChange('notificationMethod', e.target.value)}
                      className="mr-3 text-yellow-600 focus:ring-yellow-500"
                    />
                    <Icon className="w-4 h-4 mr-2 text-gray-600" />
                    <span className="text-sm text-gray-700">{option.label}</span>
                  </label>
                )
              })}
            </div>
          </div>

          {/* Title */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Title <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              placeholder="Subject"
              value={formData.title}
              onChange={(e) => handleInputChange('title', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
            />
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Description <span className="text-red-500">*</span>
            </label>
            <div className="relative">
              <textarea
                placeholder="Write description here..."
                value={formData.description}
                onChange={(e) => handleInputChange('description', e.target.value)}
                rows={4}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500 resize-none"
              />
              <div className="absolute bottom-2 right-2 text-xs text-gray-500">
                {characterCount}/{maxCharacters}
              </div>
            </div>
          </div>

          {/* Submit Button */}
          <div className="flex justify-end">
            <button
              type="submit"
              disabled={!isFormValid || loading}
              className="flex items-center px-6 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Sending...
                </>
              ) : (
                <>
                  <Send className="w-4 h-4 mr-2" />
                  Send Notification
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
