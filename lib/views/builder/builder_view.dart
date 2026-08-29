import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../models/custom_build_state.dart';
import '../../models/pc_component_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'build_summary_dialog.dart';
import 'component_picker_sheet.dart';

class BuilderView extends StatelessWidget {
  final CustomBuildState customBuildState;
  final Function(int)? onNavigateToTab;

  const BuilderView({
    super.key,
    required this.customBuildState,
    this.onNavigateToTab,
  });

  static const List<ComponentCategory> requiredSlots = [
    ComponentCategory.cpu,
    ComponentCategory.motherboard,
    ComponentCategory.gpu,
    ComponentCategory.ram,
    ComponentCategory.storage,
    ComponentCategory.psu,
    ComponentCategory.cooler,
    ComponentCategory.casing,
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: customBuildState,
      builder: (context, _) {
        final selected = customBuildState.selectedComponents;
        final warnings = customBuildState.compatibilityWarnings;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customBuildState.buildName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${customBuildState.selectedCount} of ${customBuildState.totalRequiredCount} parts configured',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                tooltip: 'Reset Build',
                onPressed: () {
                  if (customBuildState.selectedCount > 0) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Build?'),
                        content: const Text('This will clear all selected components in your custom build.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              customBuildState.reset();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Reset', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined, color: AppColors.primary),
                tooltip: 'Save Rig',
                onPressed: () async {
                  if (customBuildState.selectedCount == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one component to save a rig.'),
                      ),
                    );
                    return;
                  }

                  final user = AuthService().currentUser;
                  final uid = user?.uid ?? 'guest_user';

                  try {
                    await FirestoreService().saveCustomBuild(
                      userId: uid,
                      name: customBuildState.buildName,
                      components: customBuildState.selectedComponents.values.toList(),
                      totalPrice: customBuildState.totalPrice,
                      totalWattage: customBuildState.totalEstimatedWattage,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Custom build saved to Cloud Profile!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not save build: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Sticky Live Dashboard Header
              _buildLiveDashboard(context, warnings),

              // Slots List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: requiredSlots.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final category = requiredSlots[index];
                    final item = selected[category];
                    return _buildSlotCard(context, category, item);
                  },
                ),
              ),

              // Sticky Bottom Checkout / Review Bar
              _buildBottomActionBar(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveDashboard(BuildContext context, List<String> warnings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total Estimated Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ESTIMATED TOTAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${customBuildState.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Estimated Wattage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.accentAmber, size: 20),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Est. Wattage', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        Text(
                          '${customBuildState.totalEstimatedWattage} W',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress & Compatibility Indicator
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: customBuildState.progress,
                    backgroundColor: AppColors.inputBg,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  if (warnings.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Compatibility Notes'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: warnings
                              .map((w) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(w, style: const TextStyle(fontSize: 13))),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                        ],
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      warnings.isEmpty ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                      size: 14,
                      color: warnings.isEmpty ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      warnings.isEmpty ? '100% Compatible' : '${warnings.length} Warning',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: warnings.isEmpty ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(BuildContext context, ComponentCategory category, PcComponent? item) {
    if (item == null) {
      // Empty Slot
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(category.icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Not selected yet',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _openPicker(context, category),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Select'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySurface,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    // Filled Slot
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppNetworkImage(
                imageUrl: item.imageUrl,
                width: 52,
                height: 52,
                borderRadius: BorderRadius.circular(10),
                fallbackIcon: category.icon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category.shortName,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${item.brand}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (item.wattage > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${item.wattage}W',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Slot Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18),
                    tooltip: 'Change Part',
                    onPressed: () => _openPicker(context, category),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 18),
                    tooltip: 'Remove',
                    onPressed: () => customBuildState.removeComponent(category),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openPicker(BuildContext context, ComponentCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ComponentPickerSheet(
        category: category,
        customBuildState: customBuildState,
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final hasParts = customBuildState.selectedCount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: hasParts
                    ? () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => BuildSummaryDialog(
                            customBuildState: customBuildState,
                            onNavigateToTab: onNavigateToTab,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.receipt_long_rounded, size: 20),
                label: Text(
                  hasParts ? 'Review & Order Rig (${customBuildState.selectedCount}/8)' : 'Select Components to Order',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
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
    );
  }
}
