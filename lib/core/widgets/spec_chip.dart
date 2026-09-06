import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? textColor;

  const SpecChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.inputBg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.sp,
            color: iconColor ?? AppColors.primary,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
