import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'views/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RigCraftApp());
}

class RigCraftApp extends StatelessWidget {
  const RigCraftApp({super.key});

  @override
  Widget build(BuildContext context)  {
    return MaterialApp(
      title: 'PC Builder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashView(),
    );
  }
}
