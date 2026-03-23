import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_radius.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/team/active_team_service.dart';
import '../../../../core/team/team_remote_data_source.dart';
import '../widgets/role_permissions_modal.dart';

/// Team management dashboard: roster, subscription, activity log (ui_stitch clutch_map_team_management_dashboard).
class TeamManagementPage extends StatefulWidget {
  const TeamManagementPage({super.key});

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  late Future<String?> _teamNameFuture;

  @override
  void initState() {
    super.initState();
    _teamNameFuture = _loadTeamName();
  }

  Future<String?> _loadTeamName() async {
    final active = getIt<ActiveTeamService>();
    final id = active.activeTeamId;
    if (id == null || id.isEmpty) return null;
    final teams = await getIt<TeamRemoteDataSource>().getMyTeams();
    final match = teams.where((t) => t.id == id).toList();
    return match.isEmpty ? null : match.first.name;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _teamNameFuture,
      builder: (context, snapshot) {
        final teamName = snapshot.data ?? 'My Team';
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TeamHeader(teamName: teamName),
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _MemberRosterSection(),
                        ),
                        const SizedBox(width: 32),
                        SizedBox(
                          width: 340,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SubscriptionSection(),
                              const SizedBox(height: 32),
                              _ActivityLogSection(),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MemberRosterSection(),
                      const SizedBox(height: 32),
                      _SubscriptionSection(),
                      const SizedBox(height: 32),
                      _ActivityLogSection(),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TeamHeader extends StatelessWidget {
  final String teamName;

  const _TeamHeader({required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.neutralBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.neutralSurface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                      ),
                      child: Icon(
                        Icons.groups_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Material(
                        color: AppColors.neutralSurface,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () {},
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.edit, size: 14, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamName,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Professional Esports Organization',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white38,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pro Plan',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.settings_outlined, size: 18, color: Colors.white70),
                label: Text(
                  'Team Settings',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.neutralBorder),
                  backgroundColor: AppColors.neutralSurface,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => RolePermissionsModal.show(context),
                icon: Icon(Icons.shield_outlined, size: 18, color: Colors.white70),
                label: Text(
                  'Role Permissions',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.neutralBorder),
                  backgroundColor: AppColors.neutralSurface,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.person_add_outlined, size: 18, color: AppColors.backgroundDark),
                label: Text(
                  'Invite Member',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.backgroundDark,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberRosterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const members = [
      (name: 'Lukas Rossander', initial: 'LR', role: 'IGL', rolePrimary: true, online: true),
      (name: 'Danny Sørensen', initial: 'DS', role: 'Coach', rolePrimary: false, online: true),
      (name: 'Peter Rasmussen', initial: 'PR', role: 'Analyst', rolePrimary: false, online: false),
      (name: 'Alexander Holdt', initial: 'AH', role: 'Entry', rolePrimary: false, online: false),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutralSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.neutralBorder)),
              color: Colors.white.withValues(alpha: 0.03),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Member Roster',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '12 MEMBERS TOTAL',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(0.8),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.neutralBorder)),
                ),
                children: [
                  _TableHeader('Member'),
                  _TableHeader('Role'),
                  _TableHeader('Status', center: true),
                  _TableHeader('Actions', right: true),
                ],
              ),
              for (final m in members) _memberRow(m),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
            ),
            child: Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'VIEW ALL MEMBERS',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _memberRow(
    ({String name, String initial, String role, bool rolePrimary, bool online}) m,
  ) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.neutralBorder.withValues(alpha: 0.5))),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: m.rolePrimary
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.neutralBorder,
                ),
                child: Center(
                  child: Text(
                    m.initial,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: m.rolePrimary ? AppColors.primary : Colors.white54,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                m.name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: m.rolePrimary
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.neutralBorder.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: m.rolePrimary
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.neutralBorder,
              ),
            ),
            child: Text(
              m.role,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: m.rolePrimary ? AppColors.primary : Colors.white54,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: m.online ? AppColors.success : Colors.white38,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'MANAGE',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _TableHeader(String label, {bool center = false, bool right = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: Align(
      alignment: right ? Alignment.centerRight : (center ? Alignment.center : Alignment.centerLeft),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white54,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );
}

class _SubscriptionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.neutralSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Subscription & Seats',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: 0.8,
                backgroundColor: AppColors.neutralBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Seats',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
              ),
              Text(
                '8 / 10',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neutralBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT PLAN',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Professional Tier',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Renews Oct 12, 2024',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              foregroundColor: AppColors.primary,
            ),
            child: Text(
              'Add More Seats',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final String name;
  final String action;
  final String ago;
  final bool primary;
  const _ActivityItem(this.name, this.action, this.ago, this.primary);
}

class _ActivityLogSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      _ActivityItem('Lukas Rossander', 'updated \'Inferno Execute\'', '2 minutes ago', true),
      _ActivityItem('Danny Sørensen', 'added a new tactical note', '1 hour ago', false),
      _ActivityItem('System', 'automatically backed up data', '4 hours ago', true),
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.neutralSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Activity Log',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: items[i].primary ? AppColors.primary : Colors.white38,
                    border: Border.all(color: AppColors.backgroundDark, width: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                          children: [
                            TextSpan(
                              text: items[i].name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' ${items[i].action}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].ago.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white54,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i < items.length - 1) const SizedBox(height: 16),
          ],
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'FULL ACTIVITY LOGS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
