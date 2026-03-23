import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../game/domain/entities/agent_summary.dart';
import '../../../game/domain/entities/game_type.dart';
import '../../../game/infrastructure/datasources/game_config_remote_data_source.dart';

/// When gameType is Valorant: agent selector, ult toggles, credit input per player. DAY_127.
class ValorantRoundOptionsSection extends StatefulWidget {
  final String roundId;
  final bool canEdit;

  const ValorantRoundOptionsSection({
    super.key,
    required this.roundId,
    required this.canEdit,
  });

  @override
  State<ValorantRoundOptionsSection> createState() =>
      _ValorantRoundOptionsSectionState();
}

class _ValorantRoundOptionsSectionState extends State<ValorantRoundOptionsSection> {
  List<AgentSummary> _agents = [];
  bool _agentsLoading = true;
  final List<String?> _selectedAgents = [null, null, null, null, null];
  final List<bool> _ultReady = [false, false, false, false, false];
  final List<TextEditingController> _creditControllers = List.generate(
    5,
    (_) => TextEditingController(text: ''),
  );

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    try {
      final list = await getIt<GameConfigRemoteDataSource>()
          .getAgentsByGameType(GameType.valorant);
      if (mounted) {
        setState(() {
          _agents = list;
          _agentsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _agents = [];
          _agentsLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in _creditControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sports_esports, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Valorant — Composition & Economy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_agentsLoading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              ...List.generate(5, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: DropdownButtonFormField<String?>(
                          value: _selectedAgents[i],
                          decoration: InputDecoration(
                            labelText: 'Slot ${i + 1}',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Agent', style: TextStyle(fontSize: 12)),
                            ),
                            ..._agents.map((a) => DropdownMenuItem<String?>(
                                  value: a.code,
                                  child: Text(
                                    '${a.code} (${a.role})',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                )),
                          ],
                          onChanged: widget.canEdit
                              ? (v) {
                                  setState(() => _selectedAgents[i] = v);
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            Icon(Icons.flash_on, size: 18, color: Colors.amber),
                            const SizedBox(width: 4),
                            Checkbox(
                              value: _ultReady[i],
                              onChanged: widget.canEdit
                                  ? (v) {
                                      setState(() => _ultReady[i] = v ?? false);
                                    }
                                  : null,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: _creditControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Credits',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: widget.canEdit,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
