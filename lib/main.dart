import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'ui/splash_screen.dart'; // 👈 notre splash zen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KaisenApp());
}

class KaisenApp extends StatelessWidget {
  const KaisenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAISEN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const SplashScreen(), // 👈 démarre par le splash
    );
  }
}
