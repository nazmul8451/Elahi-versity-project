import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'views/splash/splash_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RigCraftApp());
}

class RigCraftApp extends StatelessWidget {
  const RigCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RigCraft PC Builder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashView(),
    );
  }
}
