import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/round_draft.dart';

class DraftLocalDataSource {
  static const String _draftPrefix = 'draft_';

  Future<void> saveDraft(RoundDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_draftPrefix${draft.roundId}';
    await prefs.setString(key, jsonEncode(draft.toJson()));
  }

  Future<RoundDraft?> getDraft(String roundId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_draftPrefix$roundId';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return RoundDraft.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteDraft(String roundId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_draftPrefix$roundId';
    await prefs.remove(key);
  }

  Future<List<String>> getAllDraftRoundIds() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys
        .where((key) => key.startsWith(_draftPrefix))
        .map((key) => key.substring(_draftPrefix.length))
        .toList();
  }
}


