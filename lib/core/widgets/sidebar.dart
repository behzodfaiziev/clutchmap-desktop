import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design/app_colors.dart';
import '../design/app_radius.dart';

/// Sidebar width matching ui_stitch (w-64 = 256px).
const double kSidebarWidth = 256;

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  static final _navItems = [
    (path: '/', label: 'Dashboard', icon: Icons.dashboard_outlined),
    (path: '/matches', label: 'Tactics Library', icon: Icons.sports_esports_outlined),
    (path: '/templates', label: 'Scrim Schedule', icon: Icons.calendar_today_outlined),
    (path: '/benchmark', label: 'Analytics', icon: Icons.insights_outlined),
    (path: '/opponents', label: 'Roster Planning', icon: Icons.group_outlined),
    (path: '/teams', label: 'Team Management', icon: Icons.groups_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    return Container(
      width: kSidebarWidth,
      color: AppColors.neutral900,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.query_stats,
                    size: 20,
                    color: AppColors.backgroundDark,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Clutch Map',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _navItems.map((item) {
                final selected = currentPath == item.path ||
                    (item.path == '/' && currentPath == '/') ||
                    (item.path != '/' && currentPath.startsWith(item.path));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => context.go(item.path),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: selected
                                  ? AppColors.primary
                                  : Colors.white54,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    selected ? FontWeight.w500 : FontWeight.normal,
                                color: selected
                                    ? AppColors.primary
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.neutralBorder,
                ),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/matches'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Strategy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundDark,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.neutralSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 18,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Coach Miller',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Pro Plan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 20),
                      color: Colors.white54,
                      onPressed: () => context.go('/settings'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
