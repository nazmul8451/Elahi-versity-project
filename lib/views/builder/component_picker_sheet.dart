import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PcComponent>>(
      stream: FirestoreService().streamComponents(category: widget.category),
      builder: (context, snapshot) {
        final categoryComponents = snapshot.data ??
            AppData.allComponents
                .where((c) => c.category == widget.category)
                .toList();

        // Get unique brands
        final brands = ['All', ...categoryComponents.map((c) => c.brand).toSet()];

        // Filter by search and brand
        final filtered = categoryComponents.where((c) {
          final matchesSearch = c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.brand.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesBrand = _selectedBrand == 'All' || c.brand == _selectedBrand;
          return matchesSearch && matchesBrand;
        }).toList();

        final currentlySelected = widget.customBuildState.selectedComponents[widget.category];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                Row(
                  children: [
                    Icon(widget.category.icon, color: AppColors.primary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Choose ${widget.category.displayName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search ${widget.category.shortName}...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Brand Filter Pills
          if (brands.length > 2)
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: brands.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final b = brands[idx];
                  final isSelected = b == _selectedBrand;
                  return ChoiceChip(
                    label: Text(b),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedBrand = b),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),

          // Component List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No matching components found.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isCurrent = currentlySelected?.id == item.id;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrent ? AppColors.primary : AppColors.border,
                            width: isCurrent ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppNetworkImage(
                                    imageUrl: item.imageUrl,
                                    width: 70,
                                    height: 70,
                                    borderRadius: BorderRadius.circular(10),
                                    fallbackIcon: widget.category.icon,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              item.brand,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            if (item.badge != null) ...[
                                              const SizedBox(width: 6),
                                              LiveBadge(
                                                text: item.badge!,
                                                backgroundColor: AppColors.primarySurface,
                                                textColor: AppColors.primaryDark,
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '\$${item.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Specs preview chips
                              if (item.specs.isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: item.specs.entries.take(3).map((e) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.inputBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${e.key}: ${e.value}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 12),

                              // Select / Selected Button
                              SizedBox(
                                width: double.infinity,
                                child: isCurrent
                                    ? OutlinedButton.icon(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                                        label: const Text('Currently Selected', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.success),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          widget.customBuildState.selectComponent(item);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Selected ${item.name}'),
                                              backgroundColor: AppColors.primary,
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        child: const Text('Select Component', style: TextStyle(fontWeight: FontWeight.bold)),
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
