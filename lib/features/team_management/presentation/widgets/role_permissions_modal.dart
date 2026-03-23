import 'package:flutter/material.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_radius.dart';

/// Role permissions modal (ui_stitch clutch_map_role_permissions_modal).
class RolePermissionsModal extends StatefulWidget {
  const RolePermissionsModal({
    super.key,
    this.onSave,
    this.onCancel,
  });

  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSave,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => RolePermissionsModal(
        onSave: onSave,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<RolePermissionsModal> createState() => _RolePermissionsModalState();
}

class _RolePermissionsModalState extends State<RolePermissionsModal> {
  int _selectedRoleIndex = 1; // Coach selected by default

  static final _roles = [
    (icon: Icons.shield_outlined, label: 'Administrator'),
    (icon: Icons.sports_esports_outlined, label: 'Coach'),
    (icon: Icons.analytics_outlined, label: 'Analyst'),
    (icon: Icons.person_outline, label: 'Player'),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 896, maxHeight: 900),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.neutralSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.neutralBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _rolesSidebar(),
                    Container(width: 1, color: AppColors.neutralBorder),
                    Expanded(child: _permissionsContent()),
                  ],
                ),
              ),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.neutralBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Role Permissions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure what each member of your organization can do.',
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white54),
            onPressed: () {
              widget.onCancel?.call();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _rolesSidebar() {
    return SizedBox(
      width: 256,
      child: Container(
        color: AppColors.neutralSurface.withValues(alpha: 0.5),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                'ORGANIZATION ROLES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ...List.generate(_roles.length, (i) {
              final r = _roles[i];
              final selected = _selectedRoleIndex == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Material(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: InkWell(
                    onTap: () => setState(() => _selectedRoleIndex = i),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: selected
                            ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            r.icon,
                            size: 20,
                            color: selected ? AppColors.primary : Colors.white54,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            r.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                              color: selected ? AppColors.primary : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.neutralBorder),
                ),
              ),
              child: TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add_circle_outline, size: 20, color: AppColors.primary),
                label: Text(
                  'Create Custom Role',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permissionsContent() {
    final roleName = _roles[_selectedRoleIndex].label;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports_esports_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                '$roleName Permissions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Manage high-level strategic planning and team coordination tools.',
            style: TextStyle(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 32),
          _permissionGroup(
            'STRATEGIC PLANNING',
            [
              ('Edit Tactics', 'Modify maps, paths, and utility placements.', true),
              ('Export Playbooks', 'Generate PDF or interactive video briefings.', true),
            ],
          ),
          const SizedBox(height: 32),
          _permissionGroup(
            'MANAGEMENT & DATA',
            [
              ('Manage Roster', 'Invite new players and assign them to specific squads.', false),
              ('View Analytics', 'Access team performance metrics and heatmaps.', true),
              ('Organization Settings', 'Modify billing information and main org preferences.', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _permissionGroup(String title, List<(String, String, bool)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items.map((e) => _permissionRow(e.$1, e.$2, e.$3)),
      ],
    );
  }

  Widget _permissionRow(String title, String subtitle, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) {},
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.neutralSurface,
        border: Border(
          top: BorderSide(color: AppColors.neutralBorder),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              widget.onCancel?.call();
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () {
              widget.onSave?.call();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
