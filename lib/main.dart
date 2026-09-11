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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        final responsiveWidth = isLargeScreen ? 480.0 : constraints.maxWidth;

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: Size(responsiveWidth, constraints.maxHeight),
          ),
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'PC Builder',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                builder: (context, routerChild) {
                  if (!isLargeScreen) {
                    return routerChild ?? const SizedBox.shrink();
                  }
                  return Container(
                    color: const Color(0xFF0F172A),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 480),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 36,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: routerChild,
                      ),
                    ),
                  );
                },
                home: const SplashView(),
              );
            },
          ),
        );
      },
    );
  }
}
