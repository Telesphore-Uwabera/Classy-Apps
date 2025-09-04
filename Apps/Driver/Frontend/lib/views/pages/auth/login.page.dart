import 'package:flutter/material.dart';
import 'package:fuodz/services/language.service.dart';
import 'package:fuodz/services/country.service.dart';
import 'package:fuodz/widgets/country_picker_widget.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  Map<String, dynamic> _selectedCountry = {
    'code': 'UG',
    'name': 'Uganda',
    'flag': '🇺🇬',
    'phoneCode': '+256',
    'phoneFormat': '### ### ###'
  };

  @override
  void initState() {
    super.initState();
    // No pre-filled credentials - user will enter their real phone number
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCountrySelected(Map<String, dynamic> country) {
    setState(() {
      _selectedCountry = country;
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text.trim();
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
        // Use password-based login
        final authRequest = AuthRequest();
        
        // Login with phone and password
        final response = await authRequest.loginRequest(
          phone: fullPhone, // Using phone directly
          password: password,
        );
        
        // Close loading dialog
        Navigator.of(context).pop();
        
        if (response.allGood) {
          // Save user data and token
          await AuthServices.saveUser(response.body);
          await AuthServices.setAuthBearerToken(response.body['token']);
          await AuthServices.isAuthenticated();
          
          // Navigate to dashboard
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Login failed: ${response.message}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        
      } catch (e) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Login failed: ${e.toString()}'),
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
          child: Form(
            key: _formKey,
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
                    
                    SizedBox(height: screenHeight * 0.05), // 5% of screen height
                    
                    // Welcome Text
                    Text(
                      languageService.t('welcome_back'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.075, // 7.5% of screen width
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenHeight * 0.01), // 1% of screen height
                    
                    Text(
                      languageService.t('login_to_provider_account'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // 4% of screen width
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenHeight * 0.06), // 6% of screen height
                    
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
                    
                    SizedBox(height: screenHeight * 0.03), // 3% of screen height
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Color(0xFFE91E63)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: screenHeight * 0.05), // 5% of screen height
                    
                    // Login Button
                    SizedBox(
                      height: screenHeight * 0.065, // 6.5% of screen height
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04, // 4% of screen width
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.05), // 5% of screen height
                    
                    // Register Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            languageService.t('dont_have_account'),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: screenWidth * 0.035, // 3.5% of screen width
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/register');
                            },
                            child: Text(
                              languageService.t('register'),
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
                    
                    SizedBox(height: screenHeight * 0.03), // 3% of screen height
                    
                    // Terms and Privacy Policy
                    Text(
                      'By continuing, you agree to our:',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: screenWidth * 0.032, // 3.2% of screen width
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenHeight * 0.01), // 1% of screen height
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Navigate to terms page
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
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.032,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to privacy page
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
                    
                    SizedBox(height: screenHeight * 0.05), // 5% of screen height
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
