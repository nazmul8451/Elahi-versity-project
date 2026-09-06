import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/live_badge.dart';
import '../../models/custom_build_state.dart';
import '../../models/pc_build_model.dart';
import '../../models/pc_component_model.dart';
import '../builder/build_summary_dialog.dart';

class PcDetailsView extends StatelessWidget {
  final PcBuildModel pc;
  final CustomBuildState customBuildState;
  final Function(int)? onNavigateToTab;

  const PcDetailsView({
    super.key,
    required this.pc,
    required this.customBuildState,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Image Sliver AppBar
          SliverAppBar(
            expandedHeight: 270.h,
            pinned: true,
            backgroundColor: AppColors.darkCard,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16.sp),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18.sp),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to Wishlist!')),
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.share_rounded, color: Colors.white, size: 18.sp),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sharing ${pc.title}...')),
                  );
                },
              ),
              SizedBox(width: 8.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: pc.imageUrl,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.computer_rounded,
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Info inside Hero
                  Positioned(
                    bottom: 16.h,
                    left: 20.w,
                    right: 20.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (pc.badge.isNotEmpty) ...[
                              LiveBadge(
                                text: pc.badge,
                                backgroundColor: AppColors.accentAmber,
                                textColor: Colors.black,
                              ),
                              SizedBox(width: 8.w),
                            ],
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                pc.tier,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          pc.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price & Rating Card
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '৳${pc.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (pc.originalPrice != null) ...[
                                  SizedBox(width: 8.w),
                                  Text(
                                    '৳${pc.originalPrice!.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textLight,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  'In Stock • Ready to Ship',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Rating box
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${pc.rating}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${pc.reviews} reviews',
                                style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Overview / Description
                  Text(
                    'Build Overview',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    pc.description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Highlight Tags
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: pc.tags.map((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24.h),

                  // Full Hardware Specs Breakdown
                  Text(
                    'Hardware Specifications',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _specRow(ComponentCategory.cpu.icon, 'Processor (CPU)', pc.cpu),
                        _divider(),
                        _specRow(ComponentCategory.gpu.icon, 'Graphics Card', pc.gpu),
                        _divider(),
                        _specRow(ComponentCategory.ram.icon, 'Memory (RAM)', pc.ram),
                        _divider(),
                        _specRow(ComponentCategory.storage.icon, 'Storage (SSD)', pc.storage),
                        _divider(),
                        _specRow(ComponentCategory.motherboard.icon, 'Motherboard', pc.motherboard),
                        _divider(),
                        _specRow(ComponentCategory.cooler.icon, 'Cooling', pc.cooler),
                        _divider(),
                        _specRow(ComponentCategory.psu.icon, 'Power Supply', pc.psu),
                        _divider(),
                        _specRow(ComponentCategory.casing.icon, 'Chassis', pc.casing),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Customization Callout Card
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.tune_rounded, color: Colors.white, size: 22.sp),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Want to tweak this build?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Open it in PC Builder to swap CPU, GPU, or RAM.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 90.h), // Spacing for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Fixed Actions
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
              // Customize in Builder Button
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Load into custom builder state
                    customBuildState.loadComponents(
                      pc.defaultComponents,
                      buildName: pc.title,
                    );
                    Navigator.pop(context);
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(1); // Switch to Builder tab (index 1)
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Loaded "${pc.title}" into PC Builder!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  icon: Icon(Icons.build_circle_outlined, size: 16.sp, color: AppColors.primary),
                  label: Text('Customize', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Buy / Order PC Button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Load into custom builder state
                    customBuildState.loadComponents(
                      pc.defaultComponents,
                      buildName: pc.title,
                    );
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (dialogCtx) => BuildSummaryDialog(
                        customBuildState: customBuildState,
                        onNavigateToTab: (tab) {
                          Navigator.pop(context); // Close details view
                          if (onNavigateToTab != null) {
                            onNavigateToTab!(tab);
                          }
                        },
                      ),
                    );
                  },
                  icon: Icon(Icons.shopping_cart_checkout_rounded, size: 16.sp),
                  label: Text('Buy Now • ৳${pc.price.toInt()}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  Widget _specRow(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          SizedBox(
            width: 105.w,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: AppColors.border);
  }
}
