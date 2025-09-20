const twilio = require('twilio');

class TwilioService {
  constructor() {
    this.client = null;
    this.otpStore = new Map(); // In production, use Redis or database
  }

  initialize() {
    try {
      this.client = twilio(
        process.env.TWILIO_ACCOUNT_SID,
        process.env.TWILIO_AUTH_TOKEN
      );
      console.log('✅ Twilio service initialized successfully');
    } catch (error) {
      console.error('❌ Twilio initialization error:', error);
      throw error;
    }
  }

  generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  async sendOTP(phoneNumber, purpose = 'verification') {
    try {
      if (!this.client) {
        this.initialize();
      }

      const otp = this.generateOTP();
      const message = this.getOTPMessage(otp, purpose);

      // Format phone number for international use
      const formattedPhone = this.formatInternationalPhone(phoneNumber);

      await this.client.messages.create({
        body: message,
        from: process.env.TWILIO_PHONE_NUMBER,
        to: formattedPhone
      });

      // Store OTP with expiration (5 minutes)
      this.otpStore.set(formattedPhone, {
        otp,
        purpose,
        expiresAt: Date.now() + 5 * 60 * 1000, // 5 minutes
        attempts: 0
      });

      console.log(`📱 OTP sent to ${formattedPhone} for ${purpose}`);
      
      return {
        success: true,
        message: 'OTP sent successfully',
        expiresIn: 300 // 5 minutes in seconds
      };
    } catch (error) {
      console.error('OTP sending error:', error);
      throw new Error('Failed to send OTP');
    }
  }

  async verifyOTP(phoneNumber, otp, purpose = 'verification') {
    try {
      const formattedPhone = this.formatInternationalPhone(phoneNumber);
      const storedData = this.otpStore.get(formattedPhone);

      if (!storedData) {
        return {
          success: false,
          message: 'No OTP found for this phone number'
        };
      }

      // Check if OTP is expired
      if (Date.now() > storedData.expiresAt) {
        this.otpStore.delete(formattedPhone);
        return {
          success: false,
          message: 'OTP has expired'
        };
      }

      // Check if purpose matches
      if (storedData.purpose !== purpose) {
        return {
          success: false,
          message: 'Invalid OTP purpose'
        };
      }

      // Increment attempts
      storedData.attempts += 1;

      // Check max attempts (3 attempts allowed)
      if (storedData.attempts > 3) {
        this.otpStore.delete(formattedPhone);
        return {
          success: false,
          message: 'Maximum OTP attempts exceeded'
        };
      }

      // Verify OTP
      if (storedData.otp === otp) {
        this.otpStore.delete(formattedPhone);
        return {
          success: true,
          message: 'OTP verified successfully'
        };
      } else {
        this.otpStore.set(formattedPhone, storedData);
        return {
          success: false,
          message: `Invalid OTP. ${3 - storedData.attempts} attempts remaining`
        };
      }
    } catch (error) {
      console.error('OTP verification error:', error);
      throw new Error('Failed to verify OTP');
    }
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

  getOTPMessage(otp, purpose) {
    const messages = {
      'verification': `Your Classy verification code is: ${otp}. Valid for 5 minutes. Don't share this code with anyone.`,
      'password_reset': `Your Classy password reset code is: ${otp}. Valid for 5 minutes. Don't share this code with anyone.`,
      'login': `Your Classy login code is: ${otp}. Valid for 5 minutes. Don't share this code with anyone.`
    };

    return messages[purpose] || messages['verification'];
  }

  // Clean up expired OTPs (call this periodically)
  cleanupExpiredOTPs() {
    const now = Date.now();
    for (const [phone, data] of this.otpStore.entries()) {
      if (now > data.expiresAt) {
        this.otpStore.delete(phone);
      }
    }
  }
}

module.exports = new TwilioService();
