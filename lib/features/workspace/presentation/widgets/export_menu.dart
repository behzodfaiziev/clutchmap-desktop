import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/notifications/toast_service.dart';
import '../../infrastructure/services/export_service.dart';
import '../../infrastructure/datasources/share_remote_data_source.dart';
import '../bloc/workspace_state.dart';

class ExportMenu extends StatelessWidget {
  final WorkspaceLoadedState state;
  final GlobalKey? canvasKey;
  final ShareRemoteDataSource shareDataSource;
  final ExportService exportService;

  const ExportMenu({
    super.key,
    required this.state,
    this.canvasKey,
    required this.shareDataSource,
    required this.exportService,
  });

  Future<void> _handleExportAction(String action, BuildContext context) async {
    switch (action) {
      case "export_match":
        await _exportMatch(context);
        break;
      case "export_round":
        await _exportRound(context);
        break;
      case "share":
        await _generateShareLink(context);
        break;
    }
  }

  Future<void> _exportMatch(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await exportService.exportMatchToPdf(
        match: state.match,
        rounds: state.rounds,
        buyTypes: state.buyTypes,
      );
      
      if (context.mounted) {
        Navigator.of(context).pop();
        ToastService.showSuccess(context, 'Match exported successfully');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ToastService.showError(context, 'Failed to export match: $e');
      }
    }
  }

  Future<void> _exportRound(BuildContext context) async {
    if (state.rounds.isEmpty) {
      ToastService.showError(context, 'No round selected');
      return;
    }

    final currentRound = state.rounds[state.selectedIndex];
    final buyType = state.buyTypes[currentRound.id];

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      Uint8List? canvasImage;
      if (canvasKey != null) {
        try {
          canvasImage = await exportService.captureCanvas(canvasKey!);
        } catch (e) {
          // Canvas capture failed, continue without image
        }
      }

      await exportService.exportRoundToPdf(
        round: currentRound,
        canvasImage: canvasImage,
        mapName: state.match.mapName ?? 'N/A',
        buyType: buyType,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        ToastService.showSuccess(context, 'Round exported successfully');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ToastService.showError(context, 'Failed to export round: $e');
      }
    }
  }

  Future<void> _generateShareLink(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final response = await shareDataSource.createShare(state.match.id);
      final token = response['token'] as String?;
      final shareUrl = response['shareUrl'] as String?;
      
      if (context.mounted) {
        Navigator.of(context).pop();
        
        final finalUrl = shareUrl ?? (token != null ? "http://localhost:8080/public/v1/match/$token" : null);
        if (finalUrl != null) {
          _showShareDialog(context, finalUrl);
        } else {
          ToastService.showError(context, 'Failed to generate share link');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ToastService.showError(context, 'Failed to generate share link: $e');
      }
    }
  }

  void _showShareDialog(BuildContext context, String shareUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Share Link"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(shareUrl),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: shareUrl));
                ToastService.showSuccess(context, 'Link copied to clipboard');
              },
              icon: const Icon(Icons.copy),
              label: const Text("Copy Link"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: "export_match",
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 20),
              SizedBox(width: 8),
              Text("Export Match (PDF)"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: "export_round",
          child: Row(
            children: [
              Icon(Icons.image, size: 20),
              SizedBox(width: 8),
              Text("Export Current Round"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: "share",
          child: Row(
            children: [
              Icon(Icons.share, size: 20),
              SizedBox(width: 8),
              Text("Generate Share Link"),
            ],
          ),
        ),
      ],
      onSelected: (value) => _handleExportAction(value, context),
    );
  }
}

