import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../models/custom_build_state.dart';
import '../../models/pc_component_model.dart';

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
                                '\$${comp.price.toStringAsFixed(2)}',
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
                          subtitle: const Text('+\$29.99 (Special bundle price)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                            '\$${grandTotal.toStringAsFixed(2)}',
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
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Rig successfully saved to your Profile!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            icon: const Icon(Icons.bookmark_outline_rounded, size: 18),
                            label: const Text('Save Rig'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              if (widget.onNavigateToTab != null) {
                                widget.onNavigateToTab!(2); // Navigate to Orders Tab
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order placed successfully! Assembly started.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                            label: const Text('Place Order'),
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
}
