import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_data.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/live_badge.dart';
import '../../models/custom_build_state.dart';
import '../../models/pc_component_model.dart';
import '../../services/firestore_service.dart';

class ComponentPickerSheet extends StatefulWidget {
  final ComponentCategory category;
  final CustomBuildState customBuildState;

  const ComponentPickerSheet({
    super.key,
    required this.category,
    required this.customBuildState,
  });

  @override
  State<ComponentPickerSheet> createState() => _ComponentPickerSheetState();
}

class _ComponentPickerSheetState extends State<ComponentPickerSheet> {
  String _searchQuery = '';
  String _selectedBrand = 'All';
  bool _filterWithinBudgetOnly = false;
  String _sortBy = 'default'; // 'default', 'price_asc', 'price_desc'
  late final Stream<List<PcComponent>> _componentsStream;

  @override
  void initState() {
    super.initState();
    _componentsStream = FirestoreService().streamComponents(category: widget.category);
  }

  void _handleComponentSelection(PcComponent item) {
    final state = widget.customBuildState;

    // Check if selecting this item exceeds the target budget
    if (state.hasBudget && state.wouldExceedBudget(item)) {
      final simulatedTotal = state.calculateSimulatedTotal(item);
      final overAmount = simulatedTotal - state.targetBudget!;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22.r),
              SizedBox(width: 8.w),
              Text(
                'Budget Exceeded Alert',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecting ${item.name} (৳${item.price.toStringAsFixed(0)}) will increase your total to ৳${simulatedTotal.toStringAsFixed(0)}.',
                style: TextStyle(fontSize: 12.sp, height: 1.4),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.error, size: 16.r),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Exceeds target budget (৳${state.targetBudget!.toStringAsFixed(0)}) by ৳${overAmount.toStringAsFixed(0)}.',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Would you like to select this item anyway or look for a budget-friendly alternative?',
                style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _filterWithinBudgetOnly = true;
                });
              },
              child: const Text('Find Within Budget'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                state.selectComponent(item);
                Navigator.pop(context); // Close picker sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected ${item.name} (Over Budget)'),
                    backgroundColor: AppColors.warning,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Select Anyway'),
            ),
          ],
        ),
      );
      return;
    }

    // Normal selection within budget or when no budget set
    state.selectComponent(item);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${item.name}'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.customBuildState;
    final hasBudget = state.hasBudget;
    final defaultComps = AppData.allComponents.where((c) => c.category == widget.category).toList();

    return StreamBuilder<List<PcComponent>>(
      stream: _componentsStream,
      initialData: defaultComps,
      builder: (context, snapshot) {
        final rawComps = snapshot.data;
        final categoryComponents = (rawComps != null && rawComps.isNotEmpty)
            ? rawComps
            : defaultComps;

        // Unique brands
        final brands = ['All', ...categoryComponents.map((c) => c.brand).toSet()];

        // Filter by search, brand, and budget
        var filtered = categoryComponents.where((c) {
          final matchesSearch = c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.brand.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesBrand = _selectedBrand == 'All' || c.brand == _selectedBrand;
          final matchesBudget = !_filterWithinBudgetOnly || !state.wouldExceedBudget(c);
          return matchesSearch && matchesBrand && matchesBudget;
        }).toList();

        // Sort items
        if (_sortBy == 'price_asc') {
          filtered.sort((a, b) => a.price.compareTo(b.price));
        } else if (_sortBy == 'price_desc') {
          filtered.sort((a, b) => b.price.compareTo(a.price));
        }

        final currentlySelected = state.selectedComponents[widget.category];

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
                    Row(
                      children: [
                        Icon(widget.category.icon, color: AppColors.primary, size: 22.r),
                        SizedBox(width: 10.w),
                        Text(
                          'Choose ${widget.category.displayName}',
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search & Sort Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(fontSize: 13.sp),
                        decoration: InputDecoration(
                          hintText: 'Search ${widget.category.shortName}...',
                          prefixIcon: Icon(Icons.search_rounded, size: 18.r),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          _sortBy == 'default' ? Icons.sort_rounded : Icons.filter_list_rounded,
                          color: _sortBy != 'default' ? AppColors.primary : AppColors.textSecondary,
                          size: 18.r,
                        ),
                      ),
                      tooltip: 'Sort components',
                      onSelected: (val) => setState(() => _sortBy = val),
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'default',
                          child: Text('Default Order'),
                        ),
                        const PopupMenuItem(
                          value: 'price_asc',
                          child: Text('Price: Low to High'),
                        ),
                        const PopupMenuItem(
                          value: 'price_desc',
                          child: Text('Price: High to Low'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter Chips: Budget Filter + Brand Pills
              SizedBox(
                height: 38.h,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (hasBudget) ...[
                      FilterChip(
                        avatar: Icon(
                          _filterWithinBudgetOnly ? Icons.check_circle : Icons.account_balance_wallet_outlined,
                          size: 15.r,
                          color: _filterWithinBudgetOnly ? Colors.white : AppColors.success,
                        ),
                        label: const Text('Within Budget Only'),
                        selected: _filterWithinBudgetOnly,
                        onSelected: (selected) {
                          setState(() => _filterWithinBudgetOnly = selected);
                        },
                        selectedColor: AppColors.success,
                        labelStyle: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: _filterWithinBudgetOnly ? Colors.white : AppColors.textPrimary,
                        ),
                        backgroundColor: AppColors.success.withValues(alpha: 0.08),
                        side: BorderSide(
                          color: _filterWithinBudgetOnly ? AppColors.success : AppColors.success.withValues(alpha: 0.4),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],

                    ...brands.map((b) {
                      final isSelected = b == _selectedBrand;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ChoiceChip(
                          label: Text(b),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedBrand = b),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 8.h),

              // Component List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 44.r, color: AppColors.textLight),
                            SizedBox(height: 8.h),
                            Text(
                              'No matching components found.',
                              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13.sp),
                            ),
                            if (_filterWithinBudgetOnly) ...[
                              SizedBox(height: 4.h),
                              TextButton(
                                onPressed: () => setState(() => _filterWithinBudgetOnly = false),
                                child: const Text('Clear "Within Budget" filter'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isCurrent = currentlySelected?.id == item.id;
                          final wouldExceed = hasBudget && state.wouldExceedBudget(item);
                          final diff = hasBudget ? state.simulatedBudgetDiff(item) : 0.0;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isCurrent
                                    ? AppColors.primary
                                    : (wouldExceed ? AppColors.error.withValues(alpha: 0.3) : AppColors.border),
                                width: isCurrent ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6.r,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppNetworkImage(
                                        imageUrl: item.imageUrl,
                                        width: 65.r,
                                        height: 65.r,
                                        borderRadius: BorderRadius.circular(10.r),
                                        fallbackIcon: widget.category.icon,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 6.w,
                                              runSpacing: 4.h,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Text(
                                                  item.brand,
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                if (item.badge != null)
                                                  LiveBadge(
                                                    text: item.badge!,
                                                    backgroundColor: AppColors.primarySurface,
                                                    textColor: AppColors.primaryDark,
                                                  ),
                                                if (hasBudget)
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                                                    decoration: BoxDecoration(
                                                      color: wouldExceed
                                                          ? AppColors.error.withValues(alpha: 0.1)
                                                          : AppColors.success.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(4.r),
                                                    ),
                                                    child: Text(
                                                      wouldExceed
                                                          ? '+৳${(-diff).toStringAsFixed(0)} Over'
                                                          : '✓ ৳${diff.toStringAsFixed(0)} Left',
                                                      style: TextStyle(
                                                        fontSize: 9.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: wouldExceed ? AppColors.error : AppColors.success,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              item.name,
                                              style: TextStyle(
                                                fontSize: 13.sp,
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
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                if (item.wattage > 0) ...[
                                                  SizedBox(width: 8.w),
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
                                    ],
                                  ),
                                  SizedBox(height: 8.h),

                                  // Specs preview chips
                                  if (item.specs.isNotEmpty)
                                    Wrap(
                                      spacing: 6.w,
                                      runSpacing: 4.h,
                                      children: item.specs.entries.take(3).map((e) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: AppColors.inputBg,
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            '${e.key}: ${e.value}',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  SizedBox(height: 10.h),

                                  // Select / Selected Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: isCurrent
                                        ? OutlinedButton.icon(
                                            onPressed: () => Navigator.pop(context),
                                            icon: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16.r),
                                            label: Text('Currently Selected', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: AppColors.success),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                              padding: EdgeInsets.symmetric(vertical: 8.h),
                                            ),
                                          )
                                        : ElevatedButton(
                                            onPressed: () => _handleComponentSelection(item),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: wouldExceed ? AppColors.warning : AppColors.primary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                              padding: EdgeInsets.symmetric(vertical: 9.h),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                if (wouldExceed) ...[
                                                  Icon(Icons.warning_amber_rounded, size: 15.r),
                                                  SizedBox(width: 5.w),
                                                ],
                                                Text(
                                                  wouldExceed ? 'Select (Exceeds Budget)' : 'Select Component',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
