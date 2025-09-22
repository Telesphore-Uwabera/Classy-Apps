import { useState, useEffect } from 'react'
import { MapPin, Clock, Car, User, Phone, Navigation, AlertCircle, CheckCircle, XCircle } from 'lucide-react'
import { trackingService } from '../services/trackingService'
import { Trip, LiveLocation } from '../services/trackingService'

export default function LiveTracking() {
  const [activeTrips, setActiveTrips] = useState<Trip[]>([])
  const [liveLocations, setLiveLocations] = useState<LiveLocation[]>([])
  const [selectedTrip, setSelectedTrip] = useState<Trip | null>(null)
  const [loading, setLoading] = useState(false)
  const [filter, setFilter] = useState<'all' | 'pending' | 'assigned' | 'picked_up' | 'in_progress'>('all')

  useEffect(() => {
    loadActiveTrips()
    loadLiveLocations()
    
    // Subscribe to real-time updates
    const unsubscribeTrips = trackingService.subscribeToActiveTrips(setActiveTrips)
    const unsubscribeLocations = trackingService.subscribeToLiveLocations(setLiveLocations)

    return () => {
      unsubscribeTrips()
      unsubscribeLocations()
    }
  }, [])

  const loadActiveTrips = async () => {
    setLoading(true)
    try {
      const trips = await trackingService.getActiveTrips()
      setActiveTrips(trips)
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
    } catch (error) {
      console.error('Error assigning trip:', error)
      alert('Error assigning trip')
    }
  }

  const handleReassignTrip = async (tripId: string, newDriverId: string) => {
    try {
      await trackingService.reassignTrip(tripId, newDriverId, 'admin', 'Manual reassignment')
      alert('Trip reassigned successfully!')
    } catch (error) {
      console.error('Error reassigning trip:', error)
      alert('Error reassigning trip')
    }
  }

  const handleCancelTrip = async (tripId: string, reason: string) => {
    if (!reason) {
      alert('Please provide a cancellation reason')
      return
    }
    
    try {
      await trackingService.cancelTrip(tripId, 'admin', reason)
      alert('Trip cancelled successfully!')
    } catch (error) {
      console.error('Error cancelling trip:', error)
      alert('Error cancelling trip')
    }
  }

  const handleUpdateStatus = async (tripId: string, status: Trip['status']) => {
    try {
      await trackingService.updateTripStatus(tripId, status, 'admin')
      alert('Trip status updated successfully!')
    } catch (error) {
      console.error('Error updating trip status:', error)
      alert('Error updating trip status')
    }
  }

  const getStatusIcon = (status: Trip['status']) => {
    switch (status) {
      case 'pending':
        return <Clock className="w-4 h-4 text-yellow-500" />
      case 'assigned':
        return <User className="w-4 h-4 text-blue-500" />
      case 'picked_up':
        return <CheckCircle className="w-4 h-4 text-green-500" />
      case 'in_progress':
        return <Navigation className="w-4 h-4 text-purple-500" />
      case 'completed':
        return <CheckCircle className="w-4 h-4 text-green-600" />
      case 'cancelled':
        return <XCircle className="w-4 h-4 text-red-500" />
      default:
        return <AlertCircle className="w-4 h-4 text-gray-500" />
    }
  }

  const getStatusColor = (status: Trip['status']) => {
    switch (status) {
      case 'pending':
        return 'bg-yellow-100 text-yellow-800'
      case 'assigned':
        return 'bg-blue-100 text-blue-800'
      case 'picked_up':
        return 'bg-green-100 text-green-800'
      case 'in_progress':
        return 'bg-purple-100 text-purple-800'
      case 'completed':
        return 'bg-green-100 text-green-800'
      case 'cancelled':
        return 'bg-red-100 text-red-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const filteredTrips = activeTrips.filter(trip => 
    filter === 'all' || trip.status === filter
  )

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Live Tracking</h1>
        <p className="text-gray-600">Monitor active trips and driver locations in real-time</p>
      </div>

      {/* Filter Tabs */}
      <div className="mb-6">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8">
            {[
              { id: 'all', label: 'All Trips', count: activeTrips.length },
              { id: 'pending', label: 'Pending', count: activeTrips.filter(t => t.status === 'pending').length },
              { id: 'assigned', label: 'Assigned', count: activeTrips.filter(t => t.status === 'assigned').length },
              { id: 'picked_up', label: 'Picked Up', count: activeTrips.filter(t => t.status === 'picked_up').length },
              { id: 'in_progress', label: 'In Progress', count: activeTrips.filter(t => t.status === 'in_progress').length }
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setFilter(tab.id as any)}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  filter === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {tab.label} ({tab.count})
              </button>
            ))}
          </nav>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Trips List */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-medium text-gray-900">Active Trips</h2>
            </div>
            <div className="divide-y divide-gray-200">
              {loading ? (
                <div className="p-6 text-center">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
                  <p className="mt-2 text-gray-500">Loading trips...</p>
                </div>
              ) : filteredTrips.length === 0 ? (
                <div className="p-6 text-center text-gray-500">
                  No active trips found
                </div>
              ) : (
                filteredTrips.map((trip) => (
                  <div
                    key={trip.id}
                    className={`p-6 hover:bg-gray-50 cursor-pointer ${
                      selectedTrip?.id === trip.id ? 'bg-blue-50 border-l-4 border-blue-500' : ''
                    }`}
                    onClick={() => setSelectedTrip(trip)}
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="flex items-center space-x-2 mb-2">
                          {getStatusIcon(trip.status)}
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(trip.status)}`}>
                            {trip.status.replace('_', ' ').toUpperCase()}
                          </span>
                          <span className="text-sm text-gray-500">#{trip.id.slice(-6)}</span>
                        </div>
                        
                        <div className="space-y-1">
                          <div className="flex items-center space-x-2">
                            <MapPin className="w-4 h-4 text-gray-400" />
                            <span className="text-sm text-gray-600">{trip.pickupLocation.address}</span>
                          </div>
                          <div className="flex items-center space-x-2">
                            <MapPin className="w-4 h-4 text-gray-400" />
                            <span className="text-sm text-gray-600">{trip.dropoffLocation.address}</span>
                          </div>
                        </div>

                        <div className="mt-2 flex items-center space-x-4 text-sm text-gray-500">
                          <span>UGX {trip.fare.toLocaleString()}</span>
                          <span>{trip.distance} km</span>
                          <span>{trip.estimatedDuration} min</span>
                        </div>

                        {trip.driverName && (
                          <div className="mt-2 flex items-center space-x-2">
                            <User className="w-4 h-4 text-gray-400" />
                            <span className="text-sm text-gray-600">{trip.driverName}</span>
                            <Phone className="w-4 h-4 text-gray-400" />
                            <span className="text-sm text-gray-600">{trip.driverPhone}</span>
                          </div>
                        )}
                      </div>

                      <div className="flex space-x-2">
                        {trip.status === 'pending' && (
                          <button
                            onClick={(e) => {
                              e.stopPropagation()
                              const driverId = prompt('Enter driver ID:')
                              if (driverId) handleAssignTrip(trip.id, driverId)
                            }}
                            className="px-3 py-1 bg-blue-600 text-white text-xs rounded hover:bg-blue-700"
                          >
                            Assign
                          </button>
                        )}
                        
                        {trip.status === 'assigned' && (
                          <button
                            onClick={(e) => {
                              e.stopPropagation()
                              const newDriverId = prompt('Enter new driver ID:')
                              if (newDriverId) handleReassignTrip(trip.id, newDriverId)
                            }}
                            className="px-3 py-1 bg-yellow-600 text-white text-xs rounded hover:bg-yellow-700"
                          >
                            Reassign
                          </button>
                        )}

                        <button
                          onClick={(e) => {
                            e.stopPropagation()
                            const reason = prompt('Cancellation reason:')
                            if (reason) handleCancelTrip(trip.id, reason)
                          }}
                          className="px-3 py-1 bg-red-600 text-white text-xs rounded hover:bg-red-700"
                        >
                          Cancel
                        </button>
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>

        {/* Trip Details & Map */}
        <div className="space-y-6">
          {/* Selected Trip Details */}
          {selectedTrip ? (
            <div className="bg-white rounded-lg shadow">
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-lg font-medium text-gray-900">Trip Details</h2>
              </div>
              <div className="p-6">
                <div className="space-y-4">
                  <div>
                    <h3 className="text-sm font-medium text-gray-700">Customer</h3>
                    <p className="text-sm text-gray-900">{selectedTrip.customerName}</p>
                    <p className="text-sm text-gray-500">{selectedTrip.customerPhone}</p>
                  </div>

                  <div>
                    <h3 className="text-sm font-medium text-gray-700">Pickup</h3>
                    <p className="text-sm text-gray-900">{selectedTrip.pickupLocation.address}</p>
                  </div>

                  <div>
                    <h3 className="text-sm font-medium text-gray-700">Dropoff</h3>
                    <p className="text-sm text-gray-900">{selectedTrip.dropoffLocation.address}</p>
                  </div>

                  <div>
                    <h3 className="text-sm font-medium text-gray-700">Fare</h3>
                    <p className="text-lg font-semibold text-gray-900">UGX {selectedTrip.fare.toLocaleString()}</p>
                  </div>

                  <div>
                    <h3 className="text-sm font-medium text-gray-700">Status Actions</h3>
                    <div className="space-y-2">
                      {selectedTrip.status === 'assigned' && (
                        <button
                          onClick={() => handleUpdateStatus(selectedTrip.id, 'picked_up')}
                          className="w-full px-3 py-2 bg-green-600 text-white text-sm rounded hover:bg-green-700"
                        >
                          Mark as Picked Up
                        </button>
                      )}
                      {selectedTrip.status === 'picked_up' && (
                        <button
                          onClick={() => handleUpdateStatus(selectedTrip.id, 'in_progress')}
                          className="w-full px-3 py-2 bg-blue-600 text-white text-sm rounded hover:bg-blue-700"
                        >
                          Mark as In Progress
                        </button>
                      )}
                      {selectedTrip.status === 'in_progress' && (
                        <button
                          onClick={() => handleUpdateStatus(selectedTrip.id, 'completed')}
                          className="w-full px-3 py-2 bg-purple-600 text-white text-sm rounded hover:bg-purple-700"
                        >
                          Mark as Completed
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-white rounded-lg shadow">
              <div className="p-6 text-center text-gray-500">
                <MapPin className="w-12 h-12 mx-auto mb-4 text-gray-300" />
                <p>Select a trip to view details</p>
              </div>
            </div>
          )}

          {/* Live Locations */}
          <div className="bg-white rounded-lg shadow">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-medium text-gray-900">Live Locations</h2>
            </div>
            <div className="p-6">
              <div className="space-y-3">
                {liveLocations.slice(0, 5).map((location) => (
                  <div key={location.tripId} className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
                    <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
                    <div className="flex-1">
                      <p className="text-sm font-medium text-gray-900">Driver {location.driverId.slice(-4)}</p>
                      <p className="text-xs text-gray-500">
                        {location.coordinates.lat.toFixed(4)}, {location.coordinates.lng.toFixed(4)}
                      </p>
                    </div>
                    <div className="text-xs text-gray-500">
                      {location.speed} km/h
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
