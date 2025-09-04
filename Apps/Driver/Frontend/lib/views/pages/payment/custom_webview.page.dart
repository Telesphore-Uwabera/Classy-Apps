// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:fuodz/constants/app_colors.dart';
// import 'package:fuodz/services/app.service.dart';
// import 'package:fuodz/services/http.service.dart';
// import 'package:fuodz/widgets/base.page.dart';
// import 'package:localize_and_translate/localize_and_translate.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:velocity_x/velocity_x.dart';
// import 'package:fuodz/extensions/context.dart';

// Simple placeholder for webview functionality
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomWebviewPage extends StatefulWidget {
  CustomWebviewPage({
    Key? key,
    required this.selectedUrl,
  }) : super(key: key);

  final String selectedUrl;

  @override
  _CustomWebviewPageState createState() => _CustomWebviewPageState();
}

class _CustomWebviewPageState extends State<CustomWebviewPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Web Page",
      body: Center(
        child: VStack([
          Icon(
            Icons.web,
            size: 80,
            color: AppColor.classyPrimary,
          ).py16(),
          Text(
            "Web View Not Available",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary,
            ),
          ).py16(),
          Text(
            "This feature has been simplified for the driver app.",
            style: TextStyle(
              fontSize: 16,
              color: AppColor.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).py16(),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Go Back"),
          ),
        ]),
      ),
    );
  }
}
