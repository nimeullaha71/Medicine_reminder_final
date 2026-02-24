// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'app/app.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   print("🔥 Firebase Connected");
//
//   await GetStorage.init();
//   runApp(const CareAgent());
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'app/app.dart';
import 'core/services/storage/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  print("🔥 Firebase Connected");

  await GetStorage.init();

  // 🔥 ADD THIS
  await PushNotificationService.initialize();

  runApp(const CareAgent());
}