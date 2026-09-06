import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_data.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'order_details_sheet.dart';

class OrdersView extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const OrdersView({super.key, this.onNavigateToTab});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final userId = user?.uid ?? 'guest_user';

    return StreamBuilder<List<OrderModel>>(
      stream: FirestoreService().streamUserOrders(userId),
      initialData: AppData.mockOrders,
      builder: (context, snapshot) {
        final rawOrders = snapshot.data;
        final allOrders = (rawOrders != null && rawOrders.isNotEmpty)
            ? rawOrders
            : AppData.mockOrders;
        final activeOrders = allOrders
            .where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled)
            .toList();
        final completedOrders = allOrders
            .where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled)
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'My PC Orders',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
              tabs: [
                Tab(text: 'Active Builds (${activeOrders.length})'),
                Tab(text: 'Completed (${completedOrders.length})'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(activeOrders, isActive: true),
              _buildOrderList(completedOrders, isActive: false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_outlined, size: 44.sp, color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              'No orders found',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 6.h),
            Text(
              'Custom builds you order will show up here',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 20.h),
            if (widget.onNavigateToTab != null)
              ElevatedButton.icon(
                onPressed: () => widget.onNavigateToTab!(1),
                icon: Icon(Icons.build_circle_outlined, size: 18.sp),
                label: Text('Start Custom Build', style: TextStyle(fontSize: 12.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: orders.length,
      separatorBuilder: (context, index) => SizedBox(height: 14.h),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final isDelivered = order.status == OrderStatus.delivered;
    final isCancelled = order.status == OrderStatus.cancelled;

    Color statusBg = AppColors.primarySurface;
    Color statusColor = AppColors.primary;
    if (isDelivered) {
      statusBg = AppColors.success.withValues(alpha: 0.15);
      statusColor = AppColors.success;
    } else if (isCancelled) {
      statusBg = AppColors.error.withValues(alpha: 0.15);
      statusColor = AppColors.error;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.memory_rounded, color: AppColors.primary, size: 20.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Order #${order.id}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        order.status.title,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  order.buildName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${order.items.length} parts • Ordered on ${order.orderDate}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),

                // Order Tracking Stepper Mini
                if (!isDelivered && !isCancelled) ...[
                  Row(
                    children: [
                      Icon(Icons.autorenew_rounded, size: 16.sp, color: AppColors.primary),
                      SizedBox(width: 6.w),
                      Text(
                        'Status: ${order.status.title}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: (order.status.stepIndex + 1) / (OrderStatus.values.length - 1),
                      backgroundColor: AppColors.inputBg,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6.h,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Card Footer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Amount', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                    Text(
                      '৳${order.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => OrderDetailsSheet(order: order),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text(
                        'Track PC',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
