import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${customBuildState.selectedCount} of ${customBuildState.totalRequiredCount} parts configured',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22.r),
                tooltip: 'Reset Build',
                onPressed: () {
                  if (customBuildState.selectedCount > 0) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        title: Text('Reset Build?', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        content: Text('This will clear all selected components in your custom build.', style: TextStyle(fontSize: 13.sp)),
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
                icon: Icon(Icons.bookmark_add_outlined, color: AppColors.primary, size: 22.r),
                tooltip: 'Save PC',
                onPressed: () async {
                  if (customBuildState.selectedCount == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one component to save a PC build.'),
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
              SizedBox(width: 6.w),
            ],
          ),
          body: Column(
            children: [
              // Sticky Live Dashboard Header with Budget Tracker
              _buildLiveDashboard(context, warnings),

              // Over-Budget Alert Banner (if budget exceeded)
              if (customBuildState.isOverBudget) _buildOverBudgetBanner(context),

              // Slots List
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  itemCount: requiredSlots.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
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
    final hasBudget = customBuildState.hasBudget;
    final isOverBudget = customBuildState.isOverBudget;
    final budgetUsagePercent = customBuildState.budgetUsagePercent;

    Color progressColor;
    if (!hasBudget) {
      progressColor = AppColors.primary;
    } else if (isOverBudget) {
      progressColor = AppColors.error;
    } else if (budgetUsagePercent > 80) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.success;
    }

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top metric row: Estimated Total, Target Budget pill, Est. Wattage
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Estimated Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTIMATED TOTAL',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '৳${customBuildState.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: isOverBudget ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 6.w),

              // Target Budget Button / Pill
              InkWell(
                onTap: () => _showSetBudgetDialog(context),
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: hasBudget
                        ? (isOverBudget
                            ? AppColors.error.withValues(alpha: 0.08)
                            : AppColors.primarySurface)
                        : AppColors.inputBg,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: hasBudget
                          ? (isOverBudget ? AppColors.error.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.3))
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasBudget ? Icons.account_balance_wallet_rounded : Icons.add_card_rounded,
                        color: hasBudget
                            ? (isOverBudget ? AppColors.error : AppColors.primary)
                            : AppColors.textSecondary,
                        size: 15.r,
                      ),
                      SizedBox(width: 5.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasBudget ? 'Target Budget' : 'Set Budget',
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: hasBudget
                                  ? (isOverBudget ? AppColors.error : AppColors.primary)
                                  : AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            hasBudget ? '৳${customBuildState.targetBudget!.toStringAsFixed(0)}' : 'No Limit',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: hasBudget
                                  ? (isOverBudget ? AppColors.error : AppColors.textPrimary)
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.edit_outlined,
                        size: 12.r,
                        color: hasBudget
                            ? (isOverBudget ? AppColors.error : AppColors.primary)
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 6.w),

              // Estimated Wattage
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, color: AppColors.accentAmber, size: 16.r),
                    SizedBox(width: 4.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Est. Wattage', style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary)),
                        Text(
                          '${customBuildState.totalEstimatedWattage} W',
                          style: TextStyle(
                            fontSize: 11.sp,
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

          SizedBox(height: 10.h),

          // Budget or Build Progress bar
          if (hasBudget) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isOverBudget
                        ? '⚠️ Over Budget by ৳${customBuildState.budgetOverAmount.toStringAsFixed(0)}'
                        : '৳${customBuildState.budgetRemaining.toStringAsFixed(0)} remaining (${budgetUsagePercent.toStringAsFixed(0)}% used)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: isOverBudget
                          ? AppColors.error
                          : (budgetUsagePercent > 80 ? AppColors.warning : AppColors.textSecondary),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${customBuildState.selectedCount}/${customBuildState.totalRequiredCount} Parts',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: (customBuildState.budgetUsageRatio).clamp(0.0, 1.0),
                backgroundColor: AppColors.inputBg,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6.h,
              ),
            ),
          ] else ...[
            // Parts Completion Progress Indicator
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: customBuildState.progress,
                      backgroundColor: AppColors.inputBg,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6.h,
                    ),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 8.h),

          // Compatibility Indicator Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${customBuildState.selectedCount} of ${customBuildState.totalRequiredCount} parts selected',
                style: TextStyle(fontSize: 11.sp, color: AppColors.textLight),
              ),
              GestureDetector(
                onTap: () {
                  if (warnings.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        title: Text('Compatibility & Budget Notes', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: warnings
                              .map((w) => Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4.h),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          w.contains('Budget') ? Icons.monetization_on_outlined : Icons.warning_amber_rounded,
                                          color: w.contains('Budget') ? AppColors.error : AppColors.warning,
                                          size: 17.r,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            w,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: w.contains('Budget') ? AppColors.error : AppColors.textPrimary,
                                              fontWeight: w.contains('Budget') ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ),
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
                      size: 13.r,
                      color: warnings.isEmpty ? AppColors.success : (isOverBudget ? AppColors.error : AppColors.warning),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      warnings.isEmpty
                          ? '100% Compatible'
                          : '${warnings.length} ${warnings.length == 1 ? 'Notice' : 'Notices'}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: warnings.isEmpty ? AppColors.success : (isOverBudget ? AppColors.error : AppColors.warning),
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

  Widget _buildOverBudgetBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      padding: EdgeInsets.all(11.r),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18.r),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget Limit Exceeded by ৳${customBuildState.budgetOverAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Your build total (৳${customBuildState.totalPrice.toStringAsFixed(0)}) exceeds your ৳${customBuildState.targetBudget!.toStringAsFixed(0)} budget. Consider selecting budget-friendly options.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showSetBudgetDialog(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Adjust',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(BuildContext context, ComponentCategory category, PcComponent? item) {
    if (item == null) {
      // Empty Slot
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(category.icon, color: AppColors.primary, size: 20.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Not selected yet',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _openPicker(context, category),
              icon: Icon(Icons.add_rounded, size: 15.r),
              label: const Text('Select'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySurface,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                textStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    // Filled Slot
    final hasBudget = customBuildState.hasBudget;
    final itemCostPercent = hasBudget && customBuildState.targetBudget! > 0
        ? ((item.price / customBuildState.targetBudget!) * 100).round()
        : null;

    return Container(
      padding: EdgeInsets.all(11.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 6.r,
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
                width: 48.r,
                height: 48.r,
                borderRadius: BorderRadius.circular(10.r),
                fallbackIcon: category.icon,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${category.shortName} • ${item.brand}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (itemCostPercent != null) ...[
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '$itemCostPercent% budget',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          '৳${item.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (item.wattage > 0) ...[
                          SizedBox(width: 6.w),
                          Text(
                            '• ${item.wattage}W',
                            style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              // Slot Actions (Compact)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _openPicker(context, category),
                    borderRadius: BorderRadius.circular(6.r),
                    child: Padding(
                      padding: EdgeInsets.all(6.r),
                      child: Icon(Icons.edit_outlined, color: AppColors.primary, size: 17.r),
                    ),
                  ),
                  InkWell(
                    onTap: () => customBuildState.removeComponent(category),
                    borderRadius: BorderRadius.circular(6.r),
                    child: Padding(
                      padding: EdgeInsets.all(6.r),
                      child: Icon(Icons.close_rounded, color: AppColors.error, size: 17.r),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context) {
    final textController = TextEditingController(
      text: customBuildState.hasBudget ? customBuildState.targetBudget!.toStringAsFixed(0) : '',
    );

    final presets = [
      {'label': '৳35,000', 'value': 35000.0, 'sub': 'Student / Office'},
      {'label': '৳55,000', 'value': 55000.0, 'sub': 'Budget Gaming'},
      {'label': '৳85,000', 'value': 85000.0, 'sub': '1080p Ultra'},
      {'label': '৳130,000', 'value': 130000.0, 'sub': 'High-End 1440p'},
      {'label': '৳200,000', 'value': 200000.0, 'sub': 'Enthusiast / 4K'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 20.h,
                top: 16.h,
                left: 20.w,
                right: 20.w,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20.r),
                            SizedBox(width: 8.w),
                            Text(
                              'Set Target Budget',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20.r),
                          onPressed: () => Navigator.pop(dialogCtx),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Define your spending target to track expenses and receive alerts if you exceed your limit.',
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 14.h),

                    // Quick Presets
                    Text(
                      'POPULAR PRESETS',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: presets.map((p) {
                        final val = p['value'] as double;
                        final isSelected = customBuildState.targetBudget == val;

                        return InkWell(
                          onTap: () {
                            setSheetState(() {
                              textController.text = val.toStringAsFixed(0);
                            });
                          },
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primarySurface : AppColors.inputBg,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['label'] as String,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  p['sub'] as String,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 18.h),

                    // Custom Amount Input
                    Text(
                      'CUSTOM BUDGET AMOUNT (৳ BDT)',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: textController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Text(
                            '৳',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        hintText: 'e.g. 75000',
                        suffixIcon: textController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, size: 18.r),
                                onPressed: () {
                                  setSheetState(() {
                                    textController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    SizedBox(height: 20.h),

                    // Action Buttons
                    Row(
                      children: [
                        if (customBuildState.hasBudget) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                customBuildState.clearTargetBudget();
                                Navigator.pop(dialogCtx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Target budget removed.'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(Icons.remove_circle_outline, size: 16.r),
                              label: const Text('Clear Limit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final amount = double.tryParse(textController.text.replaceAll(',', '').trim());
                              if (amount == null || amount <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a valid budget amount.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }

                              customBuildState.setTargetBudget(amount);
                              Navigator.pop(dialogCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Target budget set to ৳${amount.toStringAsFixed(0)}!'),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icon(Icons.check_rounded, size: 18.r),
                            label: const Text('Save Target Budget'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                icon: Icon(Icons.receipt_long_rounded, size: 18.r),
                label: Text(
                  hasParts ? 'Review & Order PC (${customBuildState.selectedCount}/8)' : 'Select Components to Order',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
