import 'package:flutter/material.dart';
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
                const Text(
                  'Rig Summary & Order',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rig Name Edit Field
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Custom Build Name',
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
                  const SizedBox(height: 16),

                  // Power & Compatibility Status
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: widget.customBuildState.isFullyCompatible
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
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
                          size: 24,
                        ),
                        const SizedBox(width: 12),
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
                                  fontSize: 13,
                                  color: widget.customBuildState.isFullyCompatible
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                              Text(
                                'Estimated Rig Draw: ${widget.customBuildState.totalEstimatedWattage}W',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Selected Parts List
                  const Text(
                    'Selected Components',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              AppNetworkImage(
                                imageUrl: comp.imageUrl,
                                width: 44,
                                height: 44,
                                borderRadius: BorderRadius.circular(8),
                                fallbackIcon: comp.category.icon,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comp.category.displayName,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      comp.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '৳${comp.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
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
                  const SizedBox(height: 20),

                  // Optional Add-on Services
                  const Text(
                    'Assembly & Setup Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          value: true,
                          onChanged: null, // Always included for free
                          activeColor: AppColors.success,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Free Professional Cable Management', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Included Free of Charge', style: TextStyle(fontSize: 11, color: AppColors.success)),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        CheckboxListTile(
                          value: _includeStressTesting,
                          onChanged: (val) => setState(() => _includeStressTesting = val ?? true),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('24h Stress Testing & BIOS Optimization', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('FREE Promo', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        CheckboxListTile(
                          value: _includeOs,
                          onChanged: (val) => setState(() => _includeOs = val ?? true),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Windows 11 Pro 64-bit License & Installed', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('+৳2,500 (Special bundle price)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Bottom Checkout Bar
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Grand Total', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            '৳${grandTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
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
                                : () => _handleSaveRig(components, grandTotal),
                            icon: const Icon(Icons.bookmark_outline_rounded, size: 18),
                            label: const Text('Save Rig'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () => _showCheckoutSheet(components, grandTotal),
                            icon: _isProcessing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.check_circle_outline_rounded, size: 18),
                            label: Text(_isProcessing ? 'Processing...' : 'Place Order'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Future<void> _handleSaveRig(List<PcComponent> components, double grandTotal) async {
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
          content: Text('Rig successfully saved to your Cloud Profile!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save rig: $e'),
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
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery & Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Shipping Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Cash on Delivery'),
                    selected: selectedPayment == 'Cash on Delivery',
                    onSelected: (_) => setSheetState(() => selectedPayment = 'Cash on Delivery'),
                  ),
                  ChoiceChip(
                    label: const Text('bKash / Nagad'),
                    selected: selectedPayment == 'bKash / Nagad',
                    onSelected: (_) => setSheetState(() => selectedPayment = 'bKash / Nagad'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text('Confirm Order (৳${grandTotal.toStringAsFixed(0)})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        buildName: placedBuildName.isEmpty ? 'Custom PC Rig' : placedBuildName,
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
