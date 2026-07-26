import 'package:flutter/material.dart';

import '../features/onboarding/splash_screen.dart';

class RumiApp extends StatelessWidget {
  const RumiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '루미아의 별정원',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8C72D9),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
