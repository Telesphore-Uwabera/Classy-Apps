import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class HtmlTextView extends StatelessWidget {
  const HtmlTextView(this.htmlContent, {Key? key}) : super(key: key);

  final String htmlContent;

  @override
  Widget build(BuildContext context) {
    // Simple text display instead of HTML rendering
    return Text(
      htmlContent.replaceAll(RegExp(r'<[^>]*>'), ''), // Remove HTML tags
      style: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
    ).px20();
  }
}
