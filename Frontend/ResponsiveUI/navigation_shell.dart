import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';
import 'package:medprescribe_frontend/shared/themes/app_theme.dart';
import 'package:medprescribe_frontend/shared/layouts/responsive_layout.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String routePath;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.routePath,
  });
}

class NavigationShell extends StatelessWidget {
  final Widget child;

  const NavigationShell({super.key, required this.child});

  static const List<NavigationItem> items = [
    NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      routePath: '/dashboard',
    ),
    NavigationItem(
      label: 'ICD Lookup',
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
      routePath: '/icd',
    ),
    NavigationItem(
      label: 'Drug Lookup',
      icon: Icons.medical_services_outlined,
      selectedIcon: Icons.medical_services,
      routePath: '/drugs',
    ),
    NavigationItem(
      label: 'Interaction Check',
      icon: Icons.flourescent_outlined,
      selectedIcon: Icons.flourescent,
      routePath: '/interactions',
    ),
    NavigationItem(
      label: 'Prescription',
      icon: Icons.note_alt_outlined,
      selectedIcon: Icons.note_alt,
      routePath: '/prescriptions',
    ),
    NavigationItem(
      label: 'Admin Panel',
      icon: Icons.admin_panel_settings_outlined,
      selectedIcon: Icons.admin_panel_settings,
      routePath: '/admin',
    ),
  ];

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index =
        items.indexWhere((item) => location.startsWith(item.routePath));
    return index >= 0 ? index : 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    context.go(items[index].routePath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileTabletLayout(context, theme, selectedIndex),
        tablet: _buildMobileTabletLayout(context, theme, selectedIndex),
        desktop: _buildDesktopLayout(context, theme, selectedIndex),
      ),
    );
  }

  Widget _buildMobileTabletLayout(
      BuildContext context, ThemeData theme, int selectedIndex) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(context, index),
        destinations: items.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon:
                Icon(item.selectedIcon, color: theme.colorScheme.primary),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, ThemeData theme, int selectedIndex) {
    return Row(
      children: [
        // Sidebar Navigation
        Container(
          width: 260,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: theme.brightness == Brightness.light
                    ? Colors.grey.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Sidebar Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: Text(
                        'MedPrescribe',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          color: theme.colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              AppSpacing.gapH24,
              // Sidebar Navigation items
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Material(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: AppRadius.mdBorderRadius,
                        child: InkWell(
                          onTap: () => _onItemTapped(context, index),
                          borderRadius: AppRadius.mdBorderRadius,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm + 2,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                ),
                                AppSpacing.gapW16,
                                Text(
                                  item.label,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface
                                            .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Sidebar Footer / Logout button
              const Divider(height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: Text(
                    'Logout',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    // Navigate back to login
                    context.go('/login');
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorderRadius,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                items[selectedIndex].label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              actions: [
                CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: theme.colorScheme.primary),
                ),
                AppSpacing.gapW24,
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
