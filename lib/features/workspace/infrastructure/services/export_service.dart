import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/match_detail.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/entities/buy_type.dart';
import '../../presentation/bloc/workspace_state.dart';

class ExportService {
  Future<void> exportMatchToPdf({
    required MatchDetail match,
    required List<RoundEntity> rounds,
    required Map<String, BuyType?> buyTypes,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "Match Plan",
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text("Map: ${match.mapName ?? 'N/A'}"),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 12),
          ...rounds.map(
            (round) {
              final buyType = buyTypes[round.id];
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Round ${round.roundNumber}",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text("Side: ${round.side}"),
                    if (buyType != null)
                      pw.Text("Economy: ${buyType.name}"),
                    if (round.notes != null && round.notes!.isNotEmpty) ...[
                      pw.SizedBox(height: 8),
                      pw.Text("Notes:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(round.notes!),
                    ],
                    pw.SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<void> exportRoundToPdf({
    required RoundEntity round,
    required Uint8List? canvasImage,
    required String mapName,
    BuyType? buyType,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Text(
                "Round ${round.roundNumber}",
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text("Map: $mapName"),
            pw.Text("Side: ${round.side}"),
            if (buyType != null)
              pw.Text("Economy: ${buyType.name}"),
            pw.SizedBox(height: 16),
          ];

          if (round.notes != null && round.notes!.isNotEmpty) {
            widgets.addAll([
              pw.Text("Notes:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(round.notes!),
              pw.SizedBox(height: 16),
            ]);
          }

          if (canvasImage != null) {
            widgets.addAll([
              pw.Text("Strategy:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Image(
                pw.MemoryImage(canvasImage),
                fit: pw.BoxFit.contain,
              ),
            ]);
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: widgets,
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<Uint8List> captureCanvas(GlobalKey canvasKey) async {
    final boundary = canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

