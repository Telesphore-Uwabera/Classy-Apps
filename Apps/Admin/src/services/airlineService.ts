import { collection, addDoc, updateDoc, deleteDoc, doc, getDocs, query, where, orderBy, limit } from 'firebase/firestore'
import { db } from '../config/firebase'

export interface Airline {
  id?: string
  name: string
  code: string // IATA code (e.g., 'UA', 'BA')
  logo: string
  country: string
  isActive: boolean
  contactInfo: {
    email: string
    phone: string
    website: string
    address: string
  }
  commissionRate: number // Percentage
  bookingFee: number // Fixed amount
  cancellationPolicy: {
    freeCancellationHours: number
    cancellationFee: number
    refundPercentage: number
  }
  routes: AirlineRoute[]
  createdAt: Date
  updatedAt: Date
}

export interface AirlineRoute {
  id: string
  origin: {
    code: string
    name: string
    city: string
    country: string
  }
  destination: {
    code: string
    name: string
    city: string
    country: string
  }
  distance: number // in kilometers
  duration: number // in minutes
  isActive: boolean
  basePrice: number
  frequency: {
    daily: boolean
    weekly: boolean
    specificDays: string[] // ['monday', 'tuesday', etc.]
  }
}

export interface Flight {
  id?: string
  flightNumber: string
  airlineId: string
  airlineName: string
  route: AirlineRoute
  departure: {
    airport: string
    terminal: string
    scheduledTime: Date
    actualTime?: Date
    gate?: string
  }
  arrival: {
    airport: string
    terminal: string
    scheduledTime: Date
    actualTime?: Date
    baggage?: string
  }
  aircraft: {
    type: string
    capacity: number
    registration: string
  }
  pricing: {
    basePrice: number
    taxes: number
    fees: number
    totalPrice: number
    currency: string
  }
  availability: {
    economy: number
    business: number
    first: number
  }
  status: 'scheduled' | 'boarding' | 'departed' | 'arrived' | 'delayed' | 'cancelled'
  bookingCount: number
  createdAt: Date
  updatedAt: Date
}

export interface FlightBooking {
  id?: string
  bookingReference: string
  flightId: string
  customerId: string
  customerName: string
  customerEmail: string
  customerPhone: string
  passengers: {
    name: string
    seat: string
    class: 'economy' | 'business' | 'first'
    passportNumber?: string
    nationality?: string
  }[]
  pricing: {
    basePrice: number
    taxes: number
    fees: number
    totalPrice: number
    currency: string
  }
  payment: {
    method: string
    status: 'pending' | 'completed' | 'failed' | 'refunded'
    transactionId?: string
    paidAt?: Date
  }
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed'
  specialRequests: string[]
  createdAt: Date
  updatedAt: Date
}

export interface AirlineStatistics {
  totalAirlines: number
  activeAirlines: number
  totalRoutes: number
  totalFlights: number
  totalBookings: number
  totalRevenue: number
  averageBookingValue: number
  occupancyRate: number
  cancellationRate: number
  onTimePerformance: number
}

class AirlineService {
  private airlinesCollection = 'airlines'
  private flightsCollection = 'flights'
  private bookingsCollection = 'flight_bookings'

  // Airline Management
  async createAirline(airline: Omit<Airline, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const docRef = await addDoc(collection(db, this.airlinesCollection), {
        ...airline,
        createdAt: new Date(),
        updatedAt: new Date()
      })
      return docRef.id
    } catch (error) {
      console.error('Error creating airline:', error)
      throw error
    }
  }

  async getAirlines(): Promise<Airline[]> {
    try {
      const q = query(
        collection(db, this.airlinesCollection),
        orderBy('name', 'asc')
      )

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate()
      })) as Airline[]
    } catch (error) {
      console.error('Error getting airlines:', error)
      return []
    }
  }

  async updateAirline(airlineId: string, updates: Partial<Airline>): Promise<void> {
    try {
      await updateDoc(doc(db, this.airlinesCollection, airlineId), {
        ...updates,
        updatedAt: new Date()
      })
    } catch (error) {
      console.error('Error updating airline:', error)
      throw error
    }
  }

  async deleteAirline(airlineId: string): Promise<void> {
    try {
      await deleteDoc(doc(db, this.airlinesCollection, airlineId))
    } catch (error) {
      console.error('Error deleting airline:', error)
      throw error
    }
  }

  // Flight Management
  async createFlight(flight: Omit<Flight, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const docRef = await addDoc(collection(db, this.flightsCollection), {
        ...flight,
        createdAt: new Date(),
        updatedAt: new Date()
      })
      return docRef.id
    } catch (error) {
      console.error('Error creating flight:', error)
      throw error
    }
  }

  async getFlights(filters: {
    airlineId?: string
    origin?: string
    destination?: string
    date?: Date
    status?: string
    limitCount?: number
  } = {}): Promise<Flight[]> {
    try {
      let q = query(collection(db, this.flightsCollection), orderBy('departure.scheduledTime', 'asc'))

      if (filters.airlineId) {
        q = query(q, where('airlineId', '==', filters.airlineId))
      }

      if (filters.origin) {
        q = query(q, where('route.origin.code', '==', filters.origin))
      }

      if (filters.destination) {
        q = query(q, where('route.destination.code', '==', filters.destination))
      }

      if (filters.status) {
        q = query(q, where('status', '==', filters.status))
      }

      if (filters.limitCount) {
        q = query(q, limit(filters.limitCount))
      }

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        departure: {
          ...doc.data().departure,
          scheduledTime: doc.data().departure.scheduledTime.toDate(),
          actualTime: doc.data().departure.actualTime?.toDate()
        },
        arrival: {
          ...doc.data().arrival,
          scheduledTime: doc.data().arrival.scheduledTime.toDate(),
          actualTime: doc.data().arrival.actualTime?.toDate()
        },
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate()
      })) as Flight[]
    } catch (error) {
      console.error('Error getting flights:', error)
      return []
    }
  }

  async updateFlight(flightId: string, updates: Partial<Flight>): Promise<void> {
    try {
      await updateDoc(doc(db, this.flightsCollection, flightId), {
        ...updates,
        updatedAt: new Date()
      })
    } catch (error) {
      console.error('Error updating flight:', error)
      throw error
    }
  }

  async cancelFlight(flightId: string, reason: string): Promise<void> {
    try {
      await updateDoc(doc(db, this.flightsCollection, flightId), {
        status: 'cancelled',
        cancellationReason: reason,
        updatedAt: new Date()
      })

      // Cancel all bookings for this flight
      await this.cancelFlightBookings(flightId, reason)
    } catch (error) {
      console.error('Error cancelling flight:', error)
      throw error
    }
  }

  // Booking Management
  async createBooking(booking: Omit<FlightBooking, 'id' | 'bookingReference' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const bookingReference = await this.generateBookingReference()
      
      const docRef = await addDoc(collection(db, this.bookingsCollection), {
        ...booking,
        bookingReference,
        createdAt: new Date(),
        updatedAt: new Date()
      })

      // Update flight booking count
      await this.updateFlightBookingCount(booking.flightId, 1)

      return docRef.id
    } catch (error) {
      console.error('Error creating booking:', error)
      throw error
    }
  }

  async getBookings(filters: {
    flightId?: string
    customerId?: string
    status?: string
    startDate?: Date
    endDate?: Date
    limitCount?: number
  } = {}): Promise<FlightBooking[]> {
    try {
      let q = query(collection(db, this.bookingsCollection), orderBy('createdAt', 'desc'))

      if (filters.flightId) {
        q = query(q, where('flightId', '==', filters.flightId))
      }

      if (filters.customerId) {
        q = query(q, where('customerId', '==', filters.customerId))
      }

      if (filters.status) {
        q = query(q, where('status', '==', filters.status))
      }

      if (filters.startDate) {
        q = query(q, where('createdAt', '>=', filters.startDate))
      }

      if (filters.endDate) {
        q = query(q, where('createdAt', '<=', filters.endDate))
      }

      if (filters.limitCount) {
        q = query(q, limit(filters.limitCount))
      }

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        payment: {
          ...doc.data().payment,
          paidAt: doc.data().payment.paidAt?.toDate()
        },
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate()
      })) as FlightBooking[]
    } catch (error) {
      console.error('Error getting bookings:', error)
      return []
    }
  }

  async updateBooking(bookingId: string, updates: Partial<FlightBooking>): Promise<void> {
    try {
      await updateDoc(doc(db, this.bookingsCollection, bookingId), {
        ...updates,
        updatedAt: new Date()
      })
    } catch (error) {
      console.error('Error updating booking:', error)
      throw error
    }
  }

  async cancelBooking(bookingId: string, reason: string): Promise<void> {
    try {
      const booking = await this.getBooking(bookingId)
      if (!booking) throw new Error('Booking not found')

      await updateDoc(doc(db, this.bookingsCollection, bookingId), {
        status: 'cancelled',
        cancellationReason: reason,
        updatedAt: new Date()
      })

      // Update flight booking count
      await this.updateFlightBookingCount(booking.flightId, -1)

      // Process refund if applicable
      if (booking.payment.status === 'completed') {
        await this.processRefund(bookingId, booking.pricing.totalPrice, reason)
      }
    } catch (error) {
      console.error('Error cancelling booking:', error)
      throw error
    }
  }

  async getBooking(bookingId: string): Promise<FlightBooking | null> {
    try {
      const bookingDoc = await getDocs(query(
        collection(db, this.bookingsCollection),
        where('id', '==', bookingId)
      ))

      if (bookingDoc.empty) return null

      const doc = bookingDoc.docs[0]
      const data = doc.data()
      return {
        id: doc.id,
        ...data,
        payment: {
          ...data.payment,
          paidAt: data.payment.paidAt?.toDate()
        },
        createdAt: data.createdAt.toDate(),
        updatedAt: data.updatedAt.toDate()
      } as FlightBooking
    } catch (error) {
      console.error('Error getting booking:', error)
      return null
    }
  }

  // Statistics
  async getAirlineStatistics(): Promise<AirlineStatistics> {
    try {
      const [airlines, flights, bookings] = await Promise.all([
        this.getAirlines(),
        this.getFlights(),
        this.getBookings()
      ])

      const activeAirlines = airlines.filter(airline => airline.isActive).length
      const totalRoutes = airlines.reduce((sum, airline) => sum + airline.routes.length, 0)
      const totalRevenue = bookings
        .filter(booking => booking.status === 'confirmed' || booking.status === 'completed')
        .reduce((sum, booking) => sum + booking.pricing.totalPrice, 0)
      
      const confirmedBookings = bookings.filter(booking => booking.status === 'confirmed' || booking.status === 'completed')
      const cancelledBookings = bookings.filter(booking => booking.status === 'cancelled')
      
      const averageBookingValue = confirmedBookings.length > 0 ? totalRevenue / confirmedBookings.length : 0
      const cancellationRate = bookings.length > 0 ? (cancelledBookings.length / bookings.length) * 100 : 0
      
      // Calculate occupancy rate (mock calculation)
      const totalCapacity = flights.reduce((sum, flight) => 
        sum + flight.aircraft.capacity, 0)
      const totalBookingsCount = confirmedBookings.length
      const occupancyRate = totalCapacity > 0 ? (totalBookingsCount / totalCapacity) * 100 : 0

      // Calculate on-time performance (mock calculation)
      const onTimeFlights = flights.filter(flight => 
        flight.status === 'arrived' && 
        flight.arrival.actualTime && 
        flight.arrival.actualTime <= flight.arrival.scheduledTime
      ).length
      const onTimePerformance = flights.length > 0 ? (onTimeFlights / flights.length) * 100 : 0

      return {
        totalAirlines: airlines.length,
        activeAirlines,
        totalRoutes,
        totalFlights: flights.length,
        totalBookings: bookings.length,
        totalRevenue,
        averageBookingValue,
        occupancyRate,
        cancellationRate,
        onTimePerformance
      }
    } catch (error) {
      console.error('Error getting airline statistics:', error)
      return {
        totalAirlines: 0,
        activeAirlines: 0,
        totalRoutes: 0,
        totalFlights: 0,
        totalBookings: 0,
        totalRevenue: 0,
        averageBookingValue: 0,
        occupancyRate: 0,
        cancellationRate: 0,
        onTimePerformance: 0
      }
    }
  }

  // Helper methods
  private async generateBookingReference(): Promise<string> {
    const prefix = 'FB' // Flight Booking
    const timestamp = Date.now().toString(36).toUpperCase()
    const random = Math.random().toString(36).substring(2, 6).toUpperCase()
    return `${prefix}${timestamp}${random}`
  }

  private async updateFlightBookingCount(flightId: string, change: number): Promise<void> {
    try {
      const flight = await this.getFlight(flightId)
      if (flight) {
        await updateDoc(doc(db, this.flightsCollection, flightId), {
          bookingCount: Math.max(0, (flight.bookingCount || 0) + change),
          updatedAt: new Date()
        })
      }
    } catch (error) {
      console.error('Error updating flight booking count:', error)
    }
  }

  private async getFlight(flightId: string): Promise<Flight | null> {
    try {
      const flightDoc = await getDocs(query(
        collection(db, this.flightsCollection),
        where('id', '==', flightId)
      ))

      if (flightDoc.empty) return null

      const doc = flightDoc.docs[0]
      const data = doc.data()
      return {
        id: doc.id,
        ...data,
        departure: {
          ...data.departure,
          scheduledTime: data.departure.scheduledTime.toDate(),
          actualTime: data.departure.actualTime?.toDate()
        },
        arrival: {
          ...data.arrival,
          scheduledTime: data.arrival.scheduledTime.toDate(),
          actualTime: data.arrival.actualTime?.toDate()
        },
        createdAt: data.createdAt.toDate(),
        updatedAt: data.updatedAt.toDate()
      } as Flight
    } catch (error) {
      console.error('Error getting flight:', error)
      return null
    }
  }

  private async cancelFlightBookings(flightId: string, reason: string): Promise<void> {
    try {
      const bookings = await this.getBookings({ flightId })
      for (const booking of bookings) {
        if (booking.status === 'confirmed' || booking.status === 'pending') {
          await this.cancelBooking(booking.id!, reason)
        }
      }
    } catch (error) {
      console.error('Error cancelling flight bookings:', error)
    }
  }

  private async processRefund(bookingId: string, amount: number, reason: string): Promise<void> {
    try {
      // This would integrate with payment service to process refund
      console.log(`Processing refund for booking ${bookingId}: ${amount} - Reason: ${reason}`)
    } catch (error) {
      console.error('Error processing refund:', error)
    }
  }
}

export const airlineService = new AirlineService()
