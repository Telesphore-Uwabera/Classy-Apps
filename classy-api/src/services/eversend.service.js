const axios = require('axios');

class EversendService {
  constructor() {
    this.baseURL = process.env.EVERSEND_BASE_URL || 'https://api.eversend.co/v1';
    this.clientId = process.env.EVERSEND_CLIENT_ID;
    this.clientSecret = process.env.EVERSEND_CLIENT_SECRET;
    this.client = null;
    this.accessToken = null;
  }

  async initialize() {
    try {
      // First get access token using client credentials
      await this.getAccessToken();
      
      this.client = axios.create({
        baseURL: this.baseURL,
        headers: {
          'Authorization': `Bearer ${this.accessToken}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000 // 30 seconds
      });

      console.log('✅ Eversend payment service initialized successfully');
    } catch (error) {
      console.error('❌ Eversend initialization error:', error);
      throw error;
    }
  }

  async getAccessToken() {
    try {
      const authClient = axios.create({
        baseURL: this.baseURL,
        timeout: 15000
      });

      const response = await authClient.post('/auth/token', {
        client_id: this.clientId,
        client_secret: this.clientSecret,
        grant_type: 'client_credentials'
      });

      this.accessToken = response.data.access_token;
      
      // Set token expiry (typically 1 hour)
      this.tokenExpiry = Date.now() + (response.data.expires_in * 1000);
      
      return this.accessToken;
    } catch (error) {
      console.error('❌ Failed to get Eversend access token:', error.response?.data || error.message);
      throw new Error('Failed to authenticate with Eversend API');
    }
  }

  async ensureValidToken() {
    // Check if token is expired or will expire in next 5 minutes
    if (!this.accessToken || Date.now() >= (this.tokenExpiry - 300000)) {
      await this.getAccessToken();
      // Update client headers with new token
      if (this.client) {
        this.client.defaults.headers['Authorization'] = `Bearer ${this.accessToken}`;
      }
    }
  }

  async processMTNPayment(paymentData) {
    try {
      if (!this.client) {
        await this.initialize();
      }
      await this.ensureValidToken();

      const payload = {
        phone: this.formatInternationalPhone(paymentData.phone),
        amount: paymentData.amount,
        currency: 'UGX',
        reason: paymentData.reason || 'Classy Order Payment',
        callback_url: `${process.env.API_BASE_URL}/api/payments/mtn-callback`,
        metadata: {
          orderId: paymentData.orderId,
          customerId: paymentData.customerId,
          vendorId: paymentData.vendorId,
          driverId: paymentData.driverId,
          transactionId: paymentData.transactionId
        }
      };

      const response = await this.client.post('/collections/mtn', payload);

      return {
        success: true,
        transactionId: response.data.transactionId,
        status: response.data.status,
        message: 'MTN payment initiated successfully',
        data: response.data
      };
    } catch (error) {
      console.error('MTN payment error:', error.response?.data || error.message);
      return {
        success: false,
        message: 'Failed to process MTN payment',
        error: error.response?.data || error.message
      };
    }
  }

  async processCardPayment(cardData) {
    try {
      if (!this.client) {
        await this.initialize();
      }
      await this.ensureValidToken();

      const payload = {
        card_number: cardData.cardNumber,
        expiry_month: cardData.expiryMonth,
        expiry_year: cardData.expiryYear,
        cvv: cardData.cvv,
        amount: cardData.amount,
        currency: 'UGX',
        email: cardData.email,
        callback_url: `${process.env.API_BASE_URL}/api/payments/card-callback`,
        metadata: {
          orderId: cardData.orderId,
          customerId: cardData.customerId,
          vendorId: cardData.vendorId,
          driverId: cardData.driverId,
          transactionId: cardData.transactionId
        }
      };

      const response = await this.client.post('/cards/charge', payload);

      return {
        success: true,
        transactionId: response.data.transactionId,
        status: response.data.status,
        message: 'Card payment initiated successfully',
        data: response.data
      };
    } catch (error) {
      console.error('Card payment error:', error.response?.data || error.message);
      return {
        success: false,
        message: 'Failed to process card payment',
        error: error.response?.data || error.message
      };
    }
  }

  async checkPaymentStatus(transactionId) {
    try {
      if (!this.client) {
        await this.initialize();
      }
      await this.ensureValidToken();

      const response = await this.client.get(`/transactions/${transactionId}`);

      return {
        success: true,
        status: response.data.status,
        data: response.data
      };
    } catch (error) {
      console.error('Payment status check error:', error.response?.data || error.message);
      return {
        success: false,
        message: 'Failed to check payment status',
        error: error.response?.data || error.message
      };
    }
  }

  async processVendorPayout(payoutData) {
    try {
      if (!this.client) {
        await this.initialize();
      }
      await this.ensureValidToken();

      const payload = {
        phone: this.formatInternationalPhone(payoutData.phone),
        amount: payoutData.amount,
        currency: 'UGX',
        reason: `Classy vendor payout - ${payoutData.period}`,
        metadata: {
          vendorId: payoutData.vendorId,
          period: payoutData.period,
          ordersCount: payoutData.ordersCount
        }
      };

      const response = await this.client.post('/payouts/mtn', payload);

      return {
        success: true,
        payoutId: response.data.transactionId,
        status: response.data.status,
        message: 'Vendor payout initiated successfully',
        data: response.data
      };
    } catch (error) {
      console.error('Vendor payout error:', error.response?.data || error.message);
      return {
        success: false,
        message: 'Failed to process vendor payout',
        error: error.response?.data || error.message
      };
    }
  }

  async processDriverPayout(payoutData) {
    try {
      if (!this.client) {
        await this.initialize();
      }
      await this.ensureValidToken();

      const payload = {
        phone: this.formatInternationalPhone(payoutData.phone),
        amount: payoutData.amount,
        currency: 'UGX',
        reason: `Classy driver payout - ${payoutData.period}`,
        metadata: {
          driverId: payoutData.driverId,
          period: payoutData.period,
          deliveriesCount: payoutData.deliveriesCount
        }
      };

      const response = await this.client.post('/payouts/mtn', payload);

      return {
        success: true,
        payoutId: response.data.transactionId,
        status: response.data.status,
        message: 'Driver payout initiated successfully',
        data: response.data
      };
    } catch (error) {
      console.error('Driver payout error:', error.response?.data || error.message);
      return {
        success: false,
        message: 'Failed to process driver payout',
        error: error.response?.data || error.message
      };
    }
  }

  calculateCommissions(totalAmount) {
    const classyCommission = totalAmount * parseFloat(process.env.CLASSY_COMMISSION_RATE || 0.15);
    const vendorAmount = totalAmount * parseFloat(process.env.VENDOR_COMMISSION_RATE || 0.85);
    const driverAmount = totalAmount * parseFloat(process.env.DRIVER_COMMISSION_RATE || 0.80);

    return {
      totalAmount,
      classyCommission,
      vendorAmount: vendorAmount - classyCommission,
      driverAmount: driverAmount - classyCommission,
      breakdown: {
        classyPercentage: parseFloat(process.env.CLASSY_COMMISSION_RATE || 0.15) * 100,
        vendorPercentage: parseFloat(process.env.VENDOR_COMMISSION_RATE || 0.85) * 100,
        driverPercentage: parseFloat(process.env.DRIVER_COMMISSION_RATE || 0.80) * 100
      }
    };
  }

  formatInternationalPhone(phoneNumber) {
    // Remove all non-digit and non-plus characters
    let cleaned = phoneNumber.replace(/[^\d+]/g, '');
    
    // If it already starts with +, return as is
    if (cleaned.startsWith('+')) {
      return cleaned;
    }
    
    // Remove any leading zeros
    cleaned = cleaned.replace(/^0+/, '');
    
    // Handle Uganda numbers specifically (for backward compatibility)
    if (cleaned.length === 9 && (cleaned.startsWith('7') || cleaned.startsWith('3'))) {
      return `+256${cleaned}`;
    }
    
    // Handle other formats
    if (cleaned.startsWith('256')) {
      return `+${cleaned}`;
    }
    
    // For other international numbers, assume they already have country code
    if (cleaned.length >= 10) {
      return `+${cleaned}`;
    }
    
    // Default to Uganda for short numbers (backward compatibility)
    if (cleaned.length === 9) {
      return `+256${cleaned}`;
    }
    
    return `+${cleaned}`;
  }

  validateCardData(cardData) {
    const errors = [];

    if (!cardData.cardNumber || cardData.cardNumber.length < 13) {
      errors.push('Invalid card number');
    }

    if (!cardData.expiryMonth || cardData.expiryMonth < 1 || cardData.expiryMonth > 12) {
      errors.push('Invalid expiry month');
    }

    if (!cardData.expiryYear || cardData.expiryYear < new Date().getFullYear()) {
      errors.push('Invalid expiry year');
    }

    if (!cardData.cvv || cardData.cvv.length < 3) {
      errors.push('Invalid CVV');
    }

    if (!cardData.amount || cardData.amount <= 0) {
      errors.push('Invalid amount');
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }
}

module.exports = new EversendService();
