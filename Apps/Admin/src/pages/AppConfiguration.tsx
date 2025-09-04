import { useState } from 'react'
import { Save, Settings, DollarSign, MapPin, Mail, Phone, Percent } from 'lucide-react'

export default function AppConfiguration() {
  const [config, setConfig] = useState({
    // Driver settings
    baseFee: 10,
    pricePerKm: 5,
    
    // Support settings
    supportEmail: 'support@classy.com',
    supportPhone: '9354949149',
    
    // Tax settings
    taxKeyword: 'Tax',
    taxPercentage: 10,
    
    // Commission settings
    driverCommission: 15,
    restaurantCommission: 15,
    
    // App settings
    platformFees: 10,
    orderTakingRange: 99,
    showRestaurantRange: 99,
    
    // Email settings
    emailAddress: 'noreply@classy.com',
    appPassword: '1234555',
    
    // Social links
    facebookUrl: 'Facebook URL',
    instagramUrl: 'Instagram URL',
    youtubeUrl: 'Youtube URL'
  })

  const [loading, setLoading] = useState(false)

  const handleInputChange = (field: string, value: string | number) => {
    setConfig((prev: any) => ({
      ...prev,
      [field]: value
    }))
  }

  const handleSubmit = async (e: any) => {
    e.preventDefault()
    setLoading(true)
    
    try {
      // Implement save configuration functionality
      console.log('Saving configuration:', config)
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000))
      alert('Configuration saved successfully!')
    } catch (error) {
      console.error('Error saving configuration:', error)
      alert('Error saving configuration')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">App Configuration</h1>
        <p className="text-gray-600 mt-1">Configure application settings and parameters</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Driver Configuration */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-4">
            <Settings className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-800">Driver</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Base fee <span className="text-red-500">*</span>
              </label>
              <input
                type="number"
                value={config.baseFee}
                onChange={(e: any) => handleInputChange('baseFee', parseInt(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Price per km <span className="text-red-500">*</span>
              </label>
              <input
                type="number"
                value={config.pricePerKm}
                onChange={(e: any) => handleInputChange('pricePerKm', parseInt(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Support Configuration */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-4">
            <Phone className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-800">Support</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Email <span className="text-red-500">*</span>
              </label>
              <input
                type="email"
                value={config.supportEmail}
                onChange={(e: any) => handleInputChange('supportEmail', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Call <span className="text-red-500">*</span>
              </label>
              <input
                type="tel"
                value={config.supportPhone}
                onChange={(e: any) => handleInputChange('supportPhone', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Tax Configuration */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-4">
            <Percent className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-800">Tax</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tax keyword <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                value={config.taxKeyword}
                onChange={(e: any) => handleInputChange('taxKeyword', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tax percentage(%) <span className="text-red-500">*</span>
              </label>
              <input
                type="number"
                value={config.taxPercentage}
                onChange={(e: any) => handleInputChange('taxPercentage', parseInt(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Commission Configuration */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-4">
            <DollarSign className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-800">Commission</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Commission of Driver(%) <span className="text-red-500">*</span>
              </label>
              <input
                type="number"
                value={config.driverCommission}
                onChange={(e: any) => handleInputChange('driverCommission', parseInt(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Commission of Restaurant(%) <span className="text-red-500">*</span>
              </label>
              <input
                type="number"
                value={config.restaurantCommission}
                onChange={(e: any) => handleInputChange('restaurantCommission', parseInt(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Email Account Configuration */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-4">
            <Mail className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-800">Email account for sending email</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Email address
              </label>
              <input
                type="email"
                value={config.emailAddress}
                onChange={(e: any) => handleInputChange('emailAddress', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                App password
              </label>
              <input
                type="password"
                value={config.appPassword}
                onChange={(e: any) => handleInputChange('appPassword', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* App Configuration */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-4">
            <Settings className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-800">App</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Platform fees <span className="text-red-500">*</span>
              </label>
              <input
                type="number"
                value={config.platformFees}
                onChange={(e: any) => handleInputChange('platformFees', parseInt(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Order Configuration */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-4">
            <MapPin className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-800">Order</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Order taking range per km <span className="text-red-500">*</span>
              </label>
              <input
                type="number"
                value={config.orderTakingRange}
                onChange={(e: any) => handleInputChange('orderTakingRange', parseInt(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Show restaurant range(Driver) per km <span className="text-red-500">*</span>
              </label>
              <input
                type="number"
                value={config.showRestaurantRange}
                onChange={(e: any) => handleInputChange('showRestaurantRange', parseInt(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Social Links Configuration */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-4">
            <Settings className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-800">Social links</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Facebook URL
              </label>
              <input
                type="url"
                value={config.facebookUrl}
                onChange={(e: any) => handleInputChange('facebookUrl', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Instagram URL
              </label>
              <input
                type="url"
                value={config.instagramUrl}
                onChange={(e: any) => handleInputChange('instagramUrl', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Youtube URL
              </label>
              <input
                type="url"
                value={config.youtubeUrl}
                onChange={(e: any) => handleInputChange('youtubeUrl', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Account Management Section */}
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center mb-4">
            <Settings className="w-5 h-5 text-pink-500 mr-2" />
            <h3 className="text-lg font-semibold text-gray-900">Account Management</h3>
          </div>
          
          <div className="border-t border-gray-200 pt-6">
            <div className="bg-red-50 border border-red-200 rounded-lg p-4">
              <h4 className="text-sm font-medium text-red-800 mb-2">Danger Zone</h4>
              <p className="text-sm text-red-600 mb-4">
                Once you delete your account, there is no going back. Please be certain.
              </p>
              <button
                type="button"
                onClick={() => {
                  if (window.confirm('Are you sure you want to delete your admin account? This action cannot be undone.')) {
                    // Handle delete account logic here
                    alert('Delete account functionality would be implemented here');
                  }
                }}
                className="px-4 py-2 bg-red-600 text-white text-sm font-medium rounded-lg hover:bg-red-700 transition-colors"
              >
                Delete Admin Account
              </button>
            </div>
          </div>
        </div>

        {/* Submit Button */}
        <div className="flex justify-end">
          <button
            type="submit"
            disabled={loading}
            className="flex items-center px-6 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            <Save className="w-4 h-4 mr-2" />
            {loading ? 'Saving...' : 'Submit'}
          </button>
        </div>
      </form>
    </div>
  )
}
