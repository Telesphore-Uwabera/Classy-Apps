import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fuodz/services/auth.service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(Duration(seconds: 3), () {
      if (mounted) {
        _loadNextPage();
      }
    });
  }

  void _loadNextPage() {
    // Go directly to login page
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Responsive mobile design - adapts to actual screen size
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Color(0xFFE91E63), // Hot pink/magenta
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container - White rounded square with logo
              Container(
                width: screenWidth * 0.3, // 30% of screen width
                height: screenWidth * 0.3, // Maintain square aspect
                constraints: BoxConstraints(
                  minWidth: 80, // Minimum size
                  maxWidth: 120, // Maximum size
                  minHeight: 80,
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 25,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    width: screenWidth * 0.2, // 20% of screen width
                    height: screenWidth * 0.2,
                  ),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.03), // 3% of screen height
              
              // App Title - "Classy Provider"
              Text(
                "Classy Provider",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.075, // 7.5% of screen width
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: screenHeight * 0.015), // 1.5% of screen height
              
              // App Tagline - "Connecting Providers to Opportunities"
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08), // 8% of screen width
                child: Text(
                  "Connecting Providers to Opportunities",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: screenWidth * 0.04, // 4% of screen width
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: screenHeight * 0.05), // 5% of screen height
              
              // Loading Indicator
              Container(
                width: screenWidth * 0.1, // 10% of screen width
                height: screenWidth * 0.1,
                constraints: BoxConstraints(
                  minWidth: 30,
                  maxWidth: 50,
                  minHeight: 30,
                  maxHeight: 50,
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              
              SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
              
              // Loading Text
              Text(
                "Loading...",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: screenWidth * 0.035, // 3.5% of screen width
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
