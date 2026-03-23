import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/team/active_team_service.dart';
import '../../../../core/team/team_remote_data_source.dart';
import '../widgets/create_team_dialog.dart';

class TeamSelectionPage extends StatefulWidget {
  const TeamSelectionPage({super.key});

  @override
  State<TeamSelectionPage> createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  List<TeamSummary> _teams = [];
  bool _loading = true;
  String? _error;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = getIt<ActiveTeamService>().activeTeamId;
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final teams = await getIt<TeamRemoteDataSource>().getMyTeams();
      setState(() {
        _teams = teams;
        if (_selectedId == null && teams.isNotEmpty) {
          _selectedId = teams.first.id;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _continueToDashboard() {
    final active = getIt<ActiveTeamService>();
    if (_selectedId != null) {
      active.setActiveTeamId(_selectedId);
    }
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              AppColors.backgroundDark,
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildError()
                        : _buildContent(context),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        color: AppColors.backgroundDark.withValues(alpha: 0.5),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_tree,
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
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
          Row(
            children: [
              _NavLink(label: 'Dashboard', onTap: () {}),
              const SizedBox(width: 32),
              _NavLink(label: 'Tactics', onTap: () {}),
              const SizedBox(width: 32),
              _NavLink(label: 'Maps', onTap: () {}),
              const SizedBox(width: 32),
              _NavLink(label: 'Teams', onTap: () {}),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 200,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search squads...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(width: 24),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Profile'),
          ),
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Icon(Icons.person, color: Colors.white54, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load teams.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTeams,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Column(
            children: [
              Text(
                'Select Your Team',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose an existing squad to access your tactical playbooks or create a new one to start fresh planning.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              LayoutBuilder(
                builder: (context, constraints) {
                  const crossAxisCount = 4;
                  const gap = 24.0;
                  final width = (constraints.maxWidth - gap * (crossAxisCount - 1)) / crossAxisCount;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    alignment: WrapAlignment.center,
                    children: [
                      ..._teams.map((t) => SizedBox(
                            width: width,
                            child: _TeamCard(
                              team: t,
                              selected: _selectedId == t.id,
                              onTap: () => setState(() => _selectedId = t.id),
                            ),
                          )),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
              _buildCreateNewTeamCard(),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Join Team'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _selectedId != null ? _continueToDashboard : null,
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    label: const Text('Continue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundDark,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      minimumSize: const Size(200, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateTeamDialog() async {
    final result = await CreateTeamDialog.show(context);
    if (result == null || !mounted) return;

    setState(() => _loading = true);
    try {
      final teamDataSource = getIt<TeamRemoteDataSource>();
      final created = await teamDataSource.createTeam(
        result.name,
        description: result.description,
      );
      if (!mounted) return;
      await _loadTeams();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _selectedId = created.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Team "${created.name}" created.'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not create team: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Widget _buildCreateNewTeamCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openCreateTeamDialog,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            color: AppColors.primary.withValues(alpha: 0.05),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.add, size: 28, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Create New Team',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Text(
                  'Establish a new squad identity, invite members, and start building your custom tactical map strategies.',
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '© 2024 Clutch Map Tactical Planning Platform',
            style: TextStyle(fontSize: 12, color: Colors.white38),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Documentation', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Support', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Legal', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white54,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final TeamSummary team;
  final bool selected;
  final VoidCallback onTap;

  const _TeamCard({
    required this.team,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 25,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF1E293B),
                  ),
                  child: Center(
                    child: Text(
                      team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                team.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.primary : Colors.white24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selected ? 'Selected' : 'Members • Online',
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
