import 'package:flutter/material.dart';
import 'package:Classy/views/pages/auth/enhanced_login.page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.required = false, Key? key}) : super(key: key);

  final bool required;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return EnhancedLoginPage(required: widget.required);
  }
}
