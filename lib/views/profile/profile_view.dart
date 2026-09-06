import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_data.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/live_badge.dart';
import '../../models/custom_build_state.dart';
import '../../models/order_model.dart';
import '../../models/pc_build_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../auth/login_view.dart';
import 'saved_builds_sheet.dart';

class ProfileView extends StatelessWidget {
  final UserModel user;
  final CustomBuildState customBuildState;
  final Function(int)? onNavigateToTab;

  const ProfileView({
    super.key,
    required this.user,
    required this.customBuildState,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Profile & PC Hub',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: 22.sp),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App Settings opened')),
              );
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // User Profile Header Card
            _buildUserHeader(),
            SizedBox(height: 16.h),

            // Quick Stats Row
            _buildStatsRow(context),
            SizedBox(height: 20.h),

            // Saved Custom Builds Section Card
            _buildSavedBuildsSection(context),
            SizedBox(height: 20.h),

            // Account & Services Menu Options
            _buildAccountMenu(context),
            SizedBox(height: 24.h),

            // Sign Out Button
            _buildSignOutButton(context),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 32.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    LiveBadge(
                      text: 'PRO BUILDER',
                      backgroundColor: AppColors.primarySurface,
                      textColor: AppColors.primaryDark,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<PcBuildModel>>(
            stream: FirestoreService().streamSavedBuilds(user.uid),
            initialData: AppData.savedBuilds,
            builder: (context, snapshot) {
              final raw = snapshot.data;
              final count = (raw != null && raw.isNotEmpty) ? raw.length : AppData.savedBuilds.length;
              return _statCard(
                'Saved PCs',
                '$count',
                Icons.memory_rounded,
                AppColors.primary,
                onTap: () => _openSavedBuilds(context),
              );
            },
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: FirestoreService().streamUserOrders(user.uid),
            initialData: AppData.mockOrders,
            builder: (context, snapshot) {
              final raw = snapshot.data;
              final count = (raw != null && raw.isNotEmpty) ? raw.length : AppData.mockOrders.length;
              return _statCard(
                'Orders',
                '$count',
                Icons.local_shipping_outlined,
                AppColors.accentPurple,
                onTap: () {
                  if (onNavigateToTab != null) onNavigateToTab!(2);
                },
              );
            },
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _statCard(
            'Rewards',
            '450 pts',
            Icons.military_tech_rounded,
            AppColors.accentAmber,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedBuildsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Saved Builds',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _openSavedBuilds(context),
                child: Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.sp)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          StreamBuilder<List<PcBuildModel>>(
            stream: FirestoreService().streamSavedBuilds(user.uid),
            initialData: AppData.savedBuilds,
            builder: (context, snapshot) {
              final rawBuilds = snapshot.data;
              final builds = (rawBuilds != null && rawBuilds.isNotEmpty)
                  ? rawBuilds
                  : AppData.savedBuilds;

              if (builds.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.bookmark_border_rounded, size: 28.sp, color: AppColors.textLight),
                        SizedBox(height: 6.h),
                        Text(
                          'No custom PCs saved yet',
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Use "Save PC" in Builder to save configurations',
                          style: TextStyle(fontSize: 10.sp, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final displayList = builds.take(2).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                separatorBuilder: (context, index) => const Divider(height: 16, color: AppColors.border),
                itemBuilder: (context, idx) {
                  final build = displayList[idx];
                  return Row(
                    children: [
                      AppNetworkImage(
                        imageUrl: build.imageUrl,
                        width: 48.w,
                        height: 48.w,
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
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '৳${build.price.toStringAsFixed(0)} • ${build.gpu.split(' ').take(2).join(' ')}',
                              style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.build_circle_rounded, color: AppColors.primary, size: 22.sp),
                        tooltip: 'Load to Builder',
                        onPressed: () {
                          customBuildState.loadComponents(
                            build.defaultComponents,
                            buildName: build.title,
                          );
                          if (onNavigateToTab != null) {
                            onNavigateToTab!(1);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Loaded "${build.title}" into Builder!')),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _openSavedBuilds(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SavedBuildsSheet(
        customBuildState: customBuildState,
        onNavigateToTab: onNavigateToTab,
      ),
    );
  }

  Widget _buildAccountMenu(BuildContext context) {
    final menuItems = [
      {'icon': Icons.location_on_outlined, 'title': 'Shipping Addresses', 'subtitle': '2 Saved locations'},
      {'icon': Icons.credit_card_outlined, 'title': 'Payment Methods', 'subtitle': 'Visa, Mastercard & COD'},
      {'icon': Icons.verified_outlined, 'title': 'PC Warranty & Guarantees', 'subtitle': '3-Year component coverage'},
      {'icon': Icons.support_agent_outlined, 'title': '24/7 Tech Support', 'subtitle': 'Chat with PC specialists'},
      {'icon': Icons.notifications_none_rounded, 'title': 'Push Notifications', 'subtitle': 'Order & deal alerts'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: menuItems.map((item) {
          final isLast = menuItems.indexOf(item) == menuItems.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 18.sp),
                ),
                title: Text(
                  item['title'] as String,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  item['subtitle'] as String,
                  style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 12.sp, color: AppColors.textLight),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item['title']} coming soon!')),
                  );
                },
              ),
              if (!isLast) const Divider(height: 1, color: AppColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sign Out?'),
              content: const Text('Are you sure you want to sign out from PC Builder?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await AuthService().signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginView()),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
        },
        icon: Icon(Icons.logout_rounded, color: AppColors.error, size: 18.sp),
        label: Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13.sp)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }
}
