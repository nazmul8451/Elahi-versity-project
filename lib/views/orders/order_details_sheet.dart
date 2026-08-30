import 'package:flutter/material.dart';
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
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text('Placed on ${currentOrder.orderDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20, color: AppColors.border),

              // Order Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: currentOrder.status == OrderStatus.cancelled
                                        ? AppColors.error.withValues(alpha: 0.15)
                                        : currentOrder.status == OrderStatus.delivered
                                            ? AppColors.success.withValues(alpha: 0.15)
                                            : AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    currentOrder.status.title,
                                    style: TextStyle(
                                      fontSize: 11,
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
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'Estimated Delivery: ${currentOrder.estimatedDelivery}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'Tracking: ${currentOrder.trackingNumber}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stepper / Timeline
                      const Text(
                        'Assembly & Delivery Progress',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (currentOrder.status == OrderStatus.cancelled) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.cancel_rounded, color: AppColors.error, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order Cancelled',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'This order was cancelled by the customer or admin.',
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                      const SizedBox(height: 24),

                      // Order Items List
                      Text(
                        'Components Included (${currentOrder.items.length})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
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
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.inputBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.memory_rounded, color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itm.title,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      itm.subtitle,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '৳${itm.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Delivery & Payment info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Shipping Address',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentOrder.shippingAddress,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Payment Method',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentOrder.paymentMethod,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Total & Support Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
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
                          const Text('Total Paid', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text(
                            '৳${currentOrder.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Connecting to Rig Builder Support Desk...')),
                              );
                            },
                            icon: const Icon(Icons.headset_mic_rounded, size: 18),
                            label: const Text('Support'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isPassed ? AppColors.primary : AppColors.inputBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPassed ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: isPassed
                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : null,
                  ),
                  if (status != stages.last)
                    Container(
                      width: 2,
                      height: 32,
                      color: isPassed && !isCurrent ? AppColors.primary : AppColors.border,
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isPassed ? AppColors.textPrimary : AppColors.textLight,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 2),
                      const Text(
                        'Live in-progress',
                        style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 18),
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
