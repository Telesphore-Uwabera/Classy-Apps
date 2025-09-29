import { collection, addDoc, updateDoc, deleteDoc, doc, getDocs, query, where, orderBy, onSnapshot } from 'firebase/firestore'
import { db } from '../config/firebase'

export interface Trip {
  id: string
  type: 'ride' | 'boda' | 'delivery' | 'flight'
  customerId: string
  customerName: string
  customerPhone: string
  driverId?: string
  driverName?: string
  driverPhone?: string
  status: 'pending' | 'assigned' | 'picked_up' | 'in_progress' | 'completed' | 'cancelled'
  pickupLocation: {
    address: string
    coordinates: { lat: number; lng: number }
  }
  dropoffLocation: {
    address: string
    coordinates: { lat: number; lng: number }
  }
  fare: number
  distance: number
  estimatedDuration: number
  actualDuration?: number
  createdAt: Date
  updatedAt: Date
  completedAt?: Date
  cancelledAt?: Date
  cancellationReason?: string
}

export interface LiveLocation {
  tripId: string
  driverId: string
  coordinates: { lat: number; lng: number }
  heading: number
  speed: number
  timestamp: Date
  accuracy: number
}

export interface TripAssignment {
  tripId: string
  driverId: string
  assignedBy: string
  assignedAt: Date
  reason?: string
}

class TrackingService {
  private tripsCollection = 'trips'
  private liveLocationsCollection = 'live_locations'
  private tripAssignmentsCollection = 'trip_assignments'

  // Get all active trips
  async getActiveTrips(): Promise<Trip[]> {
    try {
      const q = query(
        collection(db, this.tripsCollection),
        where('status', 'in', ['pending', 'assigned', 'picked_up', 'in_progress']),
        orderBy('createdAt', 'desc')
      )

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate(),
        completedAt: doc.data().completedAt?.toDate(),
        cancelledAt: doc.data().cancelledAt?.toDate()
      })) as Trip[]
    } catch (error) {
      console.error('Error getting active trips:', error)
      return []
    }
  }

  // Get trip by ID
  async getTrip(tripId: string): Promise<Trip | null> {
    try {
      const tripDoc = await getDocs(query(
        collection(db, this.tripsCollection),
        where('id', '==', tripId)
      ))

      if (tripDoc.empty) return null

      const doc = tripDoc.docs[0]
      const data = doc.data()
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt.toDate(),
        updatedAt: data.updatedAt.toDate(),
        completedAt: data.completedAt?.toDate(),
        cancelledAt: data.cancelledAt?.toDate()
      } as Trip
    } catch (error) {
      console.error('Error getting trip:', error)
      return null
    }
  }

  // Assign trip to driver
  async assignTrip(tripId: string, driverId: string, assignedBy: string, reason?: string): Promise<void> {
    try {
      // Update trip status
      await updateDoc(doc(db, this.tripsCollection, tripId), {
        driverId,
        status: 'assigned',
        updatedAt: new Date()
      })

      // Create assignment record
      await addDoc(collection(db, this.tripAssignmentsCollection), {
        tripId,
        driverId,
        assignedBy,
        assignedAt: new Date(),
        reason
      })
    } catch (error) {
      console.error('Error assigning trip:', error)
      throw error
    }
  }

  // Reassign trip to different driver
  async reassignTrip(tripId: string, newDriverId: string, reassignedBy: string, reason?: string): Promise<void> {
    try {
      // Update trip with new driver
      await updateDoc(doc(db, this.tripsCollection, tripId), {
        driverId: newDriverId,
        updatedAt: new Date()
      })

      // Create reassignment record
      await addDoc(collection(db, this.tripAssignmentsCollection), {
        tripId,
        driverId: newDriverId,
        assignedBy: reassignedBy,
        assignedAt: new Date(),
        reason: `Reassignment: ${reason || 'No reason provided'}`
      })
    } catch (error) {
      console.error('Error reassigning trip:', error)
      throw error
    }
  }

  // Cancel trip
  async cancelTrip(tripId: string, cancelledBy: string, reason: string): Promise<void> {
    try {
      await updateDoc(doc(db, this.tripsCollection, tripId), {
        status: 'cancelled',
        cancellationReason: reason,
        cancelledAt: new Date(),
        updatedAt: new Date()
      })

      // Log cancellation
      await addDoc(collection(db, 'trip_cancellations'), {
        tripId,
        cancelledBy,
        reason,
        cancelledAt: new Date()
      })
    } catch (error) {
      console.error('Error cancelling trip:', error)
      throw error
    }
  }

  // Update trip status
  async updateTripStatus(tripId: string, status: Trip['status'], updatedBy: string): Promise<void> {
    try {
      const updateData: any = {
        status,
        updatedAt: new Date()
      }

      if (status === 'completed') {
        updateData.completedAt = new Date()
      }

      await updateDoc(doc(db, this.tripsCollection, tripId), updateData)

      // Log status change
      await addDoc(collection(db, 'trip_status_changes'), {
        tripId,
        status,
        updatedBy,
        updatedAt: new Date()
      })
    } catch (error) {
      console.error('Error updating trip status:', error)
      throw error
    }
  }

  // Get live location for driver
  async getDriverLiveLocation(driverId: string): Promise<LiveLocation | null> {
    try {
      const q = query(
        collection(db, this.liveLocationsCollection),
        where('driverId', '==', driverId),
        orderBy('timestamp', 'desc'),
        limit(1)
      )

      const snapshot = await getDocs(q)
      if (snapshot.empty) return null

      const doc = snapshot.docs[0]
      const data = doc.data()
      return {
        ...data,
        timestamp: data.timestamp.toDate()
      } as LiveLocation
    } catch (error) {
      console.error('Error getting driver live location:', error)
      return null
    }
  }

  // Get all live locations
  async getAllLiveLocations(): Promise<LiveLocation[]> {
    try {
      const q = query(
        collection(db, this.liveLocationsCollection),
        orderBy('timestamp', 'desc')
      )

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        ...doc.data(),
        timestamp: doc.data().timestamp.toDate()
      })) as LiveLocation[]
    } catch (error) {
      console.error('Error getting live locations:', error)
      return []
    }
  }

  // Subscribe to live location updates
  subscribeToLiveLocations(callback: (locations: LiveLocation[]) => void): () => void {
    const q = query(
      collection(db, this.liveLocationsCollection),
      orderBy('timestamp', 'desc')
    )

    return onSnapshot(q, (snapshot) => {
      const locations = snapshot.docs.map(doc => ({
        ...doc.data(),
        timestamp: doc.data().timestamp.toDate()
      })) as LiveLocation[]
      callback(locations)
    })
  }

  // Subscribe to active trips updates
  subscribeToActiveTrips(callback: (trips: Trip[]) => void): () => void {
    const q = query(
      collection(db, this.tripsCollection),
      where('status', 'in', ['pending', 'assigned', 'picked_up', 'in_progress']),
      orderBy('createdAt', 'desc')
    )

    return onSnapshot(q, (snapshot) => {
      const trips = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate(),
        completedAt: doc.data().completedAt?.toDate(),
        cancelledAt: doc.data().cancelledAt?.toDate()
      })) as Trip[]
      callback(trips)
    })
  }

  // Get trip statistics
  async getTripStatistics(startDate: Date, endDate: Date): Promise<{
    totalTrips: number
    completedTrips: number
    cancelledTrips: number
    averageFare: number
    totalRevenue: number
    averageDuration: number
  }> {
    try {
      const q = query(
        collection(db, this.tripsCollection),
        where('createdAt', '>=', startDate),
        where('createdAt', '<=', endDate)
      )

      const snapshot = await getDocs(q)
      const trips = snapshot.docs.map(doc => doc.data()) as Trip[]

      const totalTrips = trips.length
      const completedTrips = trips.filter(trip => trip.status === 'completed').length
      const cancelledTrips = trips.filter(trip => trip.status === 'cancelled').length
      const totalRevenue = trips
        .filter(trip => trip.status === 'completed')
        .reduce((sum, trip) => sum + trip.fare, 0)
      const averageFare = completedTrips > 0 ? totalRevenue / completedTrips : 0
      const averageDuration = trips
        .filter(trip => trip.actualDuration)
        .reduce((sum, trip) => sum + (trip.actualDuration || 0), 0) / 
        trips.filter(trip => trip.actualDuration).length

      return {
        totalTrips,
        completedTrips,
        cancelledTrips,
        averageFare,
        totalRevenue,
        averageDuration: averageDuration || 0
      }
    } catch (error) {
      console.error('Error getting trip statistics:', error)
      return {
        totalTrips: 0,
        completedTrips: 0,
        cancelledTrips: 0,
        averageFare: 0,
        totalRevenue: 0,
        averageDuration: 0
      }
    }
  }
}

export const trackingService = new TrackingService()
