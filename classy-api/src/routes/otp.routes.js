const express = require('express');
const { body, validationResult } = require('express-validator');
const twilioService = require('../services/twilio.service');

const router = express.Router();

// Validation middleware for international phone numbers
const validatePhone = [
  body('phone').custom((value) => {
    // Allow international phone numbers with country codes
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    if (!phoneRegex.test(value.replace(/[\s-()]/g, ''))) {
      throw new Error('Invalid phone number format. Please include country code.');
    }
    return true;
  })
];

const validateOTP = [
  ...validatePhone,
  body('otp').isLength({ min: 6, max: 6 }).withMessage('OTP must be 6 digits')
];

// Send OTP (for password reset or verification)
router.post('/send', validatePhone, async (req, res) => {
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

    const { phone, purpose = 'verification' } = req.body;

    // Send OTP via Twilio
    const otpResult = await twilioService.sendOTP(phone, purpose);
    
    if (otpResult.success) {
      res.status(200).json({
        success: true,
        message: 'OTP sent successfully',
        expiresIn: otpResult.expiresIn
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to send OTP'
      });
    }

  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send OTP',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Verify OTP
router.post('/verify', validateOTP, async (req, res) => {
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

    const { phone, otp, purpose = 'verification' } = req.body;

    // Verify OTP via Twilio service
    const otpVerification = await twilioService.verifyOTP(phone, otp, purpose);
    
    res.status(otpVerification.success ? 200 : 400).json(otpVerification);

  } catch (error) {
    console.error('OTP verification error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify OTP',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
