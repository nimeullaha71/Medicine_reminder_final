import 'package:care_agent/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';


class CareAgent extends StatelessWidget {
  const CareAgent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: "Med AI",
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
