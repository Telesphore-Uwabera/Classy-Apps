import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

class DriverConnectionPage extends StatefulWidget {
  final String pickup;
  final String destination;
  final String bodaType;

  const DriverConnectionPage({
    Key? key,
    required this.pickup,
    required this.destination,
    required this.bodaType,
  }) : super(key: key);

  @override
  _DriverConnectionPageState createState() => _DriverConnectionPageState();
}

class _DriverConnectionPageState extends State<DriverConnectionPage>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeInOut),
    );
    _rippleController.repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with ripple effect
            Expanded(
              flex: 2,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple circles
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_rippleAnimation.value * 0.3),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade200.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_rippleAnimation.value * 0.6),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade300.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_rippleAnimation.value * 0.9),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade400.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Main car icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_taxi,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Connection status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  "Connecting you to a driver".text.bold.xl2.color(AppColor.primaryColor).make(),
                  SizedBox(height: 8),
                  "Please wait while we find the best driver for you".text.gray600.lg.make().centered(),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // Location details card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Pickup location
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 24),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.pickup,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Divider
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  
                  // Destination location
                  Row(
                    children: [
                      Icon(Icons.my_location, color: Colors.red, size: 24),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.destination,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Service type and payment method
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColor.primaryColor, width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_taxi, color: AppColor.primaryColor, size: 16),
                              SizedBox(width: 8),
                              widget.bodaType.text.color(AppColor.primaryColor).sm.make(),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColor.primaryColor, width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.account_balance_wallet, color: AppColor.primaryColor, size: 16),
                              SizedBox(width: 8),
                              "Cashless".text.color(AppColor.primaryColor).sm.make(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // Cancel button
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColor.primaryColor, width: 1),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: "Cancel".text.color(Colors.red).bold.make(),
              ),
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
