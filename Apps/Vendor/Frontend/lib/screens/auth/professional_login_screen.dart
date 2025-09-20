import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../services/auth_service.dart';
import '../../constants/simple_app_colors.dart';
import '../../constants/simple_app_strings.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'register_screen.dart';

class ProfessionalLoginScreen extends StatefulWidget {
  const ProfessionalLoginScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalLoginScreen> createState() => _ProfessionalLoginScreenState();
}

class _ProfessionalLoginScreenState extends State<ProfessionalLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.signInWithEmailPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login failed. Please try again.'),
            backgroundColor: AppColor.primaryColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: VStack([
            // Top spacing
            (context.percentHeight * 8).heightBox,
            
            // Logo section
            VStack([
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Welcome message
              "Welcome Back".text.xl2.semiBold.color(AppColor.primaryColor).makeCentered(),
              const SizedBox(height: 8),
              "Login to your vendor app".text.light.gray600.makeCentered(),
            ]).py12(),
            
            // Form section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: VStack([
                  // Email field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.email,
                            color: AppColor.primaryColor,
                            size: 20,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: "Email Address",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ).py12(),
                  
                  // Password field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.lock,
                            color: AppColor.primaryColor,
                            size: 20,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: "Password",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
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
                        ),
                      ],
                    ),
                  ).py12(),

                  // Forgot password
                  "Forgot Password ?".text.underline.color(AppColor.primaryColor).make().onInkTap(
                    () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Forgot password feature coming soon'),
            backgroundColor: AppColor.primaryColor,
          ),
        );
                    },
                  ).py8(),
                  
                  // Login button
                  CustomButton(
                    text: "Login",
                    onPressed: _isLoading ? null : _signIn,
                    isLoading: _isLoading,
                    backgroundColor: AppColor.primaryColor,
                  ).centered().py12(),

                  const SizedBox(height: 20),
                  
                  // Divider
                  HStack([
                    Container(height: 1, color: Colors.grey.shade300).expand(),
                    "OR".text.gray500.make().px16(),
                    Container(height: 1, color: Colors.grey.shade300).expand(),
                  ]).py8(),
                  
                  const SizedBox(height: 20),
                  
                  // Sign up link
                  HStack([
                    "Don't have an account? ".text.gray600.make(),
                    "Sign Up".text.color(AppColor.primaryColor).bold.make().onInkTap(
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                  ]).centered(),
                ]),
              ),
            ).py20(),
            
            // Bottom spacing
            (context.percentHeight * 4).heightBox,
          ]),
        ),
      ),
    );
  }
}
