import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/firebase.service.dart';
import 'package:fuodz/firebase_options.dart';

class GeneralAppService {
  //

//Hnadle background message
  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    //if it has not data then it is a normal notification, so ignore it
    if (message.data.isEmpty) return;
    
    // Firebase should already be initialized in main(), but check if it's available
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Firebase might already be initialized, continue
    }
    
    FirebaseService().saveNewNotification(message);
    FirebaseService().showNotification(message);
  }
}
