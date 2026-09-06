import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'views/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PCBuilderApp());
}

class PCBuilderApp extends StatelessWidget {
  const PCBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'PC Builder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashView(),
        );
      },
    );
  }
}
