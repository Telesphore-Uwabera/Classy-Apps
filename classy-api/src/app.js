const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Import services
const firebaseService = require('./services/firebase.service');

// Import routes - Critical missing features only
const paymentRoutes = require('./routes/payment.routes');
const locationRoutes = require('./routes/location.routes');
const transactionRoutes = require('./routes/transaction.routes');
const otpRoutes = require('./routes/otp.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://classy-customer.app', 'https://classy-vendor.app', 'https://classy-driver.app']
    : '*',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests, please try again later'
  }
});
app.use(limiter);

// Body parsing middleware
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

// Initialize Firebase
firebaseService.initialize();

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Classy API is running smoothly',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV
  });
});

// API routes - Critical missing features only
app.use('/api/payments', paymentRoutes);
app.use('/api/location', locationRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/otp', otpRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Route not found'
  });
});

// Global error handler
app.use((error, req, res, next) => {
  console.error('Global Error:', error);
  
  res.status(error.status || 500).json({
    status: 'error',
    message: process.env.NODE_ENV === 'production' 
      ? 'Something went wrong' 
      : error.message,
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Classy API server running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV}`);
  console.log(`📱 Ready to serve Customer, Vendor, and Driver apps`);
});

module.exports = app;
