import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_data.dart';
import '../../core/widgets/app_network_image.dart';
import '../../models/custom_build_state.dart';
import '../../models/pc_build_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class SavedBuildsSheet extends StatelessWidget {
  final CustomBuildState customBuildState;
  final Function(int)? onNavigateToTab;

  const SavedBuildsSheet({
    super.key,
    required this.customBuildState,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final userId = user?.uid ?? 'guest_user';

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                  'My Saved Custom PCs',
                  style: TextStyle(
                    fontSize: 17.sp,
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

          // Builds List
          Expanded(
            child: StreamBuilder<List<PcBuildModel>>(
              stream: FirestoreService().streamSavedBuilds(userId),
              initialData: AppData.savedBuilds,
              builder: (context, snapshot) {
                final rawBuilds = snapshot.data;
                final builds = (rawBuilds != null && rawBuilds.isNotEmpty)
                    ? rawBuilds
                    : AppData.savedBuilds;

                if (builds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border_rounded, size: 44.sp, color: AppColors.textLight),
                        SizedBox(height: 12.h),
                        Text(
                          'No saved PCs found',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 14.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Use the "Save PC" button in Builder to save configurations here.',
                          style: TextStyle(fontSize: 11.sp, color: AppColors.textLight),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.r),
                  itemCount: builds.length,
                  separatorBuilder: (context, index) => SizedBox(height: 14.h),
                  itemBuilder: (context, idx) {
                    final build = builds[idx];
                    return _buildSavedCard(context, build, userId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCard(BuildContext context, PcBuildModel build, String userId) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppNetworkImage(
                imageUrl: build.imageUrl,
                width: 60.w,
                height: 60.w,
                borderRadius: BorderRadius.circular(10.r),
                fallbackIcon: Icons.computer_rounded,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      build.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${build.gpu.split(' ').take(3).join(' ')} • ${build.cpu.split(' ').take(3).join(' ')}',
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '৳${build.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: AppColors.textLight, size: 20.sp),
                tooltip: 'Delete Saved PC',
                onPressed: () async {
                  await FirestoreService().deleteSavedBuild(userId, build.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved PC removed.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                customBuildState.loadComponents(
                  build.defaultComponents,
                  buildName: build.title,
                );
                Navigator.pop(context);
                if (onNavigateToTab != null) {
                  onNavigateToTab!(1); // Go to Builder tab
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Loaded "${build.title}" into PC Builder!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              icon: Icon(Icons.build_circle_outlined, size: 18.sp),
              label: Text('Load into PC Builder', style: TextStyle(fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySurface,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
