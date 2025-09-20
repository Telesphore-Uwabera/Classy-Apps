const express = require('express');
const { body, validationResult } = require('express-validator');
const eversendService = require('../services/eversend.service');
const firebaseService = require('../services/firebase.service');
const { authMiddleware } = require('../middleware/auth.middleware');

const router = express.Router();

// Validation middleware
const validateMTNPayment = [
  body('phone').custom((value) => {
    // Allow international phone numbers with country codes
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    if (!phoneRegex.test(value.replace(/[\s-()]/g, ''))) {
      throw new Error('Invalid phone number format. Please include country code.');
    }
    return true;
  }),
  body('amount').isFloat({ min: 1000 }).withMessage('Amount must be at least UGX 1,000'),
  body('orderId').notEmpty().withMessage('Order ID is required'),
  body('vendorId').optional().notEmpty().withMessage('Vendor ID cannot be empty'),
  body('driverId').optional().notEmpty().withMessage('Driver ID cannot be empty')
];

const validateCardPayment = [
  body('cardNumber').isLength({ min: 13, max: 19 }).withMessage('Invalid card number'),
  body('expiryMonth').isInt({ min: 1, max: 12 }).withMessage('Invalid expiry month'),
  body('expiryYear').isInt({ min: new Date().getFullYear() }).withMessage('Invalid expiry year'),
  body('cvv').isLength({ min: 3, max: 4 }).withMessage('Invalid CVV'),
  body('email').isEmail().withMessage('Invalid email address'),
  body('amount').isFloat({ min: 1000 }).withMessage('Amount must be at least UGX 1,000'),
  body('orderId').notEmpty().withMessage('Order ID is required')
];

// Process MTN Mobile Money payment
router.post('/mtn', authMiddleware, validateMTNPayment, async (req, res) => {
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

    const { phone, amount, orderId, vendorId, driverId, reason } = req.body;
    const customerId = req.user.uid;

    // Calculate commissions
    const commissions = eversendService.calculateCommissions(amount);

    // Create transaction record
    const transactionId = await firebaseService.createTransaction({
      type: 'payment',
      method: 'mtn',
      customerId,
      vendorId,
      driverId,
      orderId,
      amount,
      commissions,
      status: 'pending',
      phone,
      reason: reason || 'Classy Order Payment'
    });

    // Process MTN payment
    const paymentResult = await eversendService.processMTNPayment({
      phone,
      amount,
      orderId,
      customerId,
      vendorId,
      driverId,
      transactionId,
      reason
    });

    if (paymentResult.success) {
      // Update transaction with payment details
      await firebaseService.updateTransaction(transactionId, {
        externalTransactionId: paymentResult.transactionId,
        status: 'processing',
        paymentData: paymentResult.data
      });

      // Send notification to vendor/driver
      if (vendorId) {
        // TODO: Send notification to vendor
      }
      if (driverId) {
        // TODO: Send notification to driver
      }

      res.status(200).json({
        success: true,
        message: 'MTN payment initiated successfully',
        data: {
          transactionId,
          externalTransactionId: paymentResult.transactionId,
          status: 'processing',
          commissions
        }
      });
    } else {
      // Update transaction status to failed
      await firebaseService.updateTransaction(transactionId, {
        status: 'failed',
        error: paymentResult.message
      });

      res.status(400).json({
        success: false,
        message: paymentResult.message,
        transactionId
      });
    }

  } catch (error) {
    console.error('MTN payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process MTN payment',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Process Card payment
router.post('/card', authMiddleware, validateCardPayment, async (req, res) => {
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

    const { cardNumber, expiryMonth, expiryYear, cvv, email, amount, orderId, vendorId, driverId } = req.body;
    const customerId = req.user.uid;

    // Validate card data
    const cardValidation = eversendService.validateCardData({
      cardNumber, expiryMonth, expiryYear, cvv, amount
    });

    if (!cardValidation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Invalid card data',
        errors: cardValidation.errors
      });
    }

    // Calculate commissions
    const commissions = eversendService.calculateCommissions(amount);

    // Create transaction record
    const transactionId = await firebaseService.createTransaction({
      type: 'payment',
      method: 'card',
      customerId,
      vendorId,
      driverId,
      orderId,
      amount,
      commissions,
      status: 'pending',
      email
    });

    // Process card payment
    const paymentResult = await eversendService.processCardPayment({
      cardNumber,
      expiryMonth,
      expiryYear,
      cvv,
      email,
      amount,
      orderId,
      customerId,
      vendorId,
      driverId,
      transactionId
    });

    if (paymentResult.success) {
      // Update transaction with payment details
      await firebaseService.updateTransaction(transactionId, {
        externalTransactionId: paymentResult.transactionId,
        status: 'processing',
        paymentData: paymentResult.data
      });

      res.status(200).json({
        success: true,
        message: 'Card payment initiated successfully',
        data: {
          transactionId,
          externalTransactionId: paymentResult.transactionId,
          status: 'processing',
          commissions
        }
      });
    } else {
      // Update transaction status to failed
      await firebaseService.updateTransaction(transactionId, {
        status: 'failed',
        error: paymentResult.message
      });

      res.status(400).json({
        success: false,
        message: paymentResult.message,
        transactionId
      });
    }

  } catch (error) {
    console.error('Card payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process card payment',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Process Cash payment (record only)
router.post('/cash', authMiddleware, [
  body('amount').isFloat({ min: 1000 }).withMessage('Amount must be at least UGX 1,000'),
  body('orderId').notEmpty().withMessage('Order ID is required')
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

    const { amount, orderId, vendorId, driverId } = req.body;
    const customerId = req.user.uid;

    // Calculate commissions
    const commissions = eversendService.calculateCommissions(amount);

    // Create transaction record for cash payment
    const transactionId = await firebaseService.createTransaction({
      type: 'payment',
      method: 'cash',
      customerId,
      vendorId,
      driverId,
      orderId,
      amount,
      commissions,
      status: 'pending',
      note: 'Cash payment - to be collected on delivery'
    });

    res.status(200).json({
      success: true,
      message: 'Cash payment recorded successfully',
      data: {
        transactionId,
        status: 'pending',
        commissions,
        note: 'Payment will be collected on delivery'
      }
    });

  } catch (error) {
    console.error('Cash payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to record cash payment',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Check payment status
router.get('/status/:transactionId', authMiddleware, async (req, res) => {
  try {
    const { transactionId } = req.params;

    // Get transaction from Firebase
    const transaction = await firebaseService.getTransaction(transactionId);
    
    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found'
      });
    }

    // Check if user has access to this transaction
    if (transaction.customerId !== req.user.uid && 
        transaction.vendorId !== req.user.uid && 
        transaction.driverId !== req.user.uid) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // If it's an external payment, check status with Eversend
    if (transaction.externalTransactionId && transaction.method !== 'cash') {
      const statusResult = await eversendService.checkPaymentStatus(transaction.externalTransactionId);
      
      if (statusResult.success && statusResult.status !== transaction.status) {
        // Update transaction status
        await firebaseService.updateTransaction(transactionId, {
          status: statusResult.status,
          paymentData: statusResult.data
        });
        transaction.status = statusResult.status;
      }
    }

    res.status(200).json({
      success: true,
      data: {
        transactionId: transaction.id,
        status: transaction.status,
        amount: transaction.amount,
        method: transaction.method,
        createdAt: transaction.createdAt,
        commissions: transaction.commissions
      }
    });

  } catch (error) {
    console.error('Payment status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check payment status',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// MTN payment callback (webhook)
router.post('/mtn-callback', async (req, res) => {
  try {
    const { transactionId, status, metadata } = req.body;

    if (metadata && metadata.transactionId) {
      // Update transaction status
      await firebaseService.updateTransaction(metadata.transactionId, {
        status: status.toLowerCase(),
        callbackData: req.body,
        processedAt: new Date()
      });

      // If payment is successful, update order status
      if (status.toLowerCase() === 'successful' && metadata.orderId) {
        await firebaseService.updateOrder(metadata.orderId, {
          paymentStatus: 'completed'
        });
      }
    }

    res.status(200).json({ success: true });
  } catch (error) {
    console.error('MTN callback error:', error);
    res.status(500).json({ success: false });
  }
});

// Card payment callback (webhook)
router.post('/card-callback', async (req, res) => {
  try {
    const { transactionId, status, metadata } = req.body;

    if (metadata && metadata.transactionId) {
      // Update transaction status
      await firebaseService.updateTransaction(metadata.transactionId, {
        status: status.toLowerCase(),
        callbackData: req.body,
        processedAt: new Date()
      });

      // If payment is successful, update order status
      if (status.toLowerCase() === 'successful' && metadata.orderId) {
        await firebaseService.updateOrder(metadata.orderId, {
          paymentStatus: 'completed'
        });
      }
    }

    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Card callback error:', error);
    res.status(500).json({ success: false });
  }
});

module.exports = router;
