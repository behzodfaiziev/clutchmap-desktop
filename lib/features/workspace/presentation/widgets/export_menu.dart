import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/backend_error_helper.dart';
import '../../../../core/notifications/toast_service.dart';
import '../../infrastructure/services/export_service.dart';
import '../../infrastructure/datasources/share_remote_data_source.dart';
import '../../infrastructure/datasources/export_remote_data_source.dart';
import '../bloc/workspace_state.dart';
import 'dialogs/share_tactic_modal.dart';

class ExportMenu extends StatelessWidget {
  final WorkspaceLoadedState state;
  final GlobalKey? canvasKey;
  final ShareRemoteDataSource shareDataSource;
  final ExportRemoteDataSource exportDataSource;
  final ExportService exportService;

  const ExportMenu({
    super.key,
    required this.state,
    this.canvasKey,
    required this.shareDataSource,
    required this.exportDataSource,
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
      case "download_pdf_server":
        await _downloadPdfFromServer(context);
        break;
      case "share":
        await _generateShareLink(context);
        break;
      case "fullscreen":
        context.push('/overlay/${state.match.id}');
        break;
    }
  }

  Future<void> _downloadPdfFromServer(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      final bytes = await exportDataSource.getMatchPdf(state.match.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        await Printing.sharePdf(bytes: bytes, filename: 'match-${state.match.id}.pdf');
        if (context.mounted) {
          ToastService.showSuccess(context, 'PDF downloaded from server');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ToastService.showError(
          context,
          messageFromException(e, fallback: 'Failed to download PDF from server'),
        );
      }
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
        ToastService.showError(context, messageFromException(e, fallback: 'Failed to export match'));
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
        ToastService.showError(context, messageFromException(e, fallback: 'Failed to export round'));
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
        
        final finalUrl = shareUrl ?? (token != null ? '${ApiConfig.publicRootUrl}/public/v1/match/$token' : null);
        if (finalUrl != null) {
          ShareTacticModal.show(context, shareUrl: finalUrl);
        } else {
          ToastService.showError(context, 'Failed to generate share link');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ToastService.showError(context, messageFromException(e, fallback: 'Failed to generate share link'));
      }
    }
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
          value: "download_pdf_server",
          child: Row(
            children: [
              Icon(Icons.download, size: 20),
              SizedBox(width: 8),
              Text("Download PDF from server"),
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
        const PopupMenuItem(
          value: "fullscreen",
          child: Row(
            children: [
              Icon(Icons.fullscreen, size: 20),
              SizedBox(width: 8),
              Text("Fullscreen Review"),
            ],
          ),
        ),
      ],
      onSelected: (value) => _handleExportAction(value, context),
    );
  }
}

