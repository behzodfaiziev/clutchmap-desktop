import 'package:flutter/material.dart';
import '../../../../../core/di/injection.dart';
import '../../../../game/domain/entities/game_map_summary.dart';
import '../../../../game/domain/entities/game_type.dart';
import '../../../../game/infrastructure/datasources/game_config_remote_data_source.dart';
import '../../../domain/entities/map_preparation.dart';
import 'export_service.dart';
import 'map_preparation_card.dart';

class PreparationPage extends StatefulWidget {
  final String opponentId;
  final String opponentName;
  final String teamId;

  const PreparationPage({
    super.key,
    required this.opponentId,
    required this.opponentName,
    required this.teamId,
  });

  @override
  State<PreparationPage> createState() => _PreparationPageState();
}

class _PreparationPageState extends State<PreparationPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _overallNotesController = TextEditingController();
  final Map<String, MapPreparation> _preparations = {};
  List<GameMapSummary> _maps = [];
  bool _loading = true;

  static List<GameMapSummary> _fallbackMaps() => [
        const GameMapSummary(id: '1', name: 'Dust2'),
        const GameMapSummary(id: '2', name: 'Mirage'),
        const GameMapSummary(id: '3', name: 'Inferno'),
        const GameMapSummary(id: '4', name: 'Overpass'),
        const GameMapSummary(id: '5', name: 'Nuke'),
      ];

  @override
  void initState() {
    super.initState();
    _loadMaps();
  }

  Future<void> _loadMaps() async {
    try {
      final list = await getIt<GameConfigRemoteDataSource>().getMapsByGameType(GameType.cs2);
      if (!mounted) return;
      setState(() {
        _maps = list.isEmpty ? _fallbackMaps() : list;
        _tabController = TabController(length: _maps.length, vsync: this);
        _loadPreparations();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _maps = _fallbackMaps();
        _tabController = TabController(length: _maps.length, vsync: this);
        _loadPreparations();
        _loading = false;
      });
    }
  }

  void _loadPreparations() {
    for (var map in _maps) {
      if (!_preparations.containsKey(map.id)) {
        _preparations[map.id] = MapPreparation(
          mapId: map.id,
          mapName: map.name,
          notes: '',
          predictedAdvantage: 'EVEN_MATCH',
          confidence: 0,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _overallNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Preparation: ${widget.opponentName}")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading maps...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Preparation: ${widget.opponentName}"),
        bottom: TabBar(
          controller: _tabController!,
          isScrollable: true,
          tabs: _maps.map((m) => Tab(text: m.name)).toList(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController!,
              children: _maps.map((map) {
                final preparation = _preparations[map.id]!;
                return MapPreparationCard(
                  preparation: preparation,
                  teamId: widget.teamId,
                  opponentId: widget.opponentId,
                  onUpdated: (updated) {
                    setState(() {
                      _preparations[map.id] = updated;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Overall Match Strategy",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _overallNotesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Enter overall match strategy notes...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _exportToPdf(),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Export PDF"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf() async {
    final exportService = ExportService();
    await exportService.exportPreparation(
      opponentName: widget.opponentName,
      preparations: _preparations.values.toList(),
      overallNotes: _overallNotesController.text,
    );
  }
}

