import React, { useEffect, useRef, useState } from 'react'
import { MapPin, Navigation, Clock, Car, User, Phone, AlertCircle, CheckCircle } from 'lucide-react'

interface EnhancedGoogleMapsProps {
  trips: any[]
  liveLocations: any[]
  selectedTrip?: any
  onTripSelect?: (trip: any) => void
  onDriverAssign?: (tripId: string, driverId: string) => void
  onTripReassign?: (tripId: string, newDriverId: string) => void
  onTripCancel?: (tripId: string) => void
}

interface MapMarker {
  id: string
  position: { lat: number; lng: number }
  type: 'pickup' | 'destination' | 'driver' | 'customer'
  data: any
}

export default function EnhancedGoogleMaps({
  trips,
  liveLocations,
  selectedTrip,
  onTripSelect,
  onDriverAssign,
  onTripReassign,
  onTripCancel
}: EnhancedGoogleMapsProps) {
  const mapRef = useRef<HTMLDivElement>(null)
  const [map, setMap] = useState<google.maps.Map | null>(null)
  const [markers, setMarkers] = useState<MapMarker[]>([])
  const [polylines, setPolylines] = useState<google.maps.Polyline[]>([])
  const [selectedMarker, setSelectedMarker] = useState<MapMarker | null>(null)
  const [isMapLoaded, setIsMapLoaded] = useState(false)

  // Initialize Google Maps
  useEffect(() => {
    if (!window.google || !mapRef.current) return

    const mapInstance = new google.maps.Map(mapRef.current, {
      center: { lat: 0.3476, lng: 32.5825 }, // Kampala coordinates
      zoom: 12,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      styles: [
        {
          featureType: 'poi',
          elementType: 'labels',
          stylers: [{ visibility: 'off' }]
        }
      ]
    })

    setMap(mapInstance)
    setIsMapLoaded(true)
  }, [])

  // Update markers when trips or locations change
  useEffect(() => {
    if (!map || !isMapLoaded) return

    // Clear existing markers
    markers.forEach(marker => {
      if (marker.data.marker) {
        marker.data.marker.setMap(null)
      }
    })

    const newMarkers: MapMarker[] = []

    // Add trip markers
    trips.forEach(trip => {
      if (trip.pickupLocation) {
        const pickupMarker = new google.maps.Marker({
          position: {
            lat: trip.pickupLocation.latitude,
            lng: trip.pickupLocation.longitude
          },
          map: map,
          icon: {
            url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(`
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="12" cy="12" r="10" fill="#4CAF50" stroke="white" stroke-width="2"/>
                <path d="M12 2L13.09 8.26L20 9L13.09 9.74L12 16L10.91 9.74L4 9L10.91 8.26L12 2Z" fill="white"/>
              </svg>
            `),
            scaledSize: new google.maps.Size(24, 24)
          },
          title: `Pickup: ${trip.pickupLocation.address}`
        })

        pickupMarker.addListener('click', () => {
          setSelectedMarker({
            id: `pickup-${trip.id}`,
            position: {
              lat: trip.pickupLocation.latitude,
              lng: trip.pickupLocation.longitude
            },
            type: 'pickup',
            data: { ...trip, marker: pickupMarker }
          })
          onTripSelect?.(trip)
        })

        newMarkers.push({
          id: `pickup-${trip.id}`,
          position: {
            lat: trip.pickupLocation.latitude,
            lng: trip.pickupLocation.longitude
          },
          type: 'pickup',
          data: { ...trip, marker: pickupMarker }
        })
      }

      if (trip.destinationLocation) {
        const destinationMarker = new google.maps.Marker({
          position: {
            lat: trip.destinationLocation.latitude,
            lng: trip.destinationLocation.longitude
          },
          map: map,
          icon: {
            url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(`
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="12" cy="12" r="10" fill="#F44336" stroke="white" stroke-width="2"/>
                <path d="M12 2L13.09 8.26L20 9L13.09 9.74L12 16L10.91 9.74L4 9L10.91 8.26L12 2Z" fill="white"/>
              </svg>
            `),
            scaledSize: new google.maps.Size(24, 24)
          },
          title: `Destination: ${trip.destinationLocation.address}`
        })

        destinationMarker.addListener('click', () => {
          setSelectedMarker({
            id: `destination-${trip.id}`,
            position: {
              lat: trip.destinationLocation.latitude,
              lng: trip.destinationLocation.longitude
            },
            type: 'destination',
            data: { ...trip, marker: destinationMarker }
          })
          onTripSelect?.(trip)
        })

        newMarkers.push({
          id: `destination-${trip.id}`,
          position: {
            lat: trip.destinationLocation.latitude,
            lng: trip.destinationLocation.longitude
          },
          type: 'destination',
          data: { ...trip, marker: destinationMarker }
        })
      }
    })

    // Add driver location markers
    liveLocations.forEach(location => {
      const driverMarker = new google.maps.Marker({
        position: {
          lat: location.coordinates.lat,
          lng: location.coordinates.lng
        },
        map: map,
        icon: {
          url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(`
            <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <circle cx="16" cy="16" r="14" fill="#2196F3" stroke="white" stroke-width="2"/>
              <path d="M16 4L18.12 10.35L24 12L18.12 13.65L16 20L13.88 13.65L8 12L13.88 10.35L16 4Z" fill="white"/>
            </svg>
          `),
          scaledSize: new google.maps.Size(32, 32)
        },
        title: `Driver ${location.driverId.slice(-4)} - ${location.speed} km/h`
      })

      driverMarker.addListener('click', () => {
        setSelectedMarker({
          id: `driver-${location.driverId}`,
          position: {
            lat: location.coordinates.lat,
            lng: location.coordinates.lng
          },
          type: 'driver',
          data: { ...location, marker: driverMarker }
        })
      })

      newMarkers.push({
        id: `driver-${location.driverId}`,
        position: {
          lat: location.coordinates.lat,
          lng: location.coordinates.lng
        },
        type: 'driver',
        data: { ...location, marker: driverMarker }
      })
    })

    setMarkers(newMarkers)

    // Draw polylines for active trips
    drawTripRoutes(trips)
  }, [map, isMapLoaded, trips, liveLocations])

  // Draw routes for trips
  const drawTripRoutes = (trips: any[]) => {
    if (!map) return

    // Clear existing polylines
    polylines.forEach(polyline => polyline.setMap(null))

    const newPolylines: google.maps.Polyline[] = []

    trips.forEach(trip => {
      if (trip.pickupLocation && trip.destinationLocation) {
        const directionsService = new google.maps.DirectionsService()
        const directionsRenderer = new google.maps.DirectionsRenderer({
          suppressMarkers: true,
          polylineOptions: {
            strokeColor: getTripColor(trip.status),
            strokeWeight: 4,
            strokeOpacity: 0.8
          }
        })

        directionsRenderer.setMap(map)

        directionsService.route({
          origin: {
            lat: trip.pickupLocation.latitude,
            lng: trip.pickupLocation.longitude
          },
          destination: {
            lat: trip.destinationLocation.latitude,
            lng: trip.destinationLocation.longitude
          },
          travelMode: google.maps.TravelMode.DRIVING
        }, (result, status) => {
          if (status === 'OK' && result) {
            directionsRenderer.setDirections(result)
            newPolylines.push(directionsRenderer as any)
          }
        })
      }
    })

    setPolylines(newPolylines)
  }

  const getTripColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'pending': return '#FF9800'
      case 'assigned': return '#2196F3'
      case 'picked_up': return '#9C27B0'
      case 'in_progress': return '#4CAF50'
      case 'delivered': return '#4CAF50'
      case 'cancelled': return '#F44336'
      default: return '#757575'
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status.toLowerCase()) {
      case 'pending': return <Clock className="w-4 h-4 text-orange-500" />
      case 'assigned': return <User className="w-4 h-4 text-blue-500" />
      case 'picked_up': return <Car className="w-4 h-4 text-purple-500" />
      case 'in_progress': return <Navigation className="w-4 h-4 text-green-500" />
      case 'delivered': return <CheckCircle className="w-4 h-4 text-green-500" />
      case 'cancelled': return <AlertCircle className="w-4 h-4 text-red-500" />
      default: return <Clock className="w-4 h-4 text-gray-500" />
    }
  }

  return (
    <div className="flex h-full">
      {/* Map Container */}
      <div className="flex-1 relative">
        <div ref={mapRef} className="w-full h-full rounded-lg" />
        
        {/* Map Controls */}
        <div className="absolute top-4 right-4 space-y-2">
          <button
            onClick={() => map?.setZoom((map.getZoom() || 12) + 1)}
            className="bg-white p-2 rounded-lg shadow-lg hover:bg-gray-50"
          >
            <span className="text-lg font-bold">+</span>
          </button>
          <button
            onClick={() => map?.setZoom((map.getZoom() || 12) - 1)}
            className="bg-white p-2 rounded-lg shadow-lg hover:bg-gray-50"
          >
            <span className="text-lg font-bold">-</span>
          </button>
        </div>

        {/* Legend */}
        <div className="absolute bottom-4 left-4 bg-white p-4 rounded-lg shadow-lg">
          <h3 className="font-semibold text-sm mb-2">Legend</h3>
          <div className="space-y-1 text-xs">
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 bg-green-500 rounded-full"></div>
              <span>Pickup Location</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 bg-red-500 rounded-full"></div>
              <span>Destination</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 bg-blue-500 rounded-full"></div>
              <span>Driver Location</span>
            </div>
          </div>
        </div>
      </div>

      {/* Side Panel */}
      <div className="w-80 bg-white border-l border-gray-200 overflow-y-auto">
        <div className="p-4">
          <h2 className="text-lg font-semibold mb-4">Active Trips</h2>
          
          {trips.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              <MapPin className="w-12 h-12 mx-auto mb-2 text-gray-300" />
              <p>No active trips</p>
            </div>
          ) : (
            <div className="space-y-3">
              {trips.map(trip => (
                <div
                  key={trip.id}
                  className={`p-3 rounded-lg border cursor-pointer transition-colors ${
                    selectedTrip?.id === trip.id
                      ? 'border-blue-500 bg-blue-50'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                  onClick={() => onTripSelect?.(trip)}
                >
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-sm font-medium">Trip #{trip.id.slice(-6)}</span>
                    <div className="flex items-center space-x-1">
                      {getStatusIcon(trip.status)}
                      <span className="text-xs text-gray-600 capitalize">{trip.status}</span>
                    </div>
                  </div>
                  
                  <div className="text-xs text-gray-600 space-y-1">
                    <div className="flex items-center space-x-1">
                      <MapPin className="w-3 h-3 text-green-500" />
                      <span className="truncate">{trip.pickupLocation?.address}</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <MapPin className="w-3 h-3 text-red-500" />
                      <span className="truncate">{trip.destinationLocation?.address}</span>
                    </div>
                  </div>

                  {trip.driver && (
                    <div className="mt-2 pt-2 border-t border-gray-100">
                      <div className="flex items-center space-x-2">
                        <User className="w-3 h-3 text-blue-500" />
                        <span className="text-xs text-gray-600">
                          Driver: {trip.driver.name}
                        </span>
                      </div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Selected Trip Details */}
        {selectedTrip && (
          <div className="border-t border-gray-200 p-4">
            <h3 className="font-semibold mb-3">Trip Details</h3>
            <div className="space-y-3">
              <div>
                <label className="text-xs text-gray-500">Status</label>
                <div className="flex items-center space-x-2">
                  {getStatusIcon(selectedTrip.status)}
                  <span className="text-sm capitalize">{selectedTrip.status}</span>
                </div>
              </div>
              
              <div>
                <label className="text-xs text-gray-500">Customer</label>
                <p className="text-sm">{selectedTrip.customer?.name || 'Unknown'}</p>
              </div>
              
              <div>
                <label className="text-xs text-gray-500">Driver</label>
                <p className="text-sm">{selectedTrip.driver?.name || 'Unassigned'}</p>
              </div>
              
              <div>
                <label className="text-xs text-gray-500">Total</label>
                <p className="text-sm font-semibold">${selectedTrip.total?.toFixed(2) || '0.00'}</p>
              </div>

              {/* Action Buttons */}
              <div className="space-y-2">
                {selectedTrip.status === 'pending' && (
                  <button
                    onClick={() => onDriverAssign?.(selectedTrip.id, 'driver-id')}
                    className="w-full bg-blue-500 text-white py-2 px-3 rounded text-sm hover:bg-blue-600"
                  >
                    Assign Driver
                  </button>
                )}
                
                {selectedTrip.status === 'assigned' && (
                  <button
                    onClick={() => onTripReassign?.(selectedTrip.id, 'new-driver-id')}
                    className="w-full bg-orange-500 text-white py-2 px-3 rounded text-sm hover:bg-orange-600"
                  >
                    Reassign Driver
                  </button>
                )}
                
                <button
                  onClick={() => onTripCancel?.(selectedTrip.id)}
                  className="w-full bg-red-500 text-white py-2 px-3 rounded text-sm hover:bg-red-600"
                >
                  Cancel Trip
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
