import { useState, useEffect } from 'react'
import { MapPin, Clock, Car, User, Phone, Navigation, AlertCircle, CheckCircle, XCircle, RefreshCw } from 'lucide-react'
import { trackingService } from '../services/trackingService'
import { Trip, LiveLocation } from '../services/trackingService'
import EnhancedGoogleMaps from '../components/EnhancedGoogleMaps'

export default function EnhancedLiveTracking() {
  const [activeTrips, setActiveTrips] = useState<Trip[]>([])
  const [liveLocations, setLiveLocations] = useState<LiveLocation[]>([])
  const [selectedTrip, setSelectedTrip] = useState<Trip | null>(null)
  const [loading, setLoading] = useState(false)
  const [filter, setFilter] = useState<'all' | 'pending' | 'assigned' | 'picked_up' | 'in_progress'>('all')
  const [lastUpdated, setLastUpdated] = useState<Date>(new Date())

  useEffect(() => {
    loadActiveTrips()
    loadLiveLocations()
    
    // Subscribe to real-time updates
    const unsubscribeTrips = trackingService.subscribeToActiveTrips(setActiveTrips)
    const unsubscribeLocations = trackingService.subscribeToLiveLocations(setLiveLocations)

    // Update timestamp every 30 seconds
    const interval = setInterval(() => {
      setLastUpdated(new Date())
    }, 30000)

    return () => {
      unsubscribeTrips()
      unsubscribeLocations()
      clearInterval(interval)
    }
  }, [])

  const loadActiveTrips = async () => {
    setLoading(true)
    try {
      const trips = await trackingService.getActiveTrips()
      setActiveTrips(trips)
      setLastUpdated(new Date())
    } catch (error) {
      console.error('Error loading active trips:', error)
    } finally {
      setLoading(false)
    }
  }

  const loadLiveLocations = async () => {
    try {
      const locations = await trackingService.getAllLiveLocations()
      setLiveLocations(locations)
    } catch (error) {
      console.error('Error loading live locations:', error)
    }
  }

  const handleAssignTrip = async (tripId: string, driverId: string) => {
    try {
      await trackingService.assignTrip(tripId, driverId, 'admin', 'Manual assignment')
      alert('Trip assigned successfully!')
      loadActiveTrips() // Refresh data
    } catch (error) {
      console.error('Error assigning trip:', error)
      alert('Error assigning trip')
    }
  }

  const handleReassignTrip = async (tripId: string, newDriverId: string) => {
    try {
      await trackingService.reassignTrip(tripId, newDriverId, 'admin', 'Manual reassignment')
      alert('Trip reassigned successfully!')
      loadActiveTrips() // Refresh data
    } catch (error) {
      console.error('Error reassigning trip:', error)
      alert('Error reassigning trip')
    }
  }

  const handleCancelTrip = async (tripId: string) => {
    const reason = prompt('Please provide a cancellation reason:')
    if (!reason) {
      alert('Please provide a cancellation reason')
      return
    }
    
    try {
      await trackingService.cancelTrip(tripId, 'admin', reason)
      alert('Trip cancelled successfully!')
      loadActiveTrips() // Refresh data
    } catch (error) {
      console.error('Error cancelling trip:', error)
      alert('Error cancelling trip')
    }
  }

  const handleTripSelect = (trip: Trip | null) => {
    setSelectedTrip(trip)
  }

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'pending': return 'bg-orange-100 text-orange-800'
      case 'assigned': return 'bg-blue-100 text-blue-800'
      case 'picked_up': return 'bg-purple-100 text-purple-800'
      case 'in_progress': return 'bg-green-100 text-green-800'
      case 'delivered': return 'bg-green-100 text-green-800'
      case 'cancelled': return 'bg-red-100 text-red-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status.toLowerCase()) {
      case 'pending': return <Clock className="w-4 h-4 text-orange-500" />
      case 'assigned': return <User className="w-4 h-4 text-blue-500" />
      case 'picked_up': return <Car className="w-4 h-4 text-purple-500" />
      case 'in_progress': return <Navigation className="w-4 h-4 text-green-500" />
      case 'delivered': return <CheckCircle className="w-4 h-4 text-green-500" />
      case 'cancelled': return <XCircle className="w-4 h-4 text-red-500" />
      default: return <Clock className="w-4 h-4 text-gray-500" />
    }
  }

  const filteredTrips = activeTrips.filter(trip => filter === 'all' || trip.status === filter)

  return (
    <div className="h-screen flex flex-col bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Enhanced Live Tracking</h1>
            <p className="text-gray-600 mt-1">
              Monitor active trips and driver locations in real-time
              {lastUpdated && (
                <span className="text-sm text-gray-500 ml-2">
                  • Last updated: {lastUpdated.toLocaleTimeString()}
                </span>
              )}
            </p>
          </div>
          
          {/* Controls */}
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <label className="text-sm font-medium text-gray-700">Filter:</label>
              <select
                value={filter}
                onChange={(e) => setFilter(e.target.value as any)}
                className="border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="all">All Trips ({activeTrips.length})</option>
                <option value="pending">Pending ({activeTrips.filter(t => t.status === 'pending').length})</option>
                <option value="assigned">Assigned ({activeTrips.filter(t => t.status === 'assigned').length})</option>
                <option value="picked_up">Picked Up ({activeTrips.filter(t => t.status === 'picked_up').length})</option>
                <option value="in_progress">In Progress ({activeTrips.filter(t => t.status === 'in_progress').length})</option>
              </select>
            </div>
            
            <button
              onClick={loadActiveTrips}
              disabled={loading}
              className="bg-blue-500 text-white px-4 py-2 rounded-md text-sm hover:bg-blue-600 disabled:opacity-50 flex items-center space-x-2"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
              <span>{loading ? 'Loading...' : 'Refresh'}</span>
            </button>
          </div>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="px-6 py-4 bg-white border-b border-gray-200">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="bg-orange-50 border border-orange-200 rounded-lg p-4">
            <div className="flex items-center">
              <Clock className="w-8 h-8 text-orange-500" />
              <div className="ml-3">
                <p className="text-sm font-medium text-orange-800">Pending</p>
                <p className="text-2xl font-bold text-orange-900">
                  {activeTrips.filter(t => t.status === 'pending').length}
                </p>
              </div>
            </div>
          </div>
          
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div className="flex items-center">
              <User className="w-8 h-8 text-blue-500" />
              <div className="ml-3">
                <p className="text-sm font-medium text-blue-800">Assigned</p>
                <p className="text-2xl font-bold text-blue-900">
                  {activeTrips.filter(t => t.status === 'assigned').length}
                </p>
              </div>
            </div>
          </div>
          
          <div className="bg-green-50 border border-green-200 rounded-lg p-4">
            <div className="flex items-center">
              <Navigation className="w-8 h-8 text-green-500" />
              <div className="ml-3">
                <p className="text-sm font-medium text-green-800">In Progress</p>
                <p className="text-2xl font-bold text-green-900">
                  {activeTrips.filter(t => t.status === 'in_progress').length}
                </p>
              </div>
            </div>
          </div>
          
          <div className="bg-purple-50 border border-purple-200 rounded-lg p-4">
            <div className="flex items-center">
              <Car className="w-8 h-8 text-purple-500" />
              <div className="ml-3">
                <p className="text-sm font-medium text-purple-800">Drivers Online</p>
                <p className="text-2xl font-bold text-purple-900">
                  {liveLocations.length}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Enhanced Google Maps Component */}
      <div className="flex-1 min-h-0">
        <EnhancedGoogleMaps
          trips={filteredTrips}
          liveLocations={liveLocations}
          selectedTrip={selectedTrip}
          onTripSelect={handleTripSelect}
          onDriverAssign={handleAssignTrip}
          onTripReassign={handleReassignTrip}
          onTripCancel={handleCancelTrip}
        />
      </div>
    </div>
  )
}
