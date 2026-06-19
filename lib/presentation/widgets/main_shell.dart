import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_routes.dart';
import '../providers/theme_provider.dart';

// Wraps the main tab screens with a persistent bottom navigation bar.
// Visible on: Home, Career Compass, History, Profile (per design system spec).
class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  // Maps each tab index to its route path.
  static const List<String> _routes = [
    AppRoutes.home,
    AppRoutes.careerCompassQuestionnaire,
    AppRoutes.history,
    AppRoutes.profile,
  ];

  // Returns the current active tab index based on the current route location.
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.careerCompassQuestionnaire)) return 1;
    if (location.startsWith(AppRoutes.history)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final currentIndex = _currentIndex(context);

    return Scaffold(
      key: ValueKey(themeMode),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index != currentIndex) {
            context.go(_routes[index]);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.navBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedIconTheme: IconThemeData(size: 28, color: AppColors.primary),
        unselectedIconTheme: IconThemeData(size: 26, color: AppColors.textSecondary),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: AppStrings.navCompass,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: AppStrings.navHistory,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}
