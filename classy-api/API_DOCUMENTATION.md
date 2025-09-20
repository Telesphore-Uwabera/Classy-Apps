# 🚀 Classy API Documentation

**Clean, Modern, Market-Ready APIs for Uganda**

## 📋 Table of Contents
- [Overview](#overview)
- [Authentication](#authentication)
- [Payment APIs](#payment-apis)
- [Location APIs](#location-apis)
- [Transaction APIs](#transaction-apis)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)

---

## 🌟 Overview

The Classy API provides essential backend services for the Customer, Vendor, and Driver mobile applications. Built with Node.js and Express, integrated with Firebase and optimized for the Uganda market.

**Base URL**: `https://api.classy.ug` (Production)
**Base URL**: `http://localhost:3000` (Development)

### Key Features
- ✅ **Simple Authentication**: Phone + Password with OTP reset
- ✅ **Uganda Payment Methods**: MTN Mobile Money, Cards, Cash
- ✅ **Google Maps Integration**: Full location services
- ✅ **Commission Tracking**: Automated payment distribution
- ✅ **Real-time Transactions**: Firebase-powered data sync

---

## 🔐 Authentication

**Authentication is handled 100% by Firebase Client SDK in Flutter apps.**

The Node.js API only provides OTP services for password reset support.

### Send OTP (Password Reset Support)
```http
POST /api/otp/send
```

**Request Body:**
```json
{
  "phone": "+256712345678",
  "purpose": "password_reset"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "expiresIn": 300
}
```

### Verify OTP
```http
POST /api/otp/verify
```

**Request Body:**
```json
{
  "phone": "+256712345678",
  "otp": "123456",
  "purpose": "password_reset"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP verified successfully"
}
```

**Note**: All user registration, login, and password reset logic is handled directly by Firebase Authentication in the Flutter apps.

---

## 💳 Payment APIs

### MTN Mobile Money Payment
```http
POST /api/payments/mtn
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "phone": "+256712345678",
  "amount": 25000,
  "orderId": "order_123",
  "vendorId": "vendor_456",
  "driverId": "driver_789",
  "reason": "Food order payment"
}
```

**Response:**
```json
{
  "success": true,
  "message": "MTN payment initiated successfully",
  "data": {
    "transactionId": "trans_123",
    "externalTransactionId": "mtn_456",
    "status": "processing",
    "commissions": {
      "totalAmount": 25000,
      "classyCommission": 3750,
      "vendorAmount": 21250,
      "driverAmount": 20000
    }
  }
}
```

### Card Payment
```http
POST /api/payments/card
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "cardNumber": "4111111111111111",
  "expiryMonth": 12,
  "expiryYear": 2025,
  "cvv": "123",
  "email": "customer@example.com",
  "amount": 25000,
  "orderId": "order_123"
}
```

### Cash Payment (Record Only)
```http
POST /api/payments/cash
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "amount": 25000,
  "orderId": "order_123",
  "vendorId": "vendor_456",
  "driverId": "driver_789"
}
```

### Check Payment Status
```http
GET /api/payments/status/{transactionId}
Authorization: Bearer {token}
```

---

## 📍 Location APIs

### Geocoding (Address → Coordinates)
```http
GET /api/location/geocode?address=Kampala, Uganda
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "address": "Kampala, Uganda",
    "coordinates": {
      "lat": 0.3476,
      "lng": 32.5825
    },
    "placeId": "ChIJTzxTRX4gKxkRULVFOI5OFE8"
  }
}
```

### Reverse Geocoding (Coordinates → Address)
```http
GET /api/location/reverse-geocode?lat=0.3476&lng=32.5825
Authorization: Bearer {token}
```

### Places Autocomplete
```http
GET /api/location/autocomplete?input=Kampala&types=establishment
Authorization: Bearer {token}
```

### Calculate Distance & Duration
```http
POST /api/location/distance
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "origins": [{"lat": 0.3476, "lng": 32.5825}],
  "destinations": [{"lat": 0.3136, "lng": 32.5811}],
  "mode": "driving"
}
```

### Get Directions
```http
POST /api/location/directions
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "origin": {"lat": 0.3476, "lng": 32.5825},
  "destination": {"lat": 0.3136, "lng": 32.5811},
  "mode": "driving"
}
```

### Find Nearby Places
```http
GET /api/location/nearby?lat=0.3476&lng=32.5825&radius=5000&type=restaurant
Authorization: Bearer {token}
```

---

## 📊 Transaction APIs

### Get My Transactions
```http
GET /api/transactions/my-transactions?page=1&limit=20&status=successful
Authorization: Bearer {token}
```

### Get Transaction Details
```http
GET /api/transactions/{transactionId}
Authorization: Bearer {token}
```

### Get Earnings Summary (Vendors & Drivers)
```http
GET /api/transactions/earnings/summary?period=month
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "period": "month",
    "summary": {
      "totalEarnings": 500000,
      "netEarnings": 425000,
      "transactionCount": 20,
      "averageOrderValue": 25000
    },
    "chartData": [
      {"date": "2024-01-01", "amount": 50000, "count": 2},
      {"date": "2024-01-02", "amount": 75000, "count": 3}
    ]
  }
}
```

---

## 🚨 Error Handling

All API responses follow a consistent format:

### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { /* response data */ }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "errors": [
    {
      "field": "phone",
      "message": "Invalid phone number"
    }
  ]
}
```

### HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (invalid/missing token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `409` - Conflict (duplicate data)
- `429` - Too Many Requests (rate limited)
- `500` - Internal Server Error

---

## ⚡ Rate Limiting

- **General APIs**: 100 requests per 15 minutes per IP
- **Authentication APIs**: 5 requests per minute per IP
- **Payment APIs**: 10 requests per minute per user

---

## 💰 Commission Structure

### Default Rates
- **Classy Commission**: 15% of total order value
- **Vendor Share**: 85% of order value (after Classy commission)
- **Driver Share**: 80% of delivery fee (after Classy commission)

### Example Calculation
**Order Total: UGX 25,000**
- Classy Commission: UGX 3,750 (15%)
- Vendor Receives: UGX 21,250 (85%)
- Driver Receives: UGX 20,000 (80% of delivery portion)

---

## 🔧 Development Setup

### Prerequisites
- Node.js 18+
- Firebase project setup
- Twilio account
- Eversend API keys
- Google Maps API key

### Environment Variables
```bash
PORT=3000
NODE_ENV=development
FIREBASE_PROJECT_ID=classyapp-unified-backend
TWILIO_ACCOUNT_SID=your-twilio-sid
EVERSEND_API_KEY=your-eversend-key
GOOGLE_MAPS_API_KEY=your-google-maps-key
JWT_SECRET=your-jwt-secret
```

### Installation
```bash
cd classy-api
npm install
npm run dev
```

---

## 🚀 Deployment

### Production Checklist
- ✅ Environment variables configured
- ✅ Firebase service account setup
- ✅ Twilio phone number verified
- ✅ Eversend API keys activated
- ✅ Google Maps API billing enabled
- ✅ SSL certificate configured
- ✅ Rate limiting configured
- ✅ Error monitoring setup

### Deploy to Railway/Vercel
```bash
# Railway
railway login
railway init
railway up

# Vercel
vercel login
vercel --prod
```

---

## 🎯 Uganda Market Features

### Mobile Money Integration
- **MTN Mobile Money**: Primary payment method
- **Airtel Money**: Secondary option (can be added)
- **Phone Number Formats**: Automatic Uganda formatting

### Location Services
- **Kampala Focus**: Optimized for Kampala metropolitan area
- **Boda Boda Routes**: Motorcycle-friendly directions
- **Local Places**: Uganda-specific place types

### SMS/OTP Services
- **Twilio Integration**: Reliable SMS delivery
- **Local Numbers**: Uganda phone number support
- **Cost Optimization**: Efficient OTP management

---

**🎉 Ready for Uganda Market Launch!**

This API provides all essential features for a successful multi-app delivery platform in Uganda. Clean, simple, and market-ready.
