import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_data.dart';
import '../../core/widgets/app_network_image.dart';
import '../../models/custom_build_state.dart';
import '../../models/pc_build_model.dart';

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
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                  'My Saved Custom Rigs',
                  style: TextStyle(
                    fontSize: 18,
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

          // Builds List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: AppData.savedBuilds.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, idx) {
                final build = AppData.savedBuilds[idx];
                return _buildSavedCard(context, build);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCard(BuildContext context, PcBuildModel build) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppNetworkImage(
                imageUrl: build.imageUrl,
                width: 64,
                height: 64,
                borderRadius: BorderRadius.circular(10),
                fallbackIcon: Icons.computer_rounded,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      build.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${build.gpu.split(' ').take(3).join(' ')} • ${build.cpu.split(' ').take(3).join(' ')}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${build.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
              icon: const Icon(Icons.build_circle_outlined, size: 18),
              label: const Text('Load into PC Builder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySurface,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
