import 'package:flutter/material.dart';

class AppService {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  
  static BuildContext? get currentContext => _navigatorKey.currentContext;
  
  static NavigatorState? get navigator => _navigatorKey.currentState;
  
  // Driver status
  static bool _driverIsOnline = false;
  
  static bool get driverIsOnline => _driverIsOnline;
  
  static void setDriverOnline(bool isOnline) {
    _driverIsOnline = isOnline;
  }
}