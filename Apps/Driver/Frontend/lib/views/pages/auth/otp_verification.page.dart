import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;
  final bool isLogin;
  
  const OtpVerificationPage({
    Key? key,
    required this.phoneNumber,
    required this.countryCode,
    this.isLogin = false,
  }) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  
  bool _isResendEnabled = true;
  int _resendCountdown = 30;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
            _startResendTimer();
          } else {
            _isResendEnabled = true;
          }
        });
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    _checkOtpComplete();
  }

  void _checkOtpComplete() {
    String otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length == 4) {
      _verifyOtp(otp);
    }
  }

  void _verifyOtp(String otp) async {
    setState(() {
      _isVerifying = true;
    });

    try {
      final authRequest = AuthRequest();
      
      if (widget.isLogin) {
        // Login with OTP
        final response = await authRequest.verifyOTP(widget.phoneNumber, otp, isLogin: true);
        
        if (response.allGood) {
          // Save user data and token
          await AuthServices.saveUser(response.body);
          await AuthServices.setAuthBearerToken(response.body['token']);
          await AuthServices.isAuthenticated();
          
          if (mounted) {
            setState(() {
              _isVerifying = false;
            });
            _showSuccessDialog('Login successful! Welcome to Classy Driver App');
          }
        } else {
          throw Exception(response.message);
        }
      } else {
        // Registration verification
        final response = await authRequest.verifyOTP(widget.phoneNumber, otp, isLogin: false);
        
        if (response.allGood) {
          if (mounted) {
            setState(() {
              _isVerifying = false;
            });
            _showSuccessDialog('Phone number verified successfully!');
          }
        } else {
          throw Exception(response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
        _showErrorDialog('Verification failed: ${e.toString()}');
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.isLogin) {
                Navigator.of(context).pushReplacementNamed('/dashboard');
              } else {
                Navigator.of(context).pushReplacementNamed('/register');
              }
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verification Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearOtp();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearOtp() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _resendOtp() {
    setState(() {
      _isResendEnabled = false;
      _resendCountdown = 30;
    });
    _startResendTimer();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP resent successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Verify Phone Number',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFE91E63),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.08),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),
              
              // Logo
              Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.04),
              
              // Title
              Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: screenHeight * 0.02),
              
              // Subtitle
              Text(
                'We\'ve sent a 4-digit code to',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: screenHeight * 0.01),
              
              Text(
                '${widget.countryCode} ${widget.phoneNumber}',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE91E63),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: screenHeight * 0.05),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) => _onOtpChanged(value, index),
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  );
                }),
              ),
              
              SizedBox(height: screenHeight * 0.05),
              
              // Verify Button
              Container(
                width: double.infinity,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : () {
                    String otp = _otpControllers.map((controller) => controller.text).join();
                    if (otp.length == 4) {
                      _verifyOtp(otp);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: _isVerifying
                      ? SizedBox(
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.04),
              
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive the code? ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isResendEnabled ? _resendOtp : null,
                    child: Text(
                      _isResendEnabled
                          ? 'Resend'
                          : 'Resend in $_resendCountdown seconds',
                      style: TextStyle(
                        color: _isResendEnabled ? Color(0xFFE91E63) : Colors.grey[400],
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                        decoration: _isResendEnabled ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Change Phone Number
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Change Phone Number',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
