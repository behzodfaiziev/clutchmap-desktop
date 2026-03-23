import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_radius.dart';
import '../../../../core/di/injection.dart';
import '../../infrastructure/datasources/workspace_remote_data_source.dart';

class OverlayPage extends StatefulWidget {
  final String matchId;

  const OverlayPage({super.key, required this.matchId});

  @override
  State<OverlayPage> createState() => _OverlayPageState();
}

class _OverlayPageState extends State<OverlayPage> {
  OverlayModel? _overlay;
  OverlayModel? _cachedOverlay;
  bool _loading = true;
  bool _connected = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchOverlay();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchOverlay());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOverlay() async {
    try {
      final dataSource = getIt<WorkspaceRemoteDataSource>();
      final result = await dataSource.getOverlay(widget.matchId);
      setState(() {
        _overlay = result;
        _cachedOverlay = result;
        _loading = false;
        _connected = true;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _connected = false;
        if (_cachedOverlay != null) _overlay = _cachedOverlay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF16110E),
      child: SafeArea(
        child: _loading && _overlay == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white54),
              )
            : _overlay == null
                ? const Center(
                    child: Text(
                      'No overlay data. Open a match and try again.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTopBar(context),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 16),
                                _buildLeftToolstrip(context),
                                const SizedBox(width: 16),
                                Expanded(child: _buildCenter()),
                                const SizedBox(width: 24),
                                SizedBox(
                                  width: 280,
                                  child: _buildAlerts(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildQuickActions(),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }

  /// Glass-style header (ui_stitch clutch_map_fullscreen_review_mode).
  Widget _buildTopBar(BuildContext context) {
    final o = _overlay!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF221710).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'FULLSCREEN REVIEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${o.map} • ${o.side}',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Round ${o.currentRound}',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(width: 16),
          Text(
            '${o.score.us}–${o.score.them}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _connected
                  ? AppColors.success.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _connected ? Icons.circle : Icons.circle_outlined,
                  size: 10,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  _connected ? 'Live' : 'Offline',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.exit_to_app, size: 18, color: AppColors.backgroundDark),
                    const SizedBox(width: 8),
                    Text(
                      'Exit Mode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Left vertical toolstrip (ui_stitch fullscreen review).
  Widget _buildLeftToolstrip(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _glassPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toolButton(Icons.ads_click, false),
              _toolButton(Icons.gesture, true),
              _toolButton(Icons.polyline, false),
              _toolButton(Icons.category, false),
              const SizedBox(height: 8),
              Divider(height: 1, color: AppColors.primary.withValues(alpha: 0.2)),
              const SizedBox(height: 8),
              _toolButton(Icons.delete_sweep, false),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _glassPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toolButton(Icons.zoom_in, false),
              _toolButton(Icons.zoom_out, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassPanel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF221710).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }

  Widget _toolButton(IconData icon, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              size: 24,
              color: active ? AppColors.backgroundDark : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenter() {
    final o = _overlay!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (o.activeArc != null) ...[
            Text(
              'ACTIVE ARC: ${o.activeArc!.name}',
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'PATTERN: ${o.roundPlan.pattern}',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'REMINDERS:',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...o.roundPlan.keyNotes.map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.amber)),
                    Expanded(
                      child: Text(
                        note,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAlerts() {
    final alerts = _overlay!.alerts;
    if (alerts.isEmpty) return const SizedBox.shrink();
    final sorted = List<OverlayAlert>.from(alerts)..sort((a, b) => b.severity.compareTo(a.severity));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ALERTS',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...sorted.take(5).map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 18, color: a.severity >= 70 ? Colors.orange : Colors.white54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${a.text} (${a.severity})',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = _overlay!.quickActions;
    if (actions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: actions.map((a) {
          return OutlinedButton(
            onPressed: _connected ? () { /* TODO: switch arc / AI tip */ } : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00E5FF),
              side: const BorderSide(color: Color(0xFF00E5FF)),
            ),
            child: Text(a.label),
          );
        }).toList(),
      ),
    );
  }
}
