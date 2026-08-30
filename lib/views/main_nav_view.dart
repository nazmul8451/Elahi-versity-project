import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../models/custom_build_state.dart';
import '../models/user_model.dart';
import 'builder/builder_view.dart';
import 'home/home_view.dart';
import 'orders/orders_view.dart';
import 'profile/profile_view.dart';

class MainNavView extends StatefulWidget {
  final UserModel user;

  const MainNavView({super.key, required this.user});

  @override
  State<MainNavView> createState() => _MainNavViewState();
}

class _MainNavViewState extends State<MainNavView> {
  int _currentIndex = 0;
  late final CustomBuildState _customBuildState;

  @override
  void initState() {
    super.initState();
    _customBuildState = CustomBuildState();
  }

  @override
  void dispose() {
    _customBuildState.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeView(
        user: widget.user,
        customBuildState: _customBuildState,
        onNavigateToTab: _onTabSelected,
      ),
      BuilderView(
        customBuildState: _customBuildState,
        onNavigateToTab: _onTabSelected,
      ),
      OrdersView(
        onNavigateToTab: _onTabSelected,
      ),
      ProfileView(
        user: widget.user,
        customBuildState: _customBuildState,
        onNavigateToTab: _onTabSelected,
      ),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textLight,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_filled),
                label: AppStrings.tabHome,
              ),
              BottomNavigationBarItem(
                icon: ListenableBuilder(
                  listenable: _customBuildState,
                  builder: (context, _) {
                    final count = _customBuildState.selectedCount;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.build_circle_outlined),
                    );
                  },
                ),
                activeIcon: ListenableBuilder(
                  listenable: _customBuildState,
                  builder: (context, _) {
                    final count = _customBuildState.selectedCount;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      backgroundColor: AppColors.primaryDark,
                      child: const Icon(Icons.build_circle_rounded),
                    );
                  },
                ),
                label: AppStrings.tabBuilder,
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping_outlined),
                activeIcon: Icon(Icons.local_shipping_rounded),
                label: AppStrings.tabOrders,
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: AppStrings.tabProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
