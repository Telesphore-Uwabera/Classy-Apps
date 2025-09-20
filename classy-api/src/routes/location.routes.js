const express = require('express');
const axios = require('axios');
const { body, query, validationResult } = require('express-validator');
const { authMiddleware } = require('../middleware/auth.middleware');

const router = express.Router();

// Google Maps API client
const googleMapsClient = axios.create({
  baseURL: 'https://maps.googleapis.com/maps/api',
  timeout: 10000
});

// Geocoding - Convert address to coordinates
router.get('/geocode', authMiddleware, [
  query('address').notEmpty().withMessage('Address is required')
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { address } = req.query;

    const response = await googleMapsClient.get('/geocode/json', {
      params: {
        address,
        key: process.env.GOOGLE_MAPS_API_KEY,
        components: 'country:UG' // Restrict to Uganda
      }
    });

    if (response.data.status === 'OK' && response.data.results.length > 0) {
      const result = response.data.results[0];
      
      res.status(200).json({
        success: true,
        data: {
          address: result.formatted_address,
          coordinates: {
            lat: result.geometry.location.lat,
            lng: result.geometry.location.lng
          },
          placeId: result.place_id,
          components: result.address_components
        }
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'Address not found'
      });
    }

  } catch (error) {
    console.error('Geocoding error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to geocode address',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Reverse Geocoding - Convert coordinates to address
router.get('/reverse-geocode', authMiddleware, [
  query('lat').isFloat().withMessage('Valid latitude is required'),
  query('lng').isFloat().withMessage('Valid longitude is required')
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { lat, lng } = req.query;

    const response = await googleMapsClient.get('/geocode/json', {
      params: {
        latlng: `${lat},${lng}`,
        key: process.env.GOOGLE_MAPS_API_KEY
      }
    });

    if (response.data.status === 'OK' && response.data.results.length > 0) {
      const result = response.data.results[0];
      
      res.status(200).json({
        success: true,
        data: {
          address: result.formatted_address,
          coordinates: {
            lat: parseFloat(lat),
            lng: parseFloat(lng)
          },
          placeId: result.place_id,
          components: result.address_components
        }
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'Location not found'
      });
    }

  } catch (error) {
    console.error('Reverse geocoding error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to reverse geocode location',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Places Autocomplete
router.get('/autocomplete', authMiddleware, [
  query('input').notEmpty().withMessage('Search input is required')
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { input, types = 'establishment' } = req.query;

    const response = await googleMapsClient.get('/place/autocomplete/json', {
      params: {
        input,
        types,
        key: process.env.GOOGLE_MAPS_API_KEY,
        components: 'country:ug', // Restrict to Uganda
        language: 'en'
      }
    });

    if (response.data.status === 'OK') {
      const predictions = response.data.predictions.map(prediction => ({
        placeId: prediction.place_id,
        description: prediction.description,
        mainText: prediction.structured_formatting.main_text,
        secondaryText: prediction.structured_formatting.secondary_text,
        types: prediction.types
      }));

      res.status(200).json({
        success: true,
        data: predictions
      });
    } else {
      res.status(200).json({
        success: true,
        data: []
      });
    }

  } catch (error) {
    console.error('Autocomplete error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get autocomplete suggestions',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Place Details
router.get('/place-details', authMiddleware, [
  query('placeId').notEmpty().withMessage('Place ID is required')
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { placeId } = req.query;

    const response = await googleMapsClient.get('/place/details/json', {
      params: {
        place_id: placeId,
        key: process.env.GOOGLE_MAPS_API_KEY,
        fields: 'name,formatted_address,geometry,place_id,types,rating,photos,opening_hours,formatted_phone_number'
      }
    });

    if (response.data.status === 'OK') {
      const place = response.data.result;
      
      res.status(200).json({
        success: true,
        data: {
          placeId: place.place_id,
          name: place.name,
          address: place.formatted_address,
          coordinates: {
            lat: place.geometry.location.lat,
            lng: place.geometry.location.lng
          },
          types: place.types,
          rating: place.rating,
          phone: place.formatted_phone_number,
          openingHours: place.opening_hours,
          photos: place.photos ? place.photos.map(photo => ({
            reference: photo.photo_reference,
            width: photo.width,
            height: photo.height
          })) : []
        }
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'Place not found'
      });
    }

  } catch (error) {
    console.error('Place details error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get place details',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Calculate Distance and Duration
router.post('/distance', authMiddleware, [
  body('origins').isArray({ min: 1 }).withMessage('Origins array is required'),
  body('destinations').isArray({ min: 1 }).withMessage('Destinations array is required')
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { origins, destinations, mode = 'driving' } = req.body;

    // Convert coordinates to string format
    const originsStr = origins.map(coord => `${coord.lat},${coord.lng}`).join('|');
    const destinationsStr = destinations.map(coord => `${coord.lat},${coord.lng}`).join('|');

    const response = await googleMapsClient.get('/distancematrix/json', {
      params: {
        origins: originsStr,
        destinations: destinationsStr,
        mode,
        units: 'metric',
        key: process.env.GOOGLE_MAPS_API_KEY,
        language: 'en'
      }
    });

    if (response.data.status === 'OK') {
      const results = response.data.rows.map((row, originIndex) => ({
        origin: origins[originIndex],
        destinations: row.elements.map((element, destIndex) => ({
          destination: destinations[destIndex],
          distance: element.distance ? {
            text: element.distance.text,
            value: element.distance.value // in meters
          } : null,
          duration: element.duration ? {
            text: element.duration.text,
            value: element.duration.value // in seconds
          } : null,
          status: element.status
        }))
      }));

      res.status(200).json({
        success: true,
        data: results
      });
    } else {
      res.status(400).json({
        success: false,
        message: 'Failed to calculate distance'
      });
    }

  } catch (error) {
    console.error('Distance calculation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to calculate distance',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Get Directions
router.post('/directions', authMiddleware, [
  body('origin').notEmpty().withMessage('Origin is required'),
  body('destination').notEmpty().withMessage('Destination is required')
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { origin, destination, mode = 'driving', waypoints } = req.body;

    const params = {
      origin: typeof origin === 'object' ? `${origin.lat},${origin.lng}` : origin,
      destination: typeof destination === 'object' ? `${destination.lat},${destination.lng}` : destination,
      mode,
      key: process.env.GOOGLE_MAPS_API_KEY,
      language: 'en'
    };

    if (waypoints && waypoints.length > 0) {
      params.waypoints = waypoints.map(wp => 
        typeof wp === 'object' ? `${wp.lat},${wp.lng}` : wp
      ).join('|');
    }

    const response = await googleMapsClient.get('/directions/json', { params });

    if (response.data.status === 'OK' && response.data.routes.length > 0) {
      const route = response.data.routes[0];
      
      res.status(200).json({
        success: true,
        data: {
          route: {
            summary: route.summary,
            legs: route.legs.map(leg => ({
              distance: leg.distance,
              duration: leg.duration,
              startAddress: leg.start_address,
              endAddress: leg.end_address,
              startLocation: leg.start_location,
              endLocation: leg.end_location,
              steps: leg.steps.map(step => ({
                distance: step.distance,
                duration: step.duration,
                instructions: step.html_instructions.replace(/<[^>]*>/g, ''), // Remove HTML tags
                startLocation: step.start_location,
                endLocation: step.end_location
              }))
            })),
            overviewPolyline: route.overview_polyline.points,
            bounds: route.bounds,
            copyrights: route.copyrights
          }
        }
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'No route found'
      });
    }

  } catch (error) {
    console.error('Directions error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get directions',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Find Nearby Places
router.get('/nearby', authMiddleware, [
  query('lat').isFloat().withMessage('Valid latitude is required'),
  query('lng').isFloat().withMessage('Valid longitude is required')
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { lat, lng, radius = 5000, type = 'restaurant' } = req.query;

    const response = await googleMapsClient.get('/place/nearbysearch/json', {
      params: {
        location: `${lat},${lng}`,
        radius,
        type,
        key: process.env.GOOGLE_MAPS_API_KEY
      }
    });

    if (response.data.status === 'OK') {
      const places = response.data.results.map(place => ({
        placeId: place.place_id,
        name: place.name,
        vicinity: place.vicinity,
        coordinates: {
          lat: place.geometry.location.lat,
          lng: place.geometry.location.lng
        },
        rating: place.rating,
        types: place.types,
        priceLevel: place.price_level,
        openNow: place.opening_hours ? place.opening_hours.open_now : null,
        photos: place.photos ? place.photos.slice(0, 3).map(photo => ({
          reference: photo.photo_reference,
          width: photo.width,
          height: photo.height
        })) : []
      }));

      res.status(200).json({
        success: true,
        data: places
      });
    } else {
      res.status(200).json({
        success: true,
        data: []
      });
    }

  } catch (error) {
    console.error('Nearby places error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to find nearby places',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
