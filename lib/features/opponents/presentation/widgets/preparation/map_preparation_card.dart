import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../infrastructure/datasources/opponent_remote_data_source.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../../core/network/api_client.dart';
import '../../../domain/entities/map_preparation.dart';

class MapPreparationCard extends StatefulWidget {
  final MapPreparation preparation;
  final String teamId;
  final String opponentId;
  final ValueChanged<MapPreparation> onUpdated;

  const MapPreparationCard({
    super.key,
    required this.preparation,
    required this.teamId,
    required this.opponentId,
    required this.onUpdated,
  });

  @override
  State<MapPreparationCard> createState() => _MapPreparationCardState();
}

class _MapPreparationCardState extends State<MapPreparationCard> {
  late TextEditingController _notesController;
  final OpponentRemoteDataSource _dataSource = OpponentRemoteDataSource(getIt<ApiClient>());
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.preparation.notes);
    _loadMatchupData();
  }

  Future<void> _loadMatchupData() async {
    setState(() => _loading = true);
    try {
      final matchupData = await _dataSource.getMapMatchup(
        widget.teamId,
        widget.opponentId,
        widget.preparation.mapId,
      );

      final updated = widget.preparation.copyWith(
        predictedAdvantage: matchupData['predictedAdvantage'] as String? ?? 'EVEN_MATCH',
        confidence: 75, // Confidence would come from backend
      );

      widget.onUpdated(updated);
    } catch (e) {
      // Ignore errors - use default values
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _confidenceColor(int confidence) {
    if (confidence > 75) return Colors.green;
    if (confidence > 50) return Colors.orange;
    return Colors.redAccent;
  }

  String _formatAdvantage(String advantage) {
    return advantage
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        color: Colors.grey.shade800,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.preparation.mapName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Chip(
                    label: Text(
                      "${widget.preparation.confidence}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: _confidenceColor(widget.preparation.confidence),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Predicted Advantage: ${_formatAdvantage(widget.preparation.predictedAdvantage)}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Game Plan Notes",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: "Enter map-specific preparation notes...",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  final updated = widget.preparation.copyWith(notes: value);
                  widget.onUpdated(updated);
                  // Save to backend (debounced in production)
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



