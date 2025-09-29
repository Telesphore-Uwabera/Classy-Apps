import { useState, useEffect } from 'react'
import { Calculator, Settings, TrendingUp, Clock, MapPin, AlertTriangle } from 'lucide-react'
import { fareService } from '../services/fareService'
import { FareConfiguration, FareCalculation, SurgePricing } from '../services/fareService'

export default function FareManagement() {
  const [activeTab, setActiveTab] = useState<'configuration' | 'calculator' | 'surge' | 'history'>('configuration')
  const [config, setConfig] = useState<FareConfiguration | null>(null)
  const [surgeRules, setSurgeRules] = useState<SurgePricing[]>([])
  const [calculation, setCalculation] = useState<FareCalculation | null>(null)
  const [loading, setLoading] = useState(false)

  // Configuration form state
  const [configForm, setConfigForm] = useState({
    baseFarePerKm: 3000,
    delaySurchargePercentage: 35,
    nightWeatherSurchargePercentage: 20,
    highDemandSurchargePercentage: 5,
    waitingTimeSurchargePercentage: 10,
    freeWaitingTimeMinutes: 10,
    maxDelayMinutesPerKm: 6
  })

  // Calculator form state
  const [calcForm, setCalcForm] = useState({
    distanceKm: 5,
    actualTimeMinutes: 20,
    isNightTime: false,
    isBadWeather: false,
    isHighDemand: false,
    waitingTimeMinutes: 5,
    area: ''
  })

  // Surge pricing form state
  const [surgeForm, setSurgeForm] = useState({
    area: '',
    multiplier: 1.2,
    startTime: '18:00',
    endTime: '22:00',
    days: [] as string[],
    isActive: true
  })

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    setLoading(true)
    try {
      const [configData, surgeData] = await Promise.all([
        fareService.getFareConfiguration(),
        fareService.getSurgePricingRules()
      ])
      
      setConfig(configData)
      setSurgeRules(surgeData)
      
      if (configData) {
        setConfigForm({
          baseFarePerKm: configData.baseFarePerKm,
          delaySurchargePercentage: configData.delaySurchargePercentage,
          nightWeatherSurchargePercentage: configData.nightWeatherSurchargePercentage,
          highDemandSurchargePercentage: configData.highDemandSurchargePercentage,
          waitingTimeSurchargePercentage: configData.waitingTimeSurchargePercentage,
          freeWaitingTimeMinutes: configData.freeWaitingTimeMinutes,
          maxDelayMinutesPerKm: configData.maxDelayMinutesPerKm
        })
      }
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleConfigUpdate = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    try {
      await fareService.updateFareConfiguration(configForm)
      await loadData()
      alert('Fare configuration updated successfully!')
    } catch (error) {
      console.error('Error updating configuration:', error)
      alert('Error updating configuration')
    } finally {
      setLoading(false)
    }
  }

  const handleCalculateFare = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    try {
      const result = await fareService.calculateFare(calcForm)
      setCalculation(result)
    } catch (error) {
      console.error('Error calculating fare:', error)
      alert('Error calculating fare')
    } finally {
      setLoading(false)
    }
  }

  const handleCreateSurgeRule = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    try {
      await fareService.createSurgePricing(surgeForm)
      await loadData()
      setSurgeForm({
        area: '',
        multiplier: 1.2,
        startTime: '18:00',
        endTime: '22:00',
        days: [],
        isActive: true
      })
      alert('Surge pricing rule created successfully!')
    } catch (error) {
      console.error('Error creating surge rule:', error)
      alert('Error creating surge rule')
    } finally {
      setLoading(false)
    }
  }

  const toggleDay = (day: string) => {
    setSurgeForm(prev => ({
      ...prev,
      days: prev.days.includes(day)
        ? prev.days.filter(d => d !== day)
        : [...prev.days, day]
    }))
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Fare Management</h1>
        <p className="text-gray-600">Manage fare calculations, surge pricing, and fare configurations</p>
      </div>

      {/* Tabs */}
      <div className="mb-6">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8">
            {[
              { id: 'configuration', label: 'Configuration', icon: Settings },
              { id: 'calculator', label: 'Fare Calculator', icon: Calculator },
              { id: 'surge', label: 'Surge Pricing', icon: TrendingUp },
              { id: 'history', label: 'History', icon: Clock }
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <tab.icon className="w-4 h-4 inline mr-2" />
                {tab.label}
              </button>
            ))}
          </nav>
        </div>
      </div>

      {/* Configuration Tab */}
      {activeTab === 'configuration' && (
        <div className="bg-white rounded-lg shadow">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-medium text-gray-900">Fare Configuration</h2>
            <p className="text-sm text-gray-600">Configure base fares and surcharge percentages</p>
          </div>
          <form onSubmit={handleConfigUpdate} className="p-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Base Fare per KM (UGX)
                </label>
                <input
                  type="number"
                  value={configForm.baseFarePerKm}
                  onChange={(e) => setConfigForm(prev => ({ ...prev, baseFarePerKm: Number(e.target.value) }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Delay Surcharge (%)
                </label>
                <input
                  type="number"
                  value={configForm.delaySurchargePercentage}
                  onChange={(e) => setConfigForm(prev => ({ ...prev, delaySurchargePercentage: Number(e.target.value) }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Night/Weather Surcharge (%)
                </label>
                <input
                  type="number"
                  value={configForm.nightWeatherSurchargePercentage}
                  onChange={(e) => setConfigForm(prev => ({ ...prev, nightWeatherSurchargePercentage: Number(e.target.value) }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  High Demand Surcharge (%)
                </label>
                <input
                  type="number"
                  value={configForm.highDemandSurchargePercentage}
                  onChange={(e) => setConfigForm(prev => ({ ...prev, highDemandSurchargePercentage: Number(e.target.value) }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Waiting Time Surcharge (%)
                </label>
                <input
                  type="number"
                  value={configForm.waitingTimeSurchargePercentage}
                  onChange={(e) => setConfigForm(prev => ({ ...prev, waitingTimeSurchargePercentage: Number(e.target.value) }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Free Waiting Time (minutes)
                </label>
                <input
                  type="number"
                  value={configForm.freeWaitingTimeMinutes}
                  onChange={(e) => setConfigForm(prev => ({ ...prev, freeWaitingTimeMinutes: Number(e.target.value) }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Max Delay per KM (minutes)
                </label>
                <input
                  type="number"
                  value={configForm.maxDelayMinutesPerKm}
                  onChange={(e) => setConfigForm(prev => ({ ...prev, maxDelayMinutesPerKm: Number(e.target.value) }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>
            </div>

            <div className="mt-6">
              <button
                type="submit"
                disabled={loading}
                className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50"
              >
                {loading ? 'Updating...' : 'Update Configuration'}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Calculator Tab */}
      {activeTab === 'calculator' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-lg shadow">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-medium text-gray-900">Fare Calculator</h2>
              <p className="text-sm text-gray-600">Calculate fare using CLASSY UG algorithm</p>
            </div>
            <form onSubmit={handleCalculateFare} className="p-6">
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Distance (KM)
                  </label>
                  <input
                    type="number"
                    step="0.1"
                    value={calcForm.distanceKm}
                    onChange={(e) => setCalcForm(prev => ({ ...prev, distanceKm: Number(e.target.value) }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Actual Time (minutes)
                  </label>
                  <input
                    type="number"
                    value={calcForm.actualTimeMinutes}
                    onChange={(e) => setCalcForm(prev => ({ ...prev, actualTimeMinutes: Number(e.target.value) }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Waiting Time (minutes)
                  </label>
                  <input
                    type="number"
                    value={calcForm.waitingTimeMinutes}
                    onChange={(e) => setCalcForm(prev => ({ ...prev, waitingTimeMinutes: Number(e.target.value) }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Area (for surge pricing)
                  </label>
                  <input
                    type="text"
                    value={calcForm.area}
                    onChange={(e) => setCalcForm(prev => ({ ...prev, area: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="e.g., Kampala CBD"
                  />
                </div>

                <div className="space-y-2">
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={calcForm.isNightTime}
                      onChange={(e) => setCalcForm(prev => ({ ...prev, isNightTime: e.target.checked }))}
                      className="mr-2"
                    />
                    <span className="text-sm text-gray-700">Night Time</span>
                  </label>
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={calcForm.isBadWeather}
                      onChange={(e) => setCalcForm(prev => ({ ...prev, isBadWeather: e.target.checked }))}
                      className="mr-2"
                    />
                    <span className="text-sm text-gray-700">Bad Weather</span>
                  </label>
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={calcForm.isHighDemand}
                      onChange={(e) => setCalcForm(prev => ({ ...prev, isHighDemand: e.target.checked }))}
                      className="mr-2"
                    />
                    <span className="text-sm text-gray-700">High Demand</span>
                  </label>
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700 disabled:opacity-50"
                >
                  {loading ? 'Calculating...' : 'Calculate Fare'}
                </button>
              </div>
            </form>
          </div>

          {/* Calculation Results */}
          <div className="bg-white rounded-lg shadow">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-medium text-gray-900">Fare Breakdown</h2>
            </div>
            <div className="p-6">
              {calculation ? (
                <div className="space-y-4">
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-medium text-gray-900 mb-2">Trip Details</h3>
                    <p className="text-sm text-gray-600">Distance: {calculation.distanceKm} km</p>
                  </div>

                  <div className="space-y-2">
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-600">Base Fare</span>
                      <span className="text-sm font-medium">UGX {calculation.breakdown.baseFare.toLocaleString()}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-600">Delay Adjustment</span>
                      <span className="text-sm font-medium">UGX {calculation.breakdown.delayAdjustment.toLocaleString()}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-600">Night/Weather Charge</span>
                      <span className="text-sm font-medium">UGX {calculation.breakdown.nightWeatherCharge.toLocaleString()}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-600">High Demand Charge</span>
                      <span className="text-sm font-medium">UGX {calculation.breakdown.highDemandCharge.toLocaleString()}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-600">Waiting Time Charge</span>
                      <span className="text-sm font-medium">UGX {calculation.breakdown.waitingTimeCharge.toLocaleString()}</span>
                    </div>
                    <hr />
                    <div className="flex justify-between font-bold text-lg">
                      <span>Total Fare</span>
                      <span>UGX {calculation.breakdown.total.toLocaleString()}</span>
                    </div>
                  </div>
                </div>
              ) : (
                <p className="text-gray-500 text-center py-8">Enter trip details and click "Calculate Fare" to see the breakdown</p>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Surge Pricing Tab */}
      {activeTab === 'surge' && (
        <div className="space-y-6">
          {/* Create Surge Rule */}
          <div className="bg-white rounded-lg shadow">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-medium text-gray-900">Create Surge Pricing Rule</h2>
            </div>
            <form onSubmit={handleCreateSurgeRule} className="p-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Area
                  </label>
                  <input
                    type="text"
                    value={surgeForm.area}
                    onChange={(e) => setSurgeForm(prev => ({ ...prev, area: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="e.g., Kampala CBD"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Multiplier
                  </label>
                  <input
                    type="number"
                    step="0.1"
                    min="1"
                    value={surgeForm.multiplier}
                    onChange={(e) => setSurgeForm(prev => ({ ...prev, multiplier: Number(e.target.value) }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Start Time
                  </label>
                  <input
                    type="time"
                    value={surgeForm.startTime}
                    onChange={(e) => setSurgeForm(prev => ({ ...prev, startTime: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    End Time
                  </label>
                  <input
                    type="time"
                    value={surgeForm.endTime}
                    onChange={(e) => setSurgeForm(prev => ({ ...prev, endTime: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
              </div>

              <div className="mt-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Days
                </label>
                <div className="flex flex-wrap gap-2">
                  {['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'].map(day => (
                    <button
                      key={day}
                      type="button"
                      onClick={() => toggleDay(day)}
                      className={`px-3 py-1 rounded-full text-sm ${
                        surgeForm.days.includes(day)
                          ? 'bg-blue-600 text-white'
                          : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                      }`}
                    >
                      {day.charAt(0).toUpperCase() + day.slice(1)}
                    </button>
                  ))}
                </div>
              </div>

              <div className="mt-6">
                <button
                  type="submit"
                  disabled={loading}
                  className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50"
                >
                  {loading ? 'Creating...' : 'Create Rule'}
                </button>
              </div>
            </form>
          </div>

          {/* Surge Rules List */}
          <div className="bg-white rounded-lg shadow">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-medium text-gray-900">Active Surge Pricing Rules</h2>
            </div>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Area</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Multiplier</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Time</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Days</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {surgeRules.map((rule) => (
                    <tr key={rule.id}>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {rule.area}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {rule.multiplier}x
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {rule.startTime} - {rule.endTime}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {rule.days.join(', ')}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                          rule.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                        }`}>
                          {rule.isActive ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* History Tab */}
      {activeTab === 'history' && (
        <div className="bg-white rounded-lg shadow">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-medium text-gray-900">Fare Calculation History</h2>
            <p className="text-sm text-gray-600">View recent fare calculations and trends</p>
          </div>
          <div className="p-6">
            <p className="text-gray-500 text-center py-8">Fare calculation history will be displayed here</p>
          </div>
        </div>
      )}
    </div>
  )
}
