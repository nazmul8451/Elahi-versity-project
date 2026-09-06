import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double? borderRadius;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? fontSize;
  final FontWeight fontWeight;
  final double elevation;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.borderColor,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
    this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.elevation = 2.0,
  });

  /// Outlined / Secondary Button variant
  const CustomButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height,
    this.backgroundColor = Colors.transparent,
    this.textColor = AppColors.primary,
    this.borderColor = AppColors.primary,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
    this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.elevation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    final effectiveHeight = height ?? 50.h;
    final effectiveRadius = borderRadius ?? 14.r;
    final effectiveFontSize = fontSize ?? 15.sp;

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor == Colors.transparent
              ? Colors.transparent
              : backgroundColor.withValues(alpha: 0.6),
          elevation: isDisabled ? 0 : elevation,
          shadowColor: backgroundColor.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveRadius),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.5.w)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.r,
                width: 20.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, color: textColor, size: 18.r),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: effectiveFontSize,
                      fontWeight: fontWeight,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    SizedBox(width: 8.w),
                    Icon(suffixIcon, color: textColor, size: 18.r),
                  ],
                ],
              ),
      ),
    );
  }
}
