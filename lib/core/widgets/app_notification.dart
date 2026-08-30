import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum NotificationType {
  orderConfirmed,
  orderCancelled,
  custom,
  success,
  info,
}

class AppNotification {
  /// Show a dynamic push-notification style floating banner
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? trackingNumber,
    NotificationType type = NotificationType.success,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    Color accentColor;
    IconData icon;
    String badgeText;

    switch (type) {
      case NotificationType.orderConfirmed:
        accentColor = const Color(0xFF10B981); // Emerald Green
        icon = Icons.check_circle_rounded;
        badgeText = 'ORDER PLACED';
        break;
      case NotificationType.orderCancelled:
        accentColor = const Color(0xFFEF4444); // Crimson Red
        icon = Icons.cancel_rounded;
        badgeText = 'ORDER CANCELLED';
        break;
      case NotificationType.success:
        accentColor = AppColors.primary;
        icon = Icons.check_circle_rounded;
        badgeText = 'SUCCESS';
        break;
      case NotificationType.info:
      case NotificationType.custom:
        accentColor = AppColors.primaryAccent;
        icon = Icons.notifications_active_rounded;
        badgeText = 'UPDATE';
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        duration: duration,
        padding: EdgeInsets.zero,
        content: GestureDetector(
          onTap: () {
            messenger.hideCurrentSnackBar();
            if (onTap != null) onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A), // Deep Navy Midnight
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: App Logo + Title + Time + Dismiss Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryAccent],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.memory_rounded, color: Colors.white, size: 13),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'PC Builder',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '• Just now',
                      style: TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Main Content Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: accentColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            message,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.3,
                            ),
                          ),
                          if (trackingNumber != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Tracking: $trackingNumber',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Convenience shortcut for order placed
  static void showOrderPlaced(
    BuildContext context, {
    required String orderId,
    required String buildName,
    String? trackingNumber,
    VoidCallback? onTap,
  }) {
    show(
      context,
      type: NotificationType.orderConfirmed,
      title: '🎉 Order Placed Successfully!',
      message: '"$buildName" is confirmed & queued for custom assembly.',
      trackingNumber: trackingNumber ?? 'RC-2026-${orderId.hashCode.abs() % 900000 + 100000}',
      onTap: onTap,
    );
  }

  /// Convenience shortcut for order cancelled
  static void showOrderCancelled(
    BuildContext context, {
    required String orderId,
    required String buildName,
  }) {
    show(
      context,
      type: NotificationType.orderCancelled,
      title: '🚫 Order Cancelled',
      message: 'Order #$orderId ($buildName) has been cancelled.',
    );
  }
}
