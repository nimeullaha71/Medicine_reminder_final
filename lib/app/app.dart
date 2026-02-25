import 'package:care_agent/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class CareAgent extends StatelessWidget {
  const CareAgent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: "Med AI",
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
