import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../game/domain/entities/valorant_context_response.dart';
import '../../../game/infrastructure/datasources/game_config_remote_data_source.dart';

/// DAY_128: Synergy score bar, counter gap warning, retake readiness when gameType == VALORANT.
class ValorantStrategyIndicatorsSection extends StatefulWidget {
  /// When non-null, fetches prediction context from API and displays.
  final Map<String, dynamic>? roundContext;

  const ValorantStrategyIndicatorsSection({
    super.key,
    this.roundContext,
  });

  @override
  State<ValorantStrategyIndicatorsSection> createState() =>
      _ValorantStrategyIndicatorsSectionState();
}

class _ValorantStrategyIndicatorsSectionState
    extends State<ValorantStrategyIndicatorsSection> {
  ValorantContextResponse? _context;
  bool _loading = false;
  String? _error;

  @override
  void didUpdateWidget(ValorantStrategyIndicatorsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roundContext != widget.roundContext) {
      _fetchIfNeeded();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchIfNeeded();
  }

  Future<void> _fetchIfNeeded() async {
    final ctx = widget.roundContext;
    if (ctx == null || ctx.isEmpty) {
      setState(() {
        _context = null;
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await getIt<GameConfigRemoteDataSource>()
          .postValorantPredictionContext(ctx);
      if (mounted) {
        setState(() {
          _context = response;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _context = null;
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasContext = widget.roundContext != null && widget.roundContext!.isNotEmpty;
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Strategy indicators',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!hasContext)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Configure agents and ults above; use round game data to see synergy, counter gap, and retake readiness.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              )
            else if (_loading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red.shade300, fontSize: 12),
                ),
              )
            else if (_context != null) ...[
              _ScoreRow(
                label: 'Synergy',
                value: _context!.synergyScore,
                isWarning: false,
              ),
              const SizedBox(height: 8),
              _ScoreRow(
                label: 'Counter gap',
                value: _context!.counterGap,
                isWarning: _context!.counterGap > 10,
              ),
              if (_context!.weakAgainst.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Vulnerable: ${_context!.weakAgainst.join(", ")}',
                    style: TextStyle(
                      color: Colors.amber.shade200,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              _ScoreRow(
                label: 'Retake readiness',
                value: _context!.retakeScore,
                isWarning: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int value;
  final bool isWarning;

  const _ScoreRow({
    required this.label,
    required this.value,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        if (isWarning) Icon(Icons.warning_amber, size: 18, color: Colors.amber),
        if (isWarning) const SizedBox(width: 4),
        Expanded(
          child: LinearProgressIndicator(
            value: value.clamp(0, 100) / 100,
            backgroundColor: Colors.grey.shade600,
            valueColor: AlwaysStoppedAnimation<Color>(
              isWarning ? Colors.amber : Colors.green.shade300,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value',
          style: TextStyle(
            color: isWarning ? Colors.amber : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
