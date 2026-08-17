import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double borderRadius;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double fontSize;
  final FontWeight fontWeight;
  final double elevation;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height = 52.0,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.borderColor,
    this.borderRadius = 14.0,
    this.prefixIcon,
    this.suffixIcon,
    this.fontSize = 16.0,
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
    this.height = 52.0,
    this.backgroundColor = Colors.transparent,
    this.textColor = AppColors.primary,
    this.borderColor = AppColors.primary,
    this.borderRadius = 14.0,
    this.prefixIcon,
    this.suffixIcon,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.elevation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
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
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.5)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
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
                    Icon(prefixIcon, color: textColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(suffixIcon, color: textColor, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}
