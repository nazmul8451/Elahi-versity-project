import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_data.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/live_badge.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/spec_chip.dart';
import '../../models/custom_build_state.dart';
import '../../models/pc_build_model.dart';
import '../../models/pc_component_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import 'pc_details_view.dart';

class HomeView extends StatefulWidget {
  final UserModel user;
  final CustomBuildState customBuildState;
  final Function(int) onNavigateToTab;

  const HomeView({
    super.key,
    required this.user,
    required this.customBuildState,
    required this.onNavigateToTab,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final PageController _heroPageController = PageController();
  final ValueNotifier<int> _activeHeroIndexNotifier = ValueNotifier<int>(0);

  late final Stream<List<Map<String, dynamic>>> _bannersStream;
  late final Stream<List<PcBuildModel>> _prebuiltsStream;
  late final Stream<List<PcComponent>> _componentsStream;

  final List<String> _categories = [
    'All',
    'Gaming PCs',
    'Workstations',
    'Processors',
    'Graphics Cards',
    'Motherboards',
    'Memory',
    'Storage',
  ];

  @override
  void initState() {
    super.initState();
    final firestore = FirestoreService();
    _bannersStream = firestore.streamBanners();
    _prebuiltsStream = firestore.streamPrebuiltPcs();
    _componentsStream = firestore.streamComponents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _heroPageController.dispose();
    _activeHeroIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filter bar
            _buildSearchBar(),

            if (isSearching)
              _buildLiveSearchResults(_searchController.text.trim())
            else ...[
              // Hero Carousel Banner with dot indicators
              _buildHeroCarousel(),
              SizedBox(height: 16.h),

              // Start Custom Build CTA Card
              _buildCustomBuilderCTA(),
              SizedBox(height: 20.h),

              // Category Filter Pills
              _buildCategorySelector(),
              SizedBox(height: 16.h),

              // Featured Prebuilt Systems
              _buildFeaturedPrebuiltsSection(),
              SizedBox(height: 24.h),

              // Trending Hardware Components
              _buildTrendingComponentsSection(),
              SizedBox(height: 24.h),

              // Why Build With Us (Trust Badges)
              _buildTrustSection(),
              SizedBox(height: 40.h),
            ],
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryAccent],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.memory_rounded, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Welcome, ${widget.user.name}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22.sp),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new notifications')),
            );
          },
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary, size: 22.sp),
              onPressed: () {
                widget.onNavigateToTab(1); // Quick switch to builder
              },
            ),
            Positioned(
              right: 8.w,
              top: 8.h,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: ListenableBuilder(
                  listenable: widget.customBuildState,
                  builder: (context, child) {
                    return Text(
                      '${widget.customBuildState.selectedCount}',
                      style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Search components, GPUs, PCs...',
            hintStyle: TextStyle(fontSize: 12.sp, color: AppColors.textLight),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary, size: 20.sp),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18.sp),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 20.sp),
                    onPressed: () {
                      widget.onNavigateToTab(1); // Go to component builder
                    },
                  ),
            contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildHeroCarousel() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _bannersStream,
      initialData: AppData.heroBanners,
      builder: (context, snapshot) {
        final rawBanners = snapshot.data;
        final banners = (rawBanners != null && rawBanners.isNotEmpty)
            ? rawBanners
            : AppData.heroBanners;

        return Column(
          children: [
            SizedBox(
              height: 200.h,
              child: PageView.builder(
                controller: _heroPageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  _activeHeroIndexNotifier.value = index;
                },
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppNetworkImage(
                            imageUrl: banner['imageUrl'] ?? '',
                            fit: BoxFit.cover,
                          ),
                          // Dark Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.88),
                                  Colors.black.withValues(alpha: 0.35),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: 1.sw - 64.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (banner['badge'] != null && (banner['badge'] as String).isNotEmpty)
                                      LiveBadge(
                                        text: banner['badge'] ?? '',
                                        backgroundColor: AppColors.primary,
                                        textColor: Colors.white,
                                      ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      banner['title'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      banner['subtitle'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11.sp,
                                        height: 1.25,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    GestureDetector(
                                      onTap: () {
                                        widget.onNavigateToTab(1); // Go to builder
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryAccent,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              banner['cta'] ?? 'Explore',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Icon(Icons.arrow_forward_rounded, size: 13.sp, color: Colors.black),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
            SizedBox(height: 8.h),
            ValueListenableBuilder<int>(
              valueListenable: _activeHeroIndexNotifier,
              builder: (context, activeIndex, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    banners.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: activeIndex == index ? 16.w : 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: activeIndex == index ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomBuilderCTA() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.darkBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryAccent],
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Icons.build_circle_rounded, color: Colors.white, size: 28.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom PC Configurator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Choose parts with live wattage & compatibility check',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            ElevatedButton(
              onPressed: () {
                widget.onNavigateToTab(1); // Navigate to Builder tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text(
                'Build Now',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 6.r,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedPrebuiltsSection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SectionHeader(
            title: 'Featured Pre-built PCs',
            subtitle: 'Factory assembled, tested & bench-marked',
            actionText: 'View All',
            onAction: () {},
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 330.h,
          child: StreamBuilder<List<PcBuildModel>>(
            stream: _prebuiltsStream,
            initialData: AppData.featuredPrebuilts,
            builder: (context, snapshot) {
              final rawPrebuilts = snapshot.data;
              final prebuilts = (rawPrebuilts != null && rawPrebuilts.isNotEmpty)
                  ? rawPrebuilts
                  : AppData.featuredPrebuilts;
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: prebuilts.length,
                separatorBuilder: (context, index) => SizedBox(width: 14.w),
                itemBuilder: (context, index) {
                  final pc = prebuilts[index];
                  return _buildPrebuiltCard(pc);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrebuiltCard(PcBuildModel pc) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PcDetailsView(
              pc: pc,
              customBuildState: widget.customBuildState,
              onNavigateToTab: widget.onNavigateToTab,
            ),
          ),
        );
      },
      child: Container(
        width: 250.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Badge
            Stack(
              children: [
                AppNetworkImage(
                  imageUrl: pc.imageUrl,
                  height: 125.h,
                  width: double.infinity,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  fit: BoxFit.cover,
                ),
                if (pc.badge.isNotEmpty)
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: LiveBadge(
                      text: pc.badge,
                      backgroundColor: pc.badge == 'BESTSELLER' ? AppColors.primary : AppColors.accentAmber,
                      textColor: pc.badge == 'BESTSELLER' ? Colors.white : Colors.black,
                    ),
                  ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_border_rounded, size: 16.sp, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pc.tier,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 14.sp, color: Colors.amber),
                          SizedBox(width: 2.w),
                          Text(
                            '${pc.rating}',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    pc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Spec Badges
                  Row(
                    children: [
                      Expanded(
                        child: SpecChip(
                          icon: Icons.videogame_asset_rounded,
                          label: pc.gpu.split(' ').take(3).join(' '),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: SpecChip(
                          icon: Icons.memory_rounded,
                          label: pc.cpu.split(' ').take(3).join(' '),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '৳${pc.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (pc.originalPrice != null)
                            Text(
                              '৳${pc.originalPrice!.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textLight,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Customize',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingComponentsSection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SectionHeader(
            title: 'Trending Hardware',
            subtitle: 'Best selling CPUs, GPUs and Motherboards',
            actionText: 'See All Parts',
            onAction: () => widget.onNavigateToTab(1),
          ),
        ),
        SizedBox(height: 8.h),
        StreamBuilder<List<PcComponent>>(
          stream: _componentsStream,
          initialData: AppData.allComponents,
          builder: (context, snapshot) {
            final rawComps = snapshot.data;
            final allComps = (rawComps != null && rawComps.isNotEmpty)
                ? rawComps
                : AppData.allComponents;
            final list = allComps.take(4).toList();
            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final comp = list[index];
                return Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      AppNetworkImage(
                        imageUrl: comp.imageUrl,
                        width: 56.w,
                        height: 56.w,
                        borderRadius: BorderRadius.circular(10.r),
                        fallbackIcon: comp.category.icon,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6.w,
                              runSpacing: 2.h,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  comp.category.displayName,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (comp.badge != null)
                                  LiveBadge(
                                    text: comp.badge!,
                                    backgroundColor: AppColors.primarySurface,
                                    textColor: AppColors.primaryDark,
                                  ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              comp.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              comp.specs.entries.take(2).map((e) => '${e.key}: ${e.value}').join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '৳${comp.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          GestureDetector(
                            onTap: () {
                              widget.customBuildState.selectComponent(comp);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${comp.name} added to custom build!'),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_rounded, size: 14.sp, color: AppColors.primary),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Add',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrustSection() {
    final trustItems = [
      {'icon': Icons.handshake_outlined, 'title': 'Free Assembly', 'desc': 'Cable routed & stress tested'},
      {'icon': Icons.verified_user_outlined, 'title': '3-Year Warranty', 'desc': 'Full component replacement'},
      {'icon': Icons.bolt_outlined, 'title': 'Fast Delivery', 'desc': 'Safe insured courier shipment'},
      {'icon': Icons.support_agent_outlined, 'title': 'Tech Support', 'desc': 'Lifetime builder assistance'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: AppStrings.whyChooseUs),
          SizedBox(height: 8.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trustItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
            ),
            itemBuilder: (context, index) {
              final item = trustItems[index];
              return Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(item['icon'] as IconData, color: AppColors.primary, size: 24.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            item['desc'] as String,
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSearchResults(String rawQuery) {
    final query = rawQuery.toLowerCase().trim();

    return StreamBuilder<List<PcBuildModel>>(
      stream: _prebuiltsStream,
      initialData: AppData.featuredPrebuilts,
      builder: (context, pcSnapshot) {
        return StreamBuilder<List<PcComponent>>(
          stream: _componentsStream,
          initialData: AppData.allComponents,
          builder: (context, compSnapshot) {
            final rawPcs = pcSnapshot.data;
            final allPcs = (rawPcs != null && rawPcs.isNotEmpty) ? rawPcs : AppData.featuredPrebuilts;
            final rawComps = compSnapshot.data;
            final allComps = (rawComps != null && rawComps.isNotEmpty) ? rawComps : AppData.allComponents;

            final matchingPcs = allPcs.where((pc) {
              return pc.title.toLowerCase().contains(query) ||
                  pc.cpu.toLowerCase().contains(query) ||
                  pc.gpu.toLowerCase().contains(query) ||
                  pc.tier.toLowerCase().contains(query) ||
                  pc.tags.any((t) => t.toLowerCase().contains(query));
            }).toList();

            final matchingComps = allComps.where((comp) {
              return comp.name.toLowerCase().contains(query) ||
                  comp.brand.toLowerCase().contains(query) ||
                  comp.category.displayName.toLowerCase().contains(query) ||
                  comp.category.shortName.toLowerCase().contains(query) ||
                  comp.specs.values.any((v) => v.toLowerCase().contains(query));
            }).toList();

            final totalResults = matchingPcs.length + matchingComps.length;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.manage_search_rounded, color: AppColors.primary, size: 20.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Results for "$rawQuery"',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '$totalResults found',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  if (totalResults == 0) ...[
                    // Empty Search State
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 36.h),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: const BoxDecoration(
                                color: AppColors.inputBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.search_off_rounded, size: 40.sp, color: AppColors.textLight),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'No matching hardware or PCs found',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Try searching for brand names, processors, GPUs or SSDs',
                              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              alignment: WrapAlignment.center,
                              children: [
                                'RTX 4080',
                                'Ryzen 7',
                                'DDR5',
                                'Samsung 990',
                                'NZXT',
                                'ASUS',
                                'Corsair'
                              ].map((keyword) {
                                return ActionChip(
                                  label: Text(keyword, style: TextStyle(fontSize: 11.sp)),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: AppColors.border),
                                  onPressed: () {
                                    _searchController.text = keyword;
                                    setState(() {});
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Matching Pre-built PCs
                    if (matchingPcs.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.desktop_windows_rounded, size: 16.sp, color: AppColors.primary),
                          SizedBox(width: 6.w),
                          Text(
                            'Pre-built Systems (${matchingPcs.length})',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: matchingPcs.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final pc = matchingPcs[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PcDetailsView(
                                    pc: pc,
                                    customBuildState: widget.customBuildState,
                                    onNavigateToTab: widget.onNavigateToTab,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6.r,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  AppNetworkImage(
                                    imageUrl: pc.imageUrl,
                                    width: 65.w,
                                    height: 65.w,
                                    borderRadius: BorderRadius.circular(10.r),
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              pc.tier,
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(Icons.star_rounded, size: 14.sp, color: Colors.amber),
                                            SizedBox(width: 2.w),
                                            Text(
                                              '${pc.rating}',
                                              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          pc.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          '${pc.gpu.split(' ').take(2).join(' ')} • ${pc.cpu.split(' ').take(2).join(' ')}',
                                          style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '৳${pc.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20.sp),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 18.h),
                    ],

                    // Matching Hardware Components
                    if (matchingComps.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.memory_rounded, size: 16.sp, color: AppColors.primary),
                          SizedBox(width: 6.w),
                          Text(
                            'Hardware Components (${matchingComps.length})',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: matchingComps.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final comp = matchingComps[index];
                          return Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6.r,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                AppNetworkImage(
                                  imageUrl: comp.imageUrl,
                                  width: 50.r,
                                  height: 50.r,
                                  borderRadius: BorderRadius.circular(10.r),
                                  fallbackIcon: comp.category.icon,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            comp.category.shortName,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            '• ${comp.brand}',
                                            style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        comp.name,
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
                                            '৳${comp.price.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          if (comp.wattage > 0) ...[
                                            SizedBox(width: 6.w),
                                            Text(
                                              '• ${comp.wattage}W',
                                              style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                ElevatedButton(
                                  onPressed: () {
                                    widget.customBuildState.selectComponent(comp);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added "${comp.name}" to your custom PC!'),
                                        backgroundColor: AppColors.success,
                                        action: SnackBarAction(
                                          label: 'View Builder',
                                          textColor: Colors.white,
                                          onPressed: () => widget.onNavigateToTab(1),
                                        ),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primarySurface,
                                    foregroundColor: AppColors.primary,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                  ),
                                  child: Text(
                                    '+ Add',
                                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
