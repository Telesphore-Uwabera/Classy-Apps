# 🚀 Classy API - Node.js Backend

**Clean, Modern, Market-Ready API for Uganda's Delivery Platform**

## 🌟 Overview

The Classy API is a lightweight Node.js backend designed specifically for the Uganda market, providing essential services for Customer, Vendor, and Driver mobile applications.

### ✨ Key Features
- 📱 **Simple Authentication**: Phone + Password with Twilio OTP
- 💳 **Uganda Payments**: MTN Mobile Money, Cards (Eversend), Cash
- 📍 **Google Maps**: Complete location services
- 💰 **Commission Tracking**: Automated payment distribution
- 🔄 **Real-time Sync**: Firebase integration
- 🛡️ **Security**: JWT tokens, rate limiting, input validation

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Firebase project
- Twilio account
- Eversend API keys
- Google Maps API key

### Installation
```bash
# Clone and install
git clone <repository>
cd classy-api
npm install

# Setup environment
cp env.example .env
# Edit .env with your credentials

# Start development server
npm run dev
```

Server runs on `http://localhost:3000`

---

## 📁 Project Structure

```
classy-api/
├── src/
│   ├── app.js              # Express app setup
│   ├── routes/             # API routes
│   │   ├── auth.routes.js      # Authentication
│   │   ├── payment.routes.js   # Payment processing
│   │   ├── location.routes.js  # Google Maps
│   │   └── transaction.routes.js # Transaction management
│   ├── services/           # Business logic
│   │   ├── firebase.service.js # Firebase integration
│   │   ├── twilio.service.js   # SMS/OTP service
│   │   └── eversend.service.js # Payment processing
│   └── middleware/         # Express middleware
│       └── auth.middleware.js  # JWT authentication
├── package.json
├── env.example
└── README.md
```

---

## 🔧 Configuration

### Environment Variables
```bash
# Server
PORT=3000
NODE_ENV=development

# Firebase
FIREBASE_PROJECT_ID=classyapp-unified-backend
FIREBASE_CLIENT_EMAIL=your-firebase-email
FIREBASE_PRIVATE_KEY=your-firebase-key

# Twilio (OTP)
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_PHONE_NUMBER=your-twilio-number

# Eversend (Payments)
EVERSEND_API_KEY=your-eversend-key
EVERSEND_SECRET_KEY=your-eversend-secret

# Google Maps
GOOGLE_MAPS_API_KEY=your-google-maps-key

# Security
JWT_SECRET=your-jwt-secret
JWT_EXPIRES_IN=24h
```

---

## 📋 API Endpoints

### 🔐 Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/forgot-password` - Send OTP
- `POST /api/auth/reset-password` - Reset with OTP

### 💳 Payments
- `POST /api/payments/mtn` - MTN Mobile Money
- `POST /api/payments/card` - Card payment
- `POST /api/payments/cash` - Cash payment record
- `GET /api/payments/status/:id` - Payment status

### 📍 Location
- `GET /api/location/geocode` - Address to coordinates
- `GET /api/location/reverse-geocode` - Coordinates to address
- `GET /api/location/autocomplete` - Place suggestions
- `POST /api/location/distance` - Calculate distance
- `POST /api/location/directions` - Get directions
- `GET /api/location/nearby` - Find nearby places

### 📊 Transactions
- `GET /api/transactions/my-transactions` - User transactions
- `GET /api/transactions/:id` - Transaction details
- `GET /api/transactions/earnings/summary` - Earnings summary

---

## 💳 Payment Integration

### MTN Mobile Money
```javascript
// Example usage
const response = await fetch('/api/payments/mtn', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    phone: '+256712345678',
    amount: 25000,
    orderId: 'order_123'
  })
});
```

### Commission Structure
- **Classy**: 15% platform commission
- **Vendor**: 85% of order value
- **Driver**: 80% of delivery fee

---

## 🌍 Uganda Market Features

### 📱 Phone Number Handling
```javascript
// Automatic Uganda formatting
formatUgandaPhone('0712345678')    // +256712345678
formatUgandaPhone('712345678')     // +256712345678
formatUgandaPhone('+256712345678') // +256712345678
```

### 💬 SMS/OTP Integration
```javascript
// Send OTP
await twilioService.sendOTP('+256712345678', 'password_reset');

// Verify OTP
const result = await twilioService.verifyOTP('+256712345678', '123456');
```

### 🗺️ Location Services
- Optimized for Kampala and Uganda
- Boda boda-friendly routing
- Local place types and categories

---

## 🚀 Deployment

### Railway (Recommended)
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

### Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod
```

### Environment Variables Setup
1. Set all environment variables in your deployment platform
2. Ensure Firebase service account is properly configured
3. Verify Twilio and Eversend API keys are active
4. Enable Google Maps API billing

---

## 🔒 Security Features

### Authentication
- JWT token-based authentication
- Secure password hashing (bcrypt)
- Token expiration handling

### Rate Limiting
- 100 requests per 15 minutes (general)
- 5 requests per minute (auth endpoints)
- 10 requests per minute (payment endpoints)

### Input Validation
- Express-validator for all inputs
- Phone number validation
- Payment data validation

### Security Headers
- Helmet.js for security headers
- CORS configuration
- Request body size limits

---

## 📊 Monitoring & Logging

### Development
```bash
# Start with detailed logging
npm run dev

# Check logs
tail -f logs/app.log
```

### Production
- Morgan for HTTP request logging
- Firebase Crashlytics integration
- Error tracking and reporting

---

## 🧪 Testing

### Run Tests
```bash
# Run all tests
npm test

# Run specific test
npm test auth.test.js

# Coverage report
npm run test:coverage
```

### API Testing
```bash
# Health check
curl http://localhost:3000/health

# Test authentication
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Test User","phone":"+256712345678","password":"test123","confirmPassword":"test123","userType":"customer"}'
```

---

## 🔧 Development

### Adding New Endpoints
1. Create route file in `src/routes/`
2. Add business logic to `src/services/`
3. Update `src/app.js` to include route
4. Add validation middleware
5. Update API documentation

### Database Schema (Firebase)
```javascript
// Collections structure
users: {
  [userId]: {
    fullName: string,
    phone: string,
    userType: 'customer' | 'vendor' | 'driver',
    isActive: boolean,
    createdAt: timestamp
  }
}

transactions: {
  [transactionId]: {
    type: 'payment',
    method: 'mtn' | 'card' | 'cash',
    amount: number,
    status: 'pending' | 'processing' | 'successful' | 'failed',
    customerId: string,
    vendorId: string,
    driverId: string,
    commissions: object,
    createdAt: timestamp
  }
}

orders: {
  [orderId]: {
    customerId: string,
    vendorId: string,
    driverId: string,
    status: string,
    items: array,
    totalAmount: number,
    createdAt: timestamp
  }
}
```

---

## 🎯 Roadmap

### Phase 1 (Current) ✅
- Authentication system
- Payment processing
- Location services
- Transaction tracking

### Phase 2 (Next)
- Order management
- Real-time notifications
- Driver assignment
- Vendor management

### Phase 3 (Future)
- Analytics dashboard
- Automated payouts
- Advanced reporting
- Multi-language support

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🆘 Support

- **Documentation**: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)
- **Issues**: Create a GitHub issue
- **Email**: support@classy.ug

---

**🎉 Ready for Uganda Market Launch!**

This API is production-ready and optimized for the Uganda delivery market. Clean, secure, and scalable.
