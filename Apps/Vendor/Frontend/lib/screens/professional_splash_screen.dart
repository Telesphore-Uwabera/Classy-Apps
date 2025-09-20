import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../services/auth_service.dart';
import '../constants/simple_app_colors.dart';
import '../constants/simple_app_strings.dart';

class ProfessionalSplashScreen extends StatefulWidget {
  const ProfessionalSplashScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalSplashScreen> createState() => _ProfessionalSplashScreenState();
}

class _ProfessionalSplashScreenState extends State<ProfessionalSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthStatus();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      if (authService.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Check if user has seen onboarding before
        // For now, always show onboarding for new users
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primaryColor,
              AppColor.primaryColorDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: VStack([
            // Top spacing
            (context.percentHeight * 15).heightBox,
            
            // Logo section with animation
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoAnimation.value,
                  child: VStack([
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storefront,
                            size: 60,
                            color: AppColor.primaryColor,
                          ),
                          const SizedBox(height: 8),
                          "CLASS".text.bold.color(AppColor.primaryColor).make(),
                        ],
                      ),
                    ),
                  ]),
                );
              },
            ),
            
            // Text section with animation
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _textAnimation.value)),
                  child: Opacity(
                    opacity: _textAnimation.value,
                    child: VStack([
                      const SizedBox(height: 40),
                      
                      // App Name
                      AppStrings.appName.text.xl3.bold.white.makeCentered(),
                      const SizedBox(height: 12),
                      
                      // Subtitle
                      "Professional Vendor Management".text.lg.white.makeCentered(),
                      const SizedBox(height: 8),
                      
                      "Manage orders, products & analytics".text.base.white.makeCentered(),
                    ]),
                  ),
                );
              },
            ),
            
            // Bottom section
            const Spacer(),
            
            // Loading indicator
            VStack([
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              
              const SizedBox(height: 20),
              
              "Loading...".text.white.makeCentered(),
            ]).py20(),
            
            // Bottom spacing
            (context.percentHeight * 5).heightBox,
          ]),
        ),
      ),
    );
  }
}
