import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class LiveBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const LiveBadge({
    super.key,
    required this.text,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.icon,
  });

  factory LiveBadge.hotDeal(String text) {
    return LiveBadge(
      text: text,
      backgroundColor: AppColors.accentAmber,
      textColor: Colors.black,
      icon: Icons.local_fire_department_rounded,
    );
  }

  factory LiveBadge.bestseller(String text) {
    return LiveBadge(
      text: text,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      icon: Icons.star_rounded,
    );
  }

  factory LiveBadge.pro(String text) {
    return LiveBadge(
      text: text,
      backgroundColor: AppColors.accentPurple,
      textColor: Colors.white,
      icon: Icons.bolt_rounded,
    );
  }

  factory LiveBadge.success(String text) {
    return LiveBadge(
      text: text,
      backgroundColor: AppColors.success.withValues(alpha: 0.15),
      textColor: AppColors.success,
      icon: Icons.check_circle_rounded,
    );
  }

  factory LiveBadge.warning(String text) {
    return LiveBadge(
      text: text,
      backgroundColor: AppColors.warning.withValues(alpha: 0.15),
      textColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11.sp, color: textColor),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
