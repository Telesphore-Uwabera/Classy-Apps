import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language.service.dart';
import '../../services/auth.service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    // Check if user is already authenticated
    if (await AuthServices.authenticated()) {
      // User is already logged in, go directly to dashboard
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive mobile design
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Color(0xFFE91E63),
      body: SafeArea(
        child: Column(
          children: [
            // Top section with logo and welcome text
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: screenWidth * 0.25,
                      height: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
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
                    
                    // Welcome Text
                    Text(
                      'Welcome to Classy Driver',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    
                    Text(
                      'Your trusted partner for safe and reliable transportation services',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: screenWidth * 0.045,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom section with action buttons
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.08),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Login Button
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.07,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.03),
                    
                    // Create Account Button
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.07,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/register');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFFE91E63),
                          side: BorderSide(color: Color(0xFFE91E63), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.04),
                    
                    // Language Selection
                    Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Language: ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed('/language');
                              },
                              child: Text(
                                languageService.currentLanguage == 'en' ? 'English' : 'Other',
                                style: TextStyle(
                                  color: Color(0xFFE91E63),
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
