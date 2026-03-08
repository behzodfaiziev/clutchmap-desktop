import 'package:flutter/material.dart';
import 'map_preparation_card.dart';
import 'export_service.dart';
import '../../../domain/entities/map_preparation.dart';

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
  late TabController _tabController;
  final TextEditingController _overallNotesController = TextEditingController();
  final Map<String, MapPreparation> _preparations = {};
  final List<Map<String, dynamic>> _maps = [];

  @override
  void initState() {
    super.initState();
    // For now, we'll use placeholder maps
    // In production, these would come from the game module
    _maps.addAll([
      {'id': '1', 'name': 'Dust2'},
      {'id': '2', 'name': 'Mirage'},
      {'id': '3', 'name': 'Inferno'},
      {'id': '4', 'name': 'Overpass'},
      {'id': '5', 'name': 'Nuke'},
    ]);
    _tabController = TabController(length: _maps.length, vsync: this);
    _loadPreparations();
  }

  void _loadPreparations() {
    // Load existing preparations from backend
    // For now, initialize empty
    for (var map in _maps) {
      if (!_preparations.containsKey(map['id'])) {
        _preparations[map['id']] = MapPreparation(
          mapId: map['id'] as String,
          mapName: map['name'] as String,
          notes: '',
          predictedAdvantage: 'EVEN_MATCH',
          confidence: 0,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _overallNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preparation: ${widget.opponentName}"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _maps.map((map) => Tab(text: map['name'] as String)).toList(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _maps.map((map) {
                final preparation = _preparations[map['id']]!;
                return MapPreparationCard(
                  preparation: preparation,
                  teamId: widget.teamId,
                  opponentId: widget.opponentId,
                  onUpdated: (updated) {
                    setState(() {
                      _preparations[map['id']] = updated;
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

