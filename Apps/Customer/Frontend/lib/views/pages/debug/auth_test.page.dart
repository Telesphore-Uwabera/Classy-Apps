import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/services/unified_auth.service.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class AuthTestPage extends StatefulWidget {
  const AuthTestPage({Key? key}) : super(key: key);

  @override
  _AuthTestPageState createState() => _AuthTestPageState();
}

class _AuthTestPageState extends State<AuthTestPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String _status = "Ready to test authentication";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = "test@classy.app";
    _passwordController.text = "password123";
    _nameController.text = "Test User";
    _phoneController.text = "+1234567890";
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: "Authentication Test",
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: VStack([
          // Status Display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isLoading ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _status,
              style: TextStyle(
                color: _isLoading ? Colors.blue.shade700 : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          20.heightBox,

          // Test Forms
          VStack([
            "Email/Password Authentication".tr().text.xl.bold.make(),
            16.heightBox,

            CustomTextFormField(
              labelText: "Email",
              textEditingController: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            12.heightBox,

            CustomTextFormField(
              labelText: "Password",
              textEditingController: _passwordController,
              obscureText: true,
            ),
            12.heightBox,

            CustomTextFormField(
              labelText: "Name (for registration)",
              textEditingController: _nameController,
            ),
            12.heightBox,

            CustomTextFormField(
              labelText: "Phone (for registration)",
              textEditingController: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            20.heightBox,

            // Email/Password Buttons
            HStack([
              CustomButton(
                title: "Login",
                onPressed: _testEmailPasswordLogin,
                loading: _isLoading,
              ).expand(),
              12.widthBox,
              CustomButton(
                title: "Register",
                onPressed: _testEmailPasswordRegister,
                loading: _isLoading,
                color: Colors.green,
              ).expand(),
            ]),
          ]),

          30.heightBox,

          // Social login removed - only phone/password authentication available

          30.heightBox,

          // Current User Info
          VStack([
            "Current User Info".tr().text.xl.bold.make(),
            16.heightBox,

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: VStack([
                Text("Authenticated: ${UnifiedAuthService.isAuthenticated()}"),
                8.heightBox,
                Text("User: ${UnifiedAuthService.getCurrentUser()?.name ?? 'None'}"),
                8.heightBox,
                Text("Email: ${UnifiedAuthService.getCurrentUser()?.email ?? 'None'}"),
                8.heightBox,
                Text("Phone: ${UnifiedAuthService.getCurrentUser()?.phone ?? 'None'}"),
              ]),
            ),
          ]),

          30.heightBox,

          // Logout Button
          CustomButton(
            title: "Logout",
            onPressed: _testLogout,
            loading: _isLoading,
            color: Colors.red,
          ),

          20.heightBox,

          // Navigation Buttons
          HStack([
            CustomButton(
              title: "Go to Home",
              onPressed: () => Navigator.pushNamed(context, AppRoutes.homeRoute),
              color: Colors.blue,
            ).expand(),
            12.widthBox,
            CustomButton(
              title: "Go to Login",
              onPressed: () => Navigator.pushNamed(context, AppRoutes.loginRoute),
              color: Colors.orange,
            ).expand(),
          ]),
        ]),
      ),
    );
  }

  void _setStatus(String status) {
    setState(() {
      _status = status;
    });
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  Future<void> _testEmailPasswordLogin() async {
    _setLoading(true);
    _setStatus("Testing email/password login...");

    try {
      final result = await UnifiedAuthService.signInWithEmailPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result['success'] == true) {
        _setStatus("✅ Email/password login successful!");
        setState(() {}); // Refresh UI
      } else {
        _setStatus("❌ Email/password login failed: ${result['message']}");
      }
    } catch (e) {
      _setStatus("❌ Email/password login error: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _testEmailPasswordRegister() async {
    _setLoading(true);
    _setStatus("Testing email/password registration...");

    try {
      final result = await UnifiedAuthService.signUpWithEmailPassword(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        phone: _phoneController.text,
      );

      if (result['success'] == true) {
        _setStatus("✅ Email/password registration successful!");
        setState(() {}); // Refresh UI
      } else {
        _setStatus("❌ Email/password registration failed: ${result['message']}");
      }
    } catch (e) {
      _setStatus("❌ Email/password registration error: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Social login test methods removed - only phone/password authentication available

  Future<void> _testLogout() async {
    _setLoading(true);
    _setStatus("Testing logout...");

    try {
      await UnifiedAuthService.signOut();
      _setStatus("✅ Logout successful!");
      setState(() {}); // Refresh UI
    } catch (e) {
      _setStatus("❌ Logout error: $e");
    } finally {
      _setLoading(false);
    }
  }
}
