import 'dart:typed_data';

import '../../../../core/network/api_client.dart';

/// Backend export endpoints (e.g. GET /export/match/{id}/pdf).
class ExportRemoteDataSource {
  final ApiClient api;

  ExportRemoteDataSource(this.api);

  /// Fetches match PDF from backend. GET /api/v1/export/match/{matchId}/pdf.
  Future<Uint8List> getMatchPdf(String matchId) async {
    return api.getBytes('/export/match/$matchId/pdf');
  }
}
