import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../domain/entities/map_preparation.dart';

class ExportService {
  Future<void> exportPreparation({
    required String opponentName,
    required List<MapPreparation> preparations,
    required String overallNotes,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                "Opponent Preparation: $opponentName",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            if (overallNotes.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text("Overall Match Strategy"),
              ),
              pw.Paragraph(text: overallNotes),
              pw.SizedBox(height: 20),
            ],
            pw.Header(
              level: 1,
              child: pw.Text("Map-Specific Preparation"),
            ),
            pw.SizedBox(height: 10),
            ...preparations.map((prep) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey700),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          prep.mapName,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: pw.BoxDecoration(
                            color: _confidenceColor(prep.confidence),
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            "${prep.confidence}%",
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "Predicted Advantage: ${_formatAdvantage(prep.predictedAdvantage)}",
                      style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                    ),
                    if (prep.notes.isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "Notes:",
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        prep.notes,
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  PdfColor _confidenceColor(int confidence) {
    if (confidence > 75) return PdfColors.green;
    if (confidence > 50) return PdfColors.orange;
    return PdfColors.red;
  }

  String _formatAdvantage(String advantage) {
    return advantage
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

