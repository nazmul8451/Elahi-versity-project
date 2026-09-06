import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_notification.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';

class OrderDetailsSheet extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OrderModel?>(
      stream: FirestoreService().streamOrder(order.id),
      initialData: order,
      builder: (context, snapshot) {
        final currentOrder = snapshot.data ?? order;

        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Drag Handle
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 12.h),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${currentOrder.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 2.h),
                          Text('Placed on ${currentOrder.orderDate}', style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20, color: AppColors.border),

              // Order Body
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    currentOrder.buildName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: currentOrder.status == OrderStatus.cancelled
                                        ? AppColors.error.withValues(alpha: 0.15)
                                        : currentOrder.status == OrderStatus.delivered
                                            ? AppColors.success.withValues(alpha: 0.15)
                                            : AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    currentOrder.status.title,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: currentOrder.status == OrderStatus.cancelled
                                          ? AppColors.error
                                          : currentOrder.status == OrderStatus.delivered
                                              ? AppColors.success
                                              : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 14.sp, color: AppColors.textSecondary),
                                SizedBox(width: 6.w),
                                Text(
                                  'Estimated Delivery: ${currentOrder.estimatedDelivery}',
                                  style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(Icons.local_shipping_outlined, size: 14.sp, color: AppColors.textSecondary),
                                SizedBox(width: 6.w),
                                Text(
                                  'Tracking: ${currentOrder.trackingNumber}',
                                  style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Stepper / Timeline
                      Text(
                        'Assembly & Delivery Progress',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      if (currentOrder.status == OrderStatus.cancelled) ...[
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cancel_rounded, color: AppColors.error, size: 24.sp),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order Cancelled',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'This order was cancelled by the customer or admin.',
                                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        _buildTrackingTimeline(currentOrder),
                      ],
                      SizedBox(height: 20.h),

                      // Order Items List
                      Text(
                        'Components Included (${currentOrder.items.length})',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 12.h),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentOrder.items.length,
                        separatorBuilder: (context, index) => const Divider(height: 16, color: AppColors.border),
                        itemBuilder: (context, idx) {
                          final itm = currentOrder.items[idx];
                          return Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: AppColors.inputBg,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(Icons.memory_rounded, color: AppColors.primary, size: 20.sp),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itm.title,
                                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      itm.subtitle,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '৳${itm.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Delivery & Payment info
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shipping Address',
                              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              currentOrder.shippingAddress,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Payment Method',
                              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              currentOrder.paymentMethod,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),

              // Total & Support Footer
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10.r,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Paid', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                          Text(
                            '৳${currentOrder.totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (currentOrder.status == OrderStatus.confirmed) ...[
                            OutlinedButton(
                              onPressed: () => _confirmCancelOrder(context, currentOrder),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                              ),
                              child: Text('Cancel', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 8.w),
                          ],
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Connecting to PC Builder Support Desk...')),
                              );
                            },
                            icon: Icon(Icons.headset_mic_rounded, size: 16.sp),
                            label: Text('Support', style: TextStyle(fontSize: 12.sp)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackingTimeline(OrderModel currentOrder) {
    final stages = [
      OrderStatus.confirmed,
      OrderStatus.partsPicked,
      OrderStatus.assembly,
      OrderStatus.stressTesting,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: stages.map((status) {
          final isPassed = status.stepIndex <= currentOrder.status.stepIndex;
          final isCurrent = status == currentOrder.status;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: isPassed ? AppColors.primary : AppColors.inputBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPassed ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: isPassed
                        ? Icon(Icons.check_rounded, size: 12.sp, color: Colors.white)
                        : null,
                  ),
                  if (status != stages.last)
                    Container(
                      width: 2.w,
                      height: 28.h,
                      color: isPassed && !isCurrent ? AppColors.primary : AppColors.border,
                    ),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isPassed ? AppColors.textPrimary : AppColors.textLight,
                      ),
                    ),
                    if (isCurrent) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Live in-progress',
                        style: TextStyle(fontSize: 10.sp, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                    SizedBox(height: 14.h),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _confirmCancelOrder(BuildContext context, OrderModel currentOrder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: Text('Are you sure you want to cancel order #${currentOrder.id} (${currentOrder.buildName})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close details sheet
              await FirestoreService().cancelOrder(currentOrder.id);
              if (context.mounted) {
                AppNotification.showOrderCancelled(
                  context,
                  orderId: currentOrder.id,
                  buildName: currentOrder.buildName,
                );
              }
            },
            child: const Text('Cancel Order', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
