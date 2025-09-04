import { useState, useEffect } from 'react'
import { Send, Users, Mail, Smartphone } from 'lucide-react'

export default function CloudMessaging() {
  const [formData, setFormData] = useState({
    selectedUsers: '',
    notificationMethod: '',
    title: '',
    description: ''
  })

  const [characterCount, setCharacterCount] = useState(0)
  const maxCharacters = 120

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

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // Implement send notification functionality
    console.log('Sending notification:', formData)
  }

  const isFormValid = formData.selectedUsers && formData.notificationMethod && formData.title && formData.description

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Cloud Messaging</h1>
        <p className="text-gray-600 mt-1">Send notifications to users via push notifications or email</p>
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
                { value: 'customers', label: 'Customers', icon: Users },
                { value: 'drivers', label: 'Drivers', icon: Users },
                { value: 'vendors', label: 'Vendors', icon: Users },
                { value: 'particular_customer', label: 'Particular customer', icon: Users },
                { value: 'particular_driver', label: 'Particular driver', icon: Users },
                { value: 'particular_vendor', label: 'Particular vendor', icon: Users }
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
              disabled={!isFormValid}
              className="flex items-center px-6 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <Send className="w-4 h-4 mr-2" />
              Send Notification
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
