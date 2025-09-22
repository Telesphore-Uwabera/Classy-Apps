import { collection, addDoc, updateDoc, deleteDoc, doc, getDocs, query, orderBy, where } from 'firebase/firestore'
import { db } from '../config/firebase'

export interface FareConfiguration {
  id?: string
  baseFarePerKm: number // UGX 3,000 per km
  delaySurchargePercentage: number // +35% per delayed km
  nightWeatherSurchargePercentage: number // +20%
  highDemandSurchargePercentage: number // +5%
  waitingTimeSurchargePercentage: number // +10%
  freeWaitingTimeMinutes: number // 10 minutes
  maxDelayMinutesPerKm: number // 6 minutes per km
  isActive: boolean
  createdAt: Date
  updatedAt: Date
}

export interface FareCalculation {
  baseFare: number
  distanceKm: number
  delaySurcharge: number
  nightWeatherSurcharge: number
  highDemandSurcharge: number
  waitingTimeSurcharge: number
  totalFare: number
  breakdown: {
    baseFare: number
    delayAdjustment: number
    nightWeatherCharge: number
    highDemandCharge: number
    waitingTimeCharge: number
    total: number
  }
}

export interface SurgePricing {
  id?: string
  area: string
  multiplier: number
  startTime: string
  endTime: string
  days: string[] // ['monday', 'tuesday', etc.]
  isActive: boolean
  createdAt: Date
  updatedAt: Date
}

class FareService {
  private fareConfigCollection = 'fare_configurations'
  private surgePricingCollection = 'surge_pricing'

  // Get current fare configuration
  async getFareConfiguration(): Promise<FareConfiguration | null> {
    try {
      const q = query(
        collection(db, this.fareConfigCollection),
        where('isActive', '==', true),
        orderBy('createdAt', 'desc'),
        limit(1)
      )
      
      const snapshot = await getDocs(q)
      if (snapshot.empty) {
        // Return default configuration
        return {
          baseFarePerKm: 3000,
          delaySurchargePercentage: 35,
          nightWeatherSurchargePercentage: 20,
          highDemandSurchargePercentage: 5,
          waitingTimeSurchargePercentage: 10,
          freeWaitingTimeMinutes: 10,
          maxDelayMinutesPerKm: 6,
          isActive: true,
          createdAt: new Date(),
          updatedAt: new Date()
        }
      }

      const doc = snapshot.docs[0]
      const data = doc.data()
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt.toDate(),
        updatedAt: data.updatedAt.toDate()
      } as FareConfiguration
    } catch (error) {
      console.error('Error getting fare configuration:', error)
      return null
    }
  }

  // Update fare configuration
  async updateFareConfiguration(config: Omit<FareConfiguration, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      // Deactivate current configuration
      const currentConfig = await this.getFareConfiguration()
      if (currentConfig?.id) {
        await updateDoc(doc(db, this.fareConfigCollection, currentConfig.id), {
          isActive: false,
          updatedAt: new Date()
        })
      }

      // Create new configuration
      const newConfig = {
        ...config,
        createdAt: new Date(),
        updatedAt: new Date()
      }

      const docRef = await addDoc(collection(db, this.fareConfigCollection), newConfig)
      return docRef.id
    } catch (error) {
      console.error('Error updating fare configuration:', error)
      throw error
    }
  }

  // Calculate fare using CLASSY UG algorithm
  async calculateFare(params: {
    distanceKm: number
    actualTimeMinutes: number
    isNightTime: boolean
    isBadWeather: boolean
    isHighDemand: boolean
    waitingTimeMinutes: number
    area?: string
  }): Promise<FareCalculation> {
    const config = await this.getFareConfiguration()
    if (!config) {
      throw new Error('Fare configuration not found')
    }

    const { distanceKm, actualTimeMinutes, isNightTime, isBadWeather, isHighDemand, waitingTimeMinutes, area } = params

    // Step 1: Base Fare
    const baseFare = config.baseFarePerKm * distanceKm

    // Step 2: Time Check - Delay Surcharge
    const expectedTimeMinutes = distanceKm * config.maxDelayMinutesPerKm
    const delayMinutes = Math.max(0, actualTimeMinutes - expectedTimeMinutes)
    const delayKm = delayMinutes / config.maxDelayMinutesPerKm
    const delaySurcharge = (baseFare * (delayKm / distanceKm) * config.delaySurchargePercentage) / 100

    // Step 3: Night/Weather Surcharge
    const nightWeatherSurcharge = (isNightTime || isBadWeather) 
      ? (baseFare * config.nightWeatherSurchargePercentage) / 100 
      : 0

    // Step 4: High Demand Surcharge
    const highDemandSurcharge = isHighDemand 
      ? (baseFare * config.highDemandSurchargePercentage) / 100 
      : 0

    // Step 5: Waiting Time Surcharge
    const excessWaitingTime = Math.max(0, waitingTimeMinutes - config.freeWaitingTimeMinutes)
    const waitingTimeSurcharge = excessWaitingTime > 0 
      ? (baseFare * config.waitingTimeSurchargePercentage) / 100 
      : 0

    // Step 6: Surge Pricing (if area specified)
    let surgeMultiplier = 1
    if (area) {
      const surgePricing = await this.getSurgePricingForArea(area)
      if (surgePricing) {
        surgeMultiplier = surgePricing.multiplier
      }
    }

    // Calculate total fare
    const subtotal = baseFare + delaySurcharge + nightWeatherSurcharge + highDemandSurcharge + waitingTimeSurcharge
    const totalFare = subtotal * surgeMultiplier

    return {
      baseFare,
      distanceKm,
      delaySurcharge,
      nightWeatherSurcharge,
      highDemandSurcharge,
      waitingTimeSurcharge,
      totalFare,
      breakdown: {
        baseFare,
        delayAdjustment: delaySurcharge,
        nightWeatherCharge: nightWeatherSurcharge,
        highDemandCharge: highDemandSurcharge,
        waitingTimeCharge: waitingTimeSurcharge,
        total: totalFare
      }
    }
  }

  // Get surge pricing for specific area
  async getSurgePricingForArea(area: string): Promise<SurgePricing | null> {
    try {
      const now = new Date()
      const currentDay = now.toLocaleLowerCase().substring(0, 3) // 'mon', 'tue', etc.
      const currentTime = now.toTimeString().substring(0, 5) // 'HH:MM'

      const q = query(
        collection(db, this.surgePricingCollection),
        where('area', '==', area),
        where('isActive', '==', true),
        where('days', 'array-contains', currentDay)
      )

      const snapshot = await getDocs(q)
      for (const doc of snapshot.docs) {
        const data = doc.data() as SurgePricing
        if (this.isTimeInRange(currentTime, data.startTime, data.endTime)) {
          return {
            id: doc.id,
            ...data,
            createdAt: data.createdAt.toDate(),
            updatedAt: data.updatedAt.toDate()
          }
        }
      }

      return null
    } catch (error) {
      console.error('Error getting surge pricing:', error)
      return null
    }
  }

  // Create surge pricing rule
  async createSurgePricing(rule: Omit<SurgePricing, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const docRef = await addDoc(collection(db, this.surgePricingCollection), {
        ...rule,
        createdAt: new Date(),
        updatedAt: new Date()
      })
      return docRef.id
    } catch (error) {
      console.error('Error creating surge pricing:', error)
      throw error
    }
  }

  // Get all surge pricing rules
  async getSurgePricingRules(): Promise<SurgePricing[]> {
    try {
      const q = query(
        collection(db, this.surgePricingCollection),
        orderBy('createdAt', 'desc')
      )

      const snapshot = await getDocs(q)
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate()
      })) as SurgePricing[]
    } catch (error) {
      console.error('Error getting surge pricing rules:', error)
      return []
    }
  }

  // Update surge pricing rule
  async updateSurgePricing(id: string, updates: Partial<SurgePricing>): Promise<void> {
    try {
      await updateDoc(doc(db, this.surgePricingCollection, id), {
        ...updates,
        updatedAt: new Date()
      })
    } catch (error) {
      console.error('Error updating surge pricing:', error)
      throw error
    }
  }

  // Delete surge pricing rule
  async deleteSurgePricing(id: string): Promise<void> {
    try {
      await deleteDoc(doc(db, this.surgePricingCollection, id))
    } catch (error) {
      console.error('Error deleting surge pricing:', error)
      throw error
    }
  }

  private isTimeInRange(currentTime: string, startTime: string, endTime: string): boolean {
    const current = this.timeToMinutes(currentTime)
    const start = this.timeToMinutes(startTime)
    const end = this.timeToMinutes(endTime)

    if (start <= end) {
      return current >= start && current <= end
    } else {
      // Handle overnight ranges (e.g., 22:00 to 06:00)
      return current >= start || current <= end
    }
  }

  private timeToMinutes(time: string): number {
    const [hours, minutes] = time.split(':').map(Number)
    return hours * 60 + minutes
  }
}

export const fareService = new FareService()
