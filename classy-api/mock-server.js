const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 8000;

// Middleware
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:3001', 'http://localhost:60273'],
  credentials: true
}));
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'Classy API Mock Server',
    version: '1.0.0'
  });
});

// Mock registration endpoint
app.post('/api/auth/register', (req, res) => {
  console.log('Registration request received:', req.body);
  
  // Simulate processing delay
  setTimeout(() => {
    res.json({
      success: true,
      message: 'Registration successful',
      data: {
        user: {
          id: 'mock-user-' + Date.now(),
          name: req.body.name,
          phone: req.body.phone,
          email: req.body.email,
          role: req.body.role || 'vendor',
          status: 'pending',
          createdAt: new Date().toISOString()
        },
        token: 'mock-token-' + Date.now()
      }
    });
  }, 1000);
});

// Mock login endpoint
app.post('/api/auth/login', (req, res) => {
  console.log('Login request received:', req.body);
  
  setTimeout(() => {
    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: 'mock-user-' + Date.now(),
          name: 'Test Vendor',
          phone: req.body.phone,
          role: 'vendor',
          status: 'active'
        },
        token: 'mock-token-' + Date.now()
      }
    });
  }, 500);
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Classy API Mock Server',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      health: '/health',
      register: 'POST /api/auth/register',
      login: 'POST /api/auth/login'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Classy API Mock Server running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`📚 API Documentation: http://localhost:${PORT}/`);
  console.log(`🌍 Environment: development (mock mode)`);
});

module.exports = app;
