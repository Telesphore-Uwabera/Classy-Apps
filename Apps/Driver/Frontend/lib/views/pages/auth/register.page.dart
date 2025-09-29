import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuodz/services/language.service.dart';
import 'package:fuodz/services/country.service.dart';
import 'package:fuodz/widgets/country_picker_widget.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String selectedServiceType = 'car_driver';
  Map<String, dynamic> _selectedCountry = {
    'name': 'Uganda',
    'code': 'UG',
    'phoneCode': '+256',
    'flag': '🇺🇬',
    'phoneFormat': '### ### ###',
  };

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onCountrySelected(Map<String, dynamic> country) {
    setState(() {
      _selectedCountry = country;
    });
  }

  Widget _buildServiceTypeCard(String title, IconData icon, String value, bool isSelected, Color backgroundColor, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedServiceType = value;
        });
      },
      child: Container(
        width: screenWidth * 0.25, // 25% of screen width
        height: screenWidth * 0.25, // Maintain square aspect
        constraints: BoxConstraints(
          minWidth: 80,
          maxWidth: 120,
          minHeight: 80,
          maxHeight: 120,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Color(0xFFE91E63), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: screenWidth * 0.06, // 6% of screen width
              color: isSelected ? Color(0xFFE91E63) : Colors.grey[600],
            ),
            SizedBox(height: screenHeight * 0.01), // 1% of screen height
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.03, // 3% of screen width
                fontWeight: FontWeight.w600,
                color: isSelected ? Color(0xFFE91E63) : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final fullName = _fullNameController.text.trim();
      final phone = _phoneController.text.trim();
      final location = _locationController.text.trim();
      final password = _passwordController.text.trim();
      final fullPhone = '${_selectedCountry['phoneCode']}$phone';
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      try {
        // Prepare registration data based on service type
        final registrationData = {
          'name': fullName,
          'phone': fullPhone,
          'password': password,
          'password_confirmation': password,
          'address': location,
          'role': 'driver',
          'service_type': selectedServiceType,
          'country_code': _selectedCountry['phoneCode'],
          'driver_type': selectedServiceType, // Add driver type for backend
        };
        
        print('Registration data: $registrationData');
        
        // Use Firebase authentication for registration
        final email = "${fullPhone.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
        
        // Create user with Firebase
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        if (userCredential.user != null) {
          // Update user profile with additional information
          await userCredential.user!.updateDisplayName(fullName);
          
          // Save driver data to Firestore
          await FirebaseFirestore.instance.collection('drivers').doc(userCredential.user!.uid).set({
            'name': fullName,
            'email': email,
            'phone': fullPhone,
            'address': location,
            'service_type': selectedServiceType,
            'driver_type': selectedServiceType,
            'role': 'driver',
            'status': 'pending', // New drivers need approval
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
          // Close loading dialog
          Navigator.of(context).pop();
          
          // Show detailed success message with approval information
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 10),
                  Text('Registration Successful!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your driver account has been created successfully.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.hourglass_empty, color: Colors.orange[700], size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Pending Admin Approval',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your account is currently under review by our admin team. You will receive a notification once your account is approved.',
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'What happens next?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Admin will review your application'),
                  Text('• You will receive an email/SMS notification'),
                  Text('• Once approved, you can login to the app'),
                  Text('• This process usually takes 24-48 hours'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to login
                  },
                  child: Text('Got it', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        }
        
      } catch (error) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        print('Firebase registration error: $error');
        
        // Handle specific Firebase errors
        String errorMessage = "Registration failed. Please try again.";
        if (error.toString().contains('email-already-in-use')) {
          errorMessage = "An account with this phone number already exists.";
        } else if (error.toString().contains('weak-password')) {
          errorMessage = "Password is too weak. Please choose a stronger password.";
        } else if (error.toString().contains('invalid-email')) {
          errorMessage = "Invalid phone number format.";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive mobile design - adapts to actual screen size
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06), // 6% of screen width
          child: Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: screenHeight * 0.1), // 10% of screen height
                  
                  // Logo - Actual Logo Image
                  Center(
                    child: Container(
                      width: screenWidth * 0.2, // 20% of screen width
                      height: screenWidth * 0.2,
                      constraints: BoxConstraints(
                        minWidth: 60,
                        maxWidth: 100,
                        minHeight: 60,
                        maxHeight: 100,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          width: screenWidth * 0.15, // 15% of screen width
                          height: screenWidth * 0.15,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // "Create Account" Title
                  Text(
                    languageService.t('create_account'),
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, // 6% of screen width
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91E63),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: screenHeight * 0.04), // 4% of screen height
                  
                  // Service Type Selection
                  Text(
                    languageService.t('select_service_type'),
                    style: TextStyle(
                      fontSize: screenWidth * 0.04, // 4% of screen width
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.015), // 1.5% of screen height
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildServiceTypeCard(
                        'Car Driver',
                        Icons.car_rental,
                        'car_driver',
                        selectedServiceType == 'car_driver',
                        Colors.blue.shade50,
                        screenWidth,
                        screenHeight,
                      ),
                      _buildServiceTypeCard(
                        'Boda Rider',
                        Icons.two_wheeler,
                        'boda_rider',
                        selectedServiceType == 'boda_rider',
                        Colors.green.shade50,
                        screenWidth,
                        screenHeight,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.04), // 4% of screen height
                  
                  // Registration Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Full Name Field
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: languageService.t('full_name'),
                            hintText: languageService.t('full_name'),
                            prefixIcon: Icon(Icons.person, color: Color(0xFFE91E63)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        
                        SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
                        
                        // Phone Number Field with Country Picker
                        Row(
                          children: [
                            // Country Picker
                            CountryPickerWidget(
                              onCountrySelected: _onCountrySelected,
                              initialCountryCode: 'UG',
                            ),
                            
                            SizedBox(width: screenWidth * 0.03), // 3% of screen width
                            
                            // Phone Number Input
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: languageService.t('phone_number'),
                                  hintText: languageService.t('phone_number'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
                        
                        // Location Field
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: languageService.t('location'),
                            hintText: languageService.t('location'),
                            prefixIcon: Icon(Icons.location_on, color: Color(0xFFE91E63)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your location';
                            }
                            return null;
                          },
                        ),
                        
                        SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
                        
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: languageService.t('password'),
                            hintText: languageService.t('password'),
                            prefixIcon: Icon(Icons.lock, color: Color(0xFFE91E63)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Color(0xFFE91E63),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        
                        SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
                        
                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock, color: Color(0xFFE91E63)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Color(0xFFE91E63),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  
                  // Terms and Privacy Policy
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'By creating an account, you agree to our:',
                          style: TextStyle(
                            fontSize: screenWidth * 0.032, // 3.2% of screen width
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.01), // 1% of screen height
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/terms');
                              },
                              child: Text(
                                'Terms & Conditions',
                                style: TextStyle(
                                  color: Color(0xFFE91E63),
                                  fontSize: screenWidth * 0.032,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              ' and ',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: screenWidth * 0.032,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/privacy');
                              },
                              child: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: Color(0xFFE91E63),
                                  fontSize: screenWidth * 0.032,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
                  
                  // Register Button
                  SizedBox(
                    height: screenHeight * 0.065, // 6.5% of screen height
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        languageService.t('register'),
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // 4% of screen width
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
                  
                  // Already have an account? Login
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          languageService.t('already_have_account'),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.035, // 3.5% of screen width
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/login');
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFFE91E63),
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.035, // 3.5% of screen width
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.05), // 5% of screen height
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
