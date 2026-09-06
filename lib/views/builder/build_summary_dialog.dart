import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/app_notification.dart';
import '../../models/custom_build_state.dart';
import '../../models/order_model.dart';
import '../../models/pc_component_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class BuildSummaryDialog extends StatefulWidget {
  final CustomBuildState customBuildState;
  final Function(int)? onNavigateToTab;

  const BuildSummaryDialog({
    super.key,
    required this.customBuildState,
    this.onNavigateToTab,
  });

  @override
  State<BuildSummaryDialog> createState() => _BuildSummaryDialogState();
}

class _BuildSummaryDialogState extends State<BuildSummaryDialog> {
  bool _includeOs = true;
  bool _includeStressTesting = true;
  bool _isProcessing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customBuildState.buildName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final components = widget.customBuildState.selectedComponents.values.toList();
    final partsTotal = widget.customBuildState.totalPrice;
    final osPrice = _includeOs ? 29.99 : 0.0;
    final grandTotal = partsTotal + osPrice;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                Text(
                  'PC Build Summary & Order',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PC Name Edit Field
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: TextStyle(fontSize: 14.sp),
                            decoration: InputDecoration(
                              labelText: 'Custom Build Name',
                              labelStyle: TextStyle(fontSize: 12.sp),
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) => widget.customBuildState.setBuildName(val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Target Budget Analysis Card (if set)
                  if (widget.customBuildState.hasBudget) ...[
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: widget.customBuildState.isOverBudget
                            ? AppColors.error.withValues(alpha: 0.08)
                            : AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: widget.customBuildState.isOverBudget
                              ? AppColors.error.withValues(alpha: 0.3)
                              : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.customBuildState.isOverBudget
                                ? Icons.warning_amber_rounded
                                : Icons.account_balance_wallet_rounded,
                            color: widget.customBuildState.isOverBudget
                                ? AppColors.error
                                : AppColors.primary,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Target Budget: ৳${widget.customBuildState.targetBudget!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                        color: widget.customBuildState.isOverBudget
                                            ? AppColors.error
                                            : AppColors.primary,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: widget.customBuildState.isOverBudget
                                            ? AppColors.error
                                            : AppColors.success,
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        widget.customBuildState.isOverBudget
                                            ? '+৳${widget.customBuildState.budgetOverAmount.toStringAsFixed(0)} Over'
                                            : '৳${widget.customBuildState.budgetRemaining.toStringAsFixed(0)} Left',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  widget.customBuildState.isOverBudget
                                      ? 'Your build exceeds your defined budget. You can still order or adjust parts.'
                                      : 'Awesome! Your build configuration is completely within your target budget.',
                                  style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],

                  // Power & Compatibility Status
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: widget.customBuildState.isFullyCompatible
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: widget.customBuildState.isFullyCompatible
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.customBuildState.isFullyCompatible
                              ? Icons.verified_rounded
                              : Icons.warning_amber_rounded,
                          color: widget.customBuildState.isFullyCompatible
                              ? AppColors.success
                              : AppColors.warning,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.customBuildState.isFullyCompatible
                                    ? 'Hardware Compatibility Verified'
                                    : 'Review Component Compatibility',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                  color: widget.customBuildState.isFullyCompatible
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                              Text(
                                'Estimated Power Draw: ${widget.customBuildState.totalEstimatedWattage}W',
                                style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Selected Parts List
                  Text(
                    'Selected Components',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: components.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final comp = components[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          child: Row(
                            children: [
                              AppNetworkImage(
                                imageUrl: comp.imageUrl,
                                width: 44.w,
                                height: 44.w,
                                borderRadius: BorderRadius.circular(8.r),
                                fallbackIcon: comp.category.icon,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comp.category.displayName,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      comp.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '৳${comp.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Optional Add-on Services
                  Text(
                    'Assembly & Setup Services',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          value: true,
                          onChanged: null, // Always included for free
                          activeColor: AppColors.success,
                          contentPadding: EdgeInsets.zero,
                          title: Text('Free Professional Cable Management', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          subtitle: Text('Included Free of Charge', style: TextStyle(fontSize: 10.sp, color: AppColors.success)),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        CheckboxListTile(
                          value: _includeStressTesting,
                          onChanged: (val) => setState(() => _includeStressTesting = val ?? true),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          title: Text('24h Stress Testing & BIOS Optimization', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          subtitle: Text('FREE Promo', style: TextStyle(fontSize: 10.sp, color: AppColors.primary)),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        CheckboxListTile(
                          value: _includeOs,
                          onChanged: (val) => setState(() => _includeOs = val ?? true),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          title: Text('Windows 11 Pro 64-bit License & Installed', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          subtitle: Text('+৳2,500 (Special bundle price)', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),

          // Bottom Checkout Bar
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Grand Total', style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                          Text(
                            '৳${grandTotal.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () => _handleSaveBuild(components, grandTotal),
                            icon: Icon(Icons.bookmark_outline_rounded, size: 16.sp),
                            label: Text('Save', style: TextStyle(fontSize: 12.sp)),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () => _showCheckoutSheet(components, grandTotal),
                            icon: _isProcessing
                                ? SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Icon(Icons.check_circle_outline_rounded, size: 16.sp),
                            label: Text(_isProcessing ? 'Wait...' : 'Place Order', style: TextStyle(fontSize: 12.sp)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            ),
                          ),
                        ],
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
  }

  Future<void> _handleSaveBuild(List<PcComponent> components, double grandTotal) async {
    final user = AuthService().currentUser;
    final uid = user?.uid ?? 'guest_user';
    setState(() => _isProcessing = true);
    try {
      await FirestoreService().saveCustomBuild(
        userId: uid,
        name: widget.customBuildState.buildName,
        components: components,
        totalPrice: grandTotal,
        totalWattage: widget.customBuildState.totalEstimatedWattage,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PC build successfully saved to your Cloud Profile!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save PC build: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showCheckoutSheet(List<PcComponent> components, double grandTotal) {
    final addressController = TextEditingController(text: 'House 42, Road 11, Banani, Dhaka');
    final phoneController = TextEditingController(text: '+880 1700-000000');
    String selectedPayment = 'Cash on Delivery';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery & Payment',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 22.sp),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: addressController,
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  labelText: 'Shipping Address',
                  labelStyle: TextStyle(fontSize: 12.sp),
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20.sp),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: phoneController,
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  labelText: 'Contact Phone',
                  labelStyle: TextStyle(fontSize: 12.sp),
                  prefixIcon: Icon(Icons.phone_outlined, size: 20.sp),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Payment Method', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  ChoiceChip(
                    label: Text('Cash on Delivery', style: TextStyle(fontSize: 12.sp)),
                    selected: selectedPayment == 'Cash on Delivery',
                    onSelected: (_) => setSheetState(() => selectedPayment = 'Cash on Delivery'),
                  ),
                  ChoiceChip(
                    label: Text('bKash / Nagad', style: TextStyle(fontSize: 12.sp)),
                    selected: selectedPayment == 'bKash / Nagad',
                    onSelected: (_) => setSheetState(() => selectedPayment = 'bKash / Nagad'),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetCtx);
                    await _submitOrder(
                      components: components,
                      grandTotal: grandTotal,
                      address: addressController.text.trim(),
                      paymentMethod: selectedPayment,
                    );
                  },
                  icon: Icon(Icons.check_circle_rounded, size: 20.sp),
                  label: Text(
                    'Confirm Order (৳${grandTotal.toStringAsFixed(0)})',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitOrder({
    required List<PcComponent> components,
    required double grandTotal,
    required String address,
    required String paymentMethod,
  }) async {
    final user = AuthService().currentUser;
    final uid = user?.uid ?? 'guest_user';

    setState(() => _isProcessing = true);

    try {
      final List<OrderItemModel> items = components
          .map((c) => OrderItemModel(
                title: c.name,
                subtitle: '${c.category.displayName} • ${c.brand}',
                price: c.price,
                quantity: 1,
              ))
          .toList();

      if (_includeOs) {
        items.add(const OrderItemModel(
          title: 'Windows 11 Pro 64-bit License',
          subtitle: 'Installed and configured',
          price: 1500.0,
          quantity: 1,
        ));
      }

      final orderId = await FirestoreService().createOrder(
        userId: uid,
        buildName: widget.customBuildState.buildName,
        totalAmount: grandTotal,
        items: items,
        shippingAddress: address,
        paymentMethod: paymentMethod,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close summary dialog

      final placedBuildName = widget.customBuildState.buildName;

      // Reset custom builder
      widget.customBuildState.reset();

      // Navigate to Orders Tab
      if (widget.onNavigateToTab != null) {
        widget.onNavigateToTab!(2);
      }

      AppNotification.showOrderPlaced(
        context,
        orderId: orderId,
        buildName: placedBuildName.isEmpty ? 'Custom PC Build' : placedBuildName,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit order: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
