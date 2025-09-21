import { useState, useEffect } from 'react'
import { Save, Settings, DollarSign, MapPin, Mail, Phone, Percent, RefreshCw } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'

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
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    loadConfiguration()
  }, [])

  const loadConfiguration = async () => {
    try {
      setLoading(true)
      const configData = await firebaseService.getDocument('app_config', 'main')
      
      if (configData) {
        setConfig(prev => ({
          ...prev,
          ...configData
        }))
      }
    } catch (error) {
      console.error('Error loading configuration:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleInputChange = (field: string, value: string | number) => {
    setConfig((prev: any) => ({
      ...prev,
      [field]: value
    }))
  }

  const handleSubmit = async (e: any) => {
    e.preventDefault()
    setSaving(true)
    
    try {
      await firebaseService.setDocument('app_config', 'main', {
        ...config,
        updatedAt: new Date()
      })
      
      alert('Configuration saved successfully!')
    } catch (error) {
      console.error('Error saving configuration:', error)
      alert('Error saving configuration')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <div className="space-y-6">
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
          <h1 className="text-3xl font-bold text-gray-900">App Configuration</h1>
          <p className="text-gray-600 mt-1">Manage app settings stored in Firebase</p>
        </div>
        <button 
          onClick={loadConfiguration}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh
        </button>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Driver Settings */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-6">
            <Settings className="w-5 h-5 text-blue-600 mr-2" />
            <h2 className="text-xl font-semibold text-gray-800">Driver Settings</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Base Fee ($)</label>
              <input
                type="number"
                value={config.baseFee}
                onChange={(e) => handleInputChange('baseFee', parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Price per KM ($)</label>
              <input
                type="number"
                step="0.1"
                value={config.pricePerKm}
                onChange={(e) => handleInputChange('pricePerKm', parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Support Settings */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-6">
            <Phone className="w-5 h-5 text-green-600 mr-2" />
            <h2 className="text-xl font-semibold text-gray-800">Support Settings</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Support Email</label>
              <input
                type="email"
                value={config.supportEmail}
                onChange={(e) => handleInputChange('supportEmail', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Support Phone</label>
              <input
                type="tel"
                value={config.supportPhone}
                onChange={(e) => handleInputChange('supportPhone', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Tax Settings */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-6">
            <Percent className="w-5 h-5 text-orange-600 mr-2" />
            <h2 className="text-xl font-semibold text-gray-800">Tax Settings</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Tax Keyword</label>
              <input
                type="text"
                value={config.taxKeyword}
                onChange={(e) => handleInputChange('taxKeyword', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Tax Percentage (%)</label>
              <input
                type="number"
                value={config.taxPercentage}
                onChange={(e) => handleInputChange('taxPercentage', parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Commission Settings */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-6">
            <DollarSign className="w-5 h-5 text-purple-600 mr-2" />
            <h2 className="text-xl font-semibold text-gray-800">Commission Settings</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Driver Commission (%)</label>
              <input
                type="number"
                value={config.driverCommission}
                onChange={(e) => handleInputChange('driverCommission', parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Restaurant Commission (%)</label>
              <input
                type="number"
                value={config.restaurantCommission}
                onChange={(e) => handleInputChange('restaurantCommission', parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* App Settings */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-6">
            <MapPin className="w-5 h-5 text-indigo-600 mr-2" />
            <h2 className="text-xl font-semibold text-gray-800">App Settings</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Platform Fees (%)</label>
              <input
                type="number"
                value={config.platformFees}
                onChange={(e) => handleInputChange('platformFees', parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Order Taking Range (km)</label>
              <input
                type="number"
                value={config.orderTakingRange}
                onChange={(e) => handleInputChange('orderTakingRange', parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Show Restaurant Range (km)</label>
              <input
                type="number"
                value={config.showRestaurantRange}
                onChange={(e) => handleInputChange('showRestaurantRange', parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Email Settings */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-6">
            <Mail className="w-5 h-5 text-red-600 mr-2" />
            <h2 className="text-xl font-semibold text-gray-800">Email Settings</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Email Address</label>
              <input
                type="email"
                value={config.emailAddress}
                onChange={(e) => handleInputChange('emailAddress', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">App Password</label>
              <input
                type="password"
                value={config.appPassword}
                onChange={(e) => handleInputChange('appPassword', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Social Links */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h2 className="text-xl font-semibold text-gray-800 mb-6">Social Media Links</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Facebook URL</label>
              <input
                type="url"
                value={config.facebookUrl}
                onChange={(e) => handleInputChange('facebookUrl', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Instagram URL</label>
              <input
                type="url"
                value={config.instagramUrl}
                onChange={(e) => handleInputChange('instagramUrl', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">YouTube URL</label>
              <input
                type="url"
                value={config.youtubeUrl}
                onChange={(e) => handleInputChange('youtubeUrl', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
              />
            </div>
          </div>
        </div>

        {/* Save Button */}
        <div className="flex justify-end">
          <button
            type="submit"
            disabled={saving}
            className="flex items-center px-6 py-3 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {saving ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Saving...
              </>
            ) : (
              <>
                <Save className="w-4 h-4 mr-2" />
                Save Configuration
              </>
            )}
          </button>
        </div>
      </form>
    </div>
  )
}