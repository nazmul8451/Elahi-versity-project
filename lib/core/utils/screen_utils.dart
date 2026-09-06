import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized ScreenUtils helper and responsive extensions for the application.
class AppScreenUtils {
  AppScreenUtils._();

  // Screen dimension getters
  static double get screenWidth => 1.sw;
  static double get screenHeight => 1.sh;
  static double get statusBarHeight => ScreenUtil().statusBarHeight;
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  // Responsive padding presets
  static EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);
  static EdgeInsets get dialogPadding => EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h);
  static EdgeInsets get cardPadding => EdgeInsets.all(14.r);

  // Common Spacers
  static Widget get verticalSpace4 => SizedBox(height: 4.h);
  static Widget get verticalSpace8 => SizedBox(height: 8.h);
  static Widget get verticalSpace12 => SizedBox(height: 12.h);
  static Widget get verticalSpace16 => SizedBox(height: 16.h);
  static Widget get verticalSpace20 => SizedBox(height: 20.h);
  static Widget get verticalSpace24 => SizedBox(height: 24.h);
  static Widget get verticalSpace32 => SizedBox(height: 32.h);

  static Widget get horizontalSpace4 => SizedBox(width: 4.w);
  static Widget get horizontalSpace8 => SizedBox(width: 8.w);
  static Widget get horizontalSpace12 => SizedBox(width: 12.w);
  static Widget get horizontalSpace16 => SizedBox(width: 16.w);
  static Widget get horizontalSpace20 => SizedBox(width: 20.w);

  // Radius presets
  static Radius get radius8 => Radius.circular(8.r);
  static Radius get radius12 => Radius.circular(12.r);
  static Radius get radius16 => Radius.circular(16.r);
  static Radius get radius24 => Radius.circular(24.r);

  static BorderRadius get borderRadius8 => BorderRadius.circular(8.r);
  static BorderRadius get borderRadius12 => BorderRadius.circular(12.r);
  static BorderRadius get borderRadius16 => BorderRadius.circular(16.r);
  static BorderRadius get borderRadius24 => BorderRadius.circular(24.r);
}
