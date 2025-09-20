const express = require('express');
const { query, validationResult } = require('express-validator');
const firebaseService = require('../services/firebase.service');
const eversendService = require('../services/eversend.service');
const { authMiddleware, requireUserType } = require('../middleware/auth.middleware');

const router = express.Router();

// Get user transactions
router.get('/my-transactions', authMiddleware, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('status').optional().isIn(['pending', 'processing', 'successful', 'failed']).withMessage('Invalid status'),
  query('method').optional().isIn(['mtn', 'card', 'cash']).withMessage('Invalid payment method')
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

    const { page = 1, limit = 20, status, method } = req.query;
    const userId = req.user.uid;
    const userType = req.user.userType;

    // Build query based on user type
    let query = firebaseService.db.collection('transactions');

    // Filter by user type
    if (userType === 'customer') {
      query = query.where('customerId', '==', userId);
    } else if (userType === 'vendor') {
      query = query.where('vendorId', '==', userId);
    } else if (userType === 'driver') {
      query = query.where('driverId', '==', userId);
    }

    // Apply filters
    if (status) {
      query = query.where('status', '==', status);
    }
    if (method) {
      query = query.where('method', '==', method);
    }

    // Order by creation date (newest first)
    query = query.orderBy('createdAt', 'desc');

    // Apply pagination
    const offset = (page - 1) * limit;
    if (offset > 0) {
      // For pagination, we need to use startAfter with document snapshot
      // This is a simplified version - in production, implement proper cursor-based pagination
      query = query.limit(parseInt(limit));
    } else {
      query = query.limit(parseInt(limit));
    }

    const snapshot = await query.get();
    const transactions = [];

    snapshot.forEach(doc => {
      const data = doc.data();
      transactions.push({
        id: doc.id,
        type: data.type,
        method: data.method,
        amount: data.amount,
        status: data.status,
        orderId: data.orderId,
        createdAt: data.createdAt,
        commissions: userType === 'customer' ? undefined : data.commissions, // Hide commissions from customers
        note: data.note
      });
    });

    res.status(200).json({
      success: true,
      data: {
        transactions,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: transactions.length
        }
      }
    });

  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get transactions',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Get transaction details
router.get('/:transactionId', authMiddleware, async (req, res) => {
  try {
    const { transactionId } = req.params;
    const userId = req.user.uid;
    const userType = req.user.userType;

    // Get transaction from Firebase
    const transaction = await firebaseService.getTransaction(transactionId);
    
    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found'
      });
    }

    // Check if user has access to this transaction
    const hasAccess = transaction.customerId === userId || 
                     transaction.vendorId === userId || 
                     transaction.driverId === userId;

    if (!hasAccess) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // Prepare response data based on user type
    const responseData = {
      id: transaction.id,
      type: transaction.type,
      method: transaction.method,
      amount: transaction.amount,
      status: transaction.status,
      orderId: transaction.orderId,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      note: transaction.note
    };

    // Add commissions info for vendors and drivers
    if (userType !== 'customer' && transaction.commissions) {
      responseData.commissions = transaction.commissions;
    }

    // Add payment-specific data
    if (transaction.method === 'mtn' && transaction.phone) {
      responseData.phone = transaction.phone;
    }
    if (transaction.method === 'card' && transaction.email) {
      responseData.email = transaction.email;
    }

    res.status(200).json({
      success: true,
      data: responseData
    });

  } catch (error) {
    console.error('Get transaction details error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get transaction details',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Get earnings summary (for vendors and drivers)
router.get('/earnings/summary', authMiddleware, requireUserType(['vendor', 'driver']), [
  query('period').optional().isIn(['today', 'week', 'month', 'year']).withMessage('Invalid period')
], async (req, res) => {
  try {
    const { period = 'month' } = req.query;
    const userId = req.user.uid;
    const userType = req.user.userType;

    // Calculate date range based on period
    const now = new Date();
    let startDate;

    switch (period) {
      case 'today':
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        break;
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'month':
        startDate = new Date(now.getFullYear(), now.getMonth(), 1);
        break;
      case 'year':
        startDate = new Date(now.getFullYear(), 0, 1);
        break;
      default:
        startDate = new Date(now.getFullYear(), now.getMonth(), 1);
    }

    // Build query
    let query = firebaseService.db.collection('transactions')
      .where('status', '==', 'successful')
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', now);

    // Filter by user type
    if (userType === 'vendor') {
      query = query.where('vendorId', '==', userId);
    } else if (userType === 'driver') {
      query = query.where('driverId', '==', userId);
    }

    const snapshot = await query.get();
    
    let totalEarnings = 0;
    let totalCommissions = 0;
    let transactionCount = 0;
    const dailyEarnings = {};

    snapshot.forEach(doc => {
      const data = doc.data();
      const amount = data.amount || 0;
      const commissions = data.commissions || {};
      
      transactionCount++;
      totalEarnings += amount;

      // Calculate user's share based on type
      if (userType === 'vendor' && commissions.vendorAmount) {
        totalCommissions += commissions.vendorAmount;
      } else if (userType === 'driver' && commissions.driverAmount) {
        totalCommissions += commissions.driverAmount;
      }

      // Group by day for chart data
      const date = data.createdAt.toDate().toISOString().split('T')[0];
      if (!dailyEarnings[date]) {
        dailyEarnings[date] = { amount: 0, count: 0 };
      }
      dailyEarnings[date].amount += amount;
      dailyEarnings[date].count += 1;
    });

    // Convert daily earnings to array for charts
    const chartData = Object.entries(dailyEarnings).map(([date, data]) => ({
      date,
      amount: data.amount,
      count: data.count
    })).sort((a, b) => new Date(a.date) - new Date(b.date));

    res.status(200).json({
      success: true,
      data: {
        period,
        summary: {
          totalEarnings,
          netEarnings: totalCommissions, // Amount after Classy commission
          transactionCount,
          averageOrderValue: transactionCount > 0 ? totalEarnings / transactionCount : 0
        },
        chartData
      }
    });

  } catch (error) {
    console.error('Get earnings summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get earnings summary',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// Admin: Get all transactions (admin only)
router.get('/admin/all-transactions', authMiddleware, requireUserType('admin'), [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('status').optional().isIn(['pending', 'processing', 'successful', 'failed']).withMessage('Invalid status'),
  query('method').optional().isIn(['mtn', 'card', 'cash']).withMessage('Invalid payment method'),
  query('userType').optional().isIn(['customer', 'vendor', 'driver']).withMessage('Invalid user type')
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

    const { page = 1, limit = 50, status, method, userType } = req.query;

    // Build query
    let query = firebaseService.db.collection('transactions');

    // Apply filters
    if (status) {
      query = query.where('status', '==', status);
    }
    if (method) {
      query = query.where('method', '==', method);
    }

    // Order by creation date (newest first)
    query = query.orderBy('createdAt', 'desc').limit(parseInt(limit));

    const snapshot = await query.get();
    const transactions = [];

    snapshot.forEach(doc => {
      const data = doc.data();
      transactions.push({
        id: doc.id,
        type: data.type,
        method: data.method,
        amount: data.amount,
        status: data.status,
        customerId: data.customerId,
        vendorId: data.vendorId,
        driverId: data.driverId,
        orderId: data.orderId,
        commissions: data.commissions,
        createdAt: data.createdAt,
        note: data.note
      });
    });

    // Calculate totals
    const totalAmount = transactions.reduce((sum, t) => sum + (t.amount || 0), 0);
    const totalCommissions = transactions.reduce((sum, t) => 
      sum + (t.commissions?.classyCommission || 0), 0
    );

    res.status(200).json({
      success: true,
      data: {
        transactions,
        summary: {
          totalTransactions: transactions.length,
          totalAmount,
          totalCommissions,
          successfulTransactions: transactions.filter(t => t.status === 'successful').length,
          pendingTransactions: transactions.filter(t => t.status === 'pending').length
        },
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Get all transactions error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get transactions',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
