import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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
        title: const Text(
          'My Profile & Rig Hub',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App Settings opened')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Profile Header Card
            _buildUserHeader(),
            const SizedBox(height: 16),

            // Quick Stats Row
            _buildStatsRow(context),
            const SizedBox(height: 20),

            // Saved Custom Builds Section Card
            _buildSavedBuildsSection(context),
            const SizedBox(height: 20),

            // Account & Services Menu Options
            _buildAccountMenu(context),
            const SizedBox(height: 24),

            // Sign Out Button
            _buildSignOutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
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
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    LiveBadge(
                      text: 'PRO BUILDER',
                      backgroundColor: AppColors.primarySurface,
                      textColor: AppColors.primaryDark,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
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
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return _statCard(
                'Saved Rigs',
                '$count',
                Icons.memory_rounded,
                AppColors.primary,
                onTap: () => _openSavedBuilds(context),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: FirestoreService().streamUserOrders(user.uid),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
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
        const SizedBox(width: 10),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Saved Builds',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _openSavedBuilds(context),
                child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<PcBuildModel>>(
            stream: FirestoreService().streamSavedBuilds(user.uid),
            builder: (context, snapshot) {
              final builds = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              if (builds.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.bookmark_border_rounded, size: 28, color: AppColors.textLight),
                        const SizedBox(height: 6),
                        const Text(
                          'No custom rigs saved yet',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Use "Save Rig" in Builder to save configurations',
                          style: TextStyle(fontSize: 11, color: AppColors.textLight),
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
                        width: 50,
                        height: 50,
                        borderRadius: BorderRadius.circular(10),
                        fallbackIcon: Icons.computer_rounded,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              build.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '৳${build.price.toStringAsFixed(0)} • ${build.gpu.split(' ').take(2).join(' ')}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.build_circle_rounded, color: AppColors.primary),
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
      {'icon': Icons.verified_outlined, 'title': 'Rig Warranty & Guarantees', 'subtitle': '3-Year component coverage'},
      {'icon': Icons.support_agent_outlined, 'title': '24/7 Tech Support', 'subtitle': 'Chat with rig specialists'},
      {'icon': Icons.notifications_none_rounded, 'title': 'Push Notifications', 'subtitle': 'Order & deal alerts'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: menuItems.map((item) {
          final isLast = menuItems.indexOf(item) == menuItems.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 20),
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  item['subtitle'] as String,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
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
        icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
        label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
