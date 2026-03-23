import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_radius.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/team/active_team_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../capabilities/infrastructure/datasources/capabilities_remote_data_source.dart';
import '../../domain/entities/match_summary.dart';
import '../../infrastructure/datasources/dashboard_remote_data_source.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/tactical_insights_feed.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<String?>? _teamIdFuture;

  Future<String?> _teamIdAfterResolved() async {
    final active = getIt<ActiveTeamService>();
    await active.ensureResolved();
    return active.activeTeamId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(
            child: Text(
              'Please log in',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        _teamIdFuture ??= _teamIdAfterResolved();
        return FutureBuilder<String?>(
          future: _teamIdFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final teamId = snapshot.data;
            if (teamId == null || teamId.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    snapshot.hasError
                        ? 'Could not load teams. Check backend connection.'
                        : 'No team found. Create or join a team to see the dashboard.',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return BlocProvider(
              create: (_) {
                final bloc = DashboardBloc(
                  dataSource: getIt<DashboardRemoteDataSource>(),
                  capabilitiesDataSource: getIt<CapabilitiesRemoteDataSource>(),
                );
                bloc.add(DashboardLoaded(teamId));
                return bloc;
              },
              child: _DashboardBody(teamId: teamId),
            );
          },
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final String teamId;

  const _DashboardBody({required this.teamId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DashboardLoadedState) {
          return _DashboardContent(teamId: teamId, state: state);
        }
        if (state is DashboardError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<DashboardBloc>().add(DashboardLoaded(teamId));
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return Center(
          child: Text(
            'Error loading dashboard',
            style: TextStyle(color: Colors.white70),
          ),
        );
      },
    );
  }
}

/// Dashboard header: title, search, notifications (ui_stitch clutch_map_dashboard_overview).
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppColors.neutral900.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: AppColors.neutralBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Project Overview',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 256,
            height: 36,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tactics...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.white38),
                filled: true,
                fillColor: AppColors.neutralSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.white54),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neutral900, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final String teamId;
  final DashboardLoadedState state;

  const _DashboardContent({required this.teamId, required this.state});

  @override
  Widget build(BuildContext context) {
    final showProBanner = state.capabilities != null && state.capabilities!.planCode == 'FREE';
    final recent = state.recentMatches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DashboardHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.insights.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: TacticalInsightsFeed(
                      teamId: teamId,
                      insights: state.insights,
                      onRefresh: () {
                        context.read<DashboardBloc>().add(DashboardInsightsRefreshRequested(teamId));
                      },
                      onDismiss: (id) {
                        context.read<DashboardBloc>().add(
                              DashboardInsightDismissed(teamId: teamId, insightId: id),
                            );
                      },
                    ),
                  ),
                _StatsRow(),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 900;
                    return wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _RecentlyEditedTactics(
                                  recent: recent,
                                  onViewLibrary: () => context.go('/matches'),
                                  onTapTactic: (id) => context.go('/match/$id'),
                                ),
                              ),
                              const SizedBox(width: 32),
                              SizedBox(
                                width: 320,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _UpcomingScrims(),
                                    const SizedBox(height: 24),
                                    if (showProBanner) _ProFeatureCard(),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _RecentlyEditedTactics(
                                recent: recent,
                                onViewLibrary: () => context.go('/matches'),
                                onTapTactic: (id) => context.go('/match/$id'),
                              ),
                              const SizedBox(height: 24),
                              _UpcomingScrims(),
                              if (showProBanner) ...[
                                const SizedBox(height: 24),
                                _ProFeatureCard(),
                              ],
                            ],
                          );
                  },
                ),
                const SizedBox(height: 32),
                _TeamPerformanceTable(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Three stat cards: Total Win Rate, Tactics Designed, Active Scrims.
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 700 ? 3 : 1;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: count == 1 ? 2.5 : 1.8,
          children: [
            _StatCardWinRate(),
            _StatCardTactics(),
            _StatCardScrims(),
          ],
        );
      },
    );
  }
}

class _StatCardWinRate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.neutralSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutralBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Win Rate',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '64.2%',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    '2.4%',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.642,
              minHeight: 6,
              backgroundColor: AppColors.neutralBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardTactics extends StatelessWidget {
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tactics Designed',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '142',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'this season',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Bar(h: 16, opacity: 0.2),
              const SizedBox(width: 4),
              _Bar(h: 24, opacity: 0.4),
              const SizedBox(width: 4),
              _Bar(h: 12, opacity: 0.1),
              const SizedBox(width: 4),
              _Bar(h: 32, opacity: 1),
              const SizedBox(width: 4),
              _Bar(h: 20, opacity: 0.6),
              const SizedBox(width: 4),
              _Bar(h: 28, opacity: 0.8),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double h;
  final double opacity;

  const _Bar({required this.h, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _StatCardScrims extends StatelessWidget {
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Scrims',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '04',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'live now',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ScrimAvatar(label: 'T1'),
              _ScrimAvatar(label: 'G2'),
              _ScrimAvatar(label: 'FN'),
              _ScrimAvatar(label: '+8', primary: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScrimAvatar extends StatelessWidget {
  final String label;
  final bool primary;

  const _ScrimAvatar({required this.label, this.primary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: -8),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary ? AppColors.primary.withValues(alpha: 0.2) : AppColors.neutralBorder,
        border: Border.all(color: AppColors.neutralSurface, width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: primary ? AppColors.primary : Colors.white54,
          ),
        ),
      ),
    );
  }
}

class _RecentlyEditedTactics extends StatelessWidget {
  final List<MatchSummary> recent;
  final VoidCallback onViewLibrary;
  final ValueChanged<String> onTapTactic;

  const _RecentlyEditedTactics({
    required this.recent,
    required this.onViewLibrary,
    required this.onTapTactic,
  });

  @override
  Widget build(BuildContext context) {
    final items = recent.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recently Edited Tactics',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: onViewLibrary,
              child: Text(
                'View Library',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        items.isEmpty
            ? _EmptyTacticsCard(onViewLibrary: onViewLibrary)
            : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  for (final m in items) _TacticCard(match: m, onTap: () => onTapTactic(m.id)),
                ],
              ),
      ],
    );
  }
}

class _EmptyTacticsCard extends StatelessWidget {
  final VoidCallback onViewLibrary;

  const _EmptyTacticsCard({required this.onViewLibrary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.neutralSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_tree_outlined, size: 40, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              'No tactics yet',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onViewLibrary,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create or view tactics'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TacticCard extends StatelessWidget {
  final MatchSummary match;
  final VoidCallback onTap;

  const _TacticCard({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mapName = match.mapName ?? 'Map';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.neutralSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.neutralBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    _MiniMapPreview(),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          mapName.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Edited ${_formatAgo(match.updatedAt)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white54,
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

  String _formatAgo(DateTime date) {
    final d = DateTime.now().difference(date);
    if (d.inMinutes < 60) return '${d.inMinutes} mins ago';
    if (d.inHours < 24) return '${d.inHours} hours ago';
    if (d.inDays == 1) return 'yesterday';
    if (d.inDays < 7) return '${d.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MiniMapPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral900,
      child: CustomPaint(
        painter: _TacticalGridPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _TacticalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const step = 20.0;
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    // Simple wall blocks
    final wallPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;
    final wallBorder = Paint()
      ..color = const Color(0xFF444444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final r1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.2, size.width * 0.25, size.height * 0.35),
      const Radius.circular(4),
    );
    canvas.drawRRect(r1, wallPaint);
    canvas.drawRRect(r1, wallBorder);
    final r2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.45, size.width * 0.2, size.height * 0.2),
      const Radius.circular(4),
    );
    canvas.drawRRect(r2, wallPaint);
    canvas.drawRRect(r2, wallBorder);
    // Orange path hint
    final pathPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.75), 4, pathPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.4), 4, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UpcomingScrims extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Scrims',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _ScrimRow(opponent: 'Team Liquid', meta: 'Starts in 45 mins • BO3', tag: 'T1'),
        const SizedBox(height: 12),
        _ScrimRow(opponent: 'Natus Vincere', meta: 'Tomorrow, 14:00 • BO1', tag: 'NA'),
      ],
    );
  }
}

class _ScrimRow extends StatelessWidget {
  final String opponent;
  final String meta;
  final String tag;

  const _ScrimRow({
    required this.opponent,
    required this.meta,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.neutralBorder,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text(
                tag,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VS $opponent',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
                Text(
                  meta,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white54, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ProFeatureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Pro Feature',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock advanced server simulations and real-time utility tracking for your team.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Learn more',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamPerformanceTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Performance Stats',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.neutralSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.neutralBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.neutralBorder),
                  ),
                ),
                children: [
                  _TableHeader('Player'),
                  _TableHeader('ADR'),
                  _TableHeader('KAST %'),
                  _TableHeader('Rating'),
                  _TableHeader('Trend'),
                ],
              ),
              _playerRow('Simple_01', 'S', '94.5', '78.2%', '1.28', primary: true),
              _playerRow('Niko_R', 'N', '88.1', '74.5%', '1.15', primary: false),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _playerRow(
    String name,
    String initial,
    String adr,
    String kast,
    String rating, {
    required bool primary,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.neutralBorder.withValues(alpha: 0.5)),
        ),
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
                  color: primary
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.neutralBorder,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: primary ? AppColors.primary : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            adr,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            kast,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            rating,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TrendBar(h: 12, opacity: primary ? 1 : 0.4),
              const SizedBox(width: 4),
              _TrendBar(h: 20, opacity: primary ? 1 : 0.4),
              const SizedBox(width: 4),
              _TrendBar(h: 16, opacity: primary ? 1 : 0.4),
              const SizedBox(width: 4),
              _TrendBar(h: 24, opacity: primary ? 1 : 0.4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _TableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white54,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _TrendBar extends StatelessWidget {
  final double h;
  final double opacity;

  const _TrendBar({required this.h, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
