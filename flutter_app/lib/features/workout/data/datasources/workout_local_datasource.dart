import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/workout_session.dart';

class WorkoutLocalDatasource {
  final SharedPreferences _prefs;
  static const String _historyKey = 'workout_history';
  static const String _draftKey = 'workout_draft';

  WorkoutLocalDatasource(this._prefs);

  Future<List<WorkoutSession>> getHistory() async {
    final raw = _prefs.getStringList(_historyKey) ?? [];
    return raw.map((e) => WorkoutSession.fromJson(jsonDecode(e))).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  Future<void> saveToHistory(WorkoutSession session) async {
    final raw = _prefs.getStringList(_historyKey) ?? [];
    final updated = raw.where((e) {
      final s = WorkoutSession.fromJson(jsonDecode(e));
      return s.id != session.id;
    }).toList();
    updated.add(jsonEncode(session.toJson()));
    await _prefs.setStringList(_historyKey, updated);
  }

  Future<WorkoutSession?> getDraft() async {
    final raw = _prefs.getString(_draftKey);
    if (raw == null) return null;
    return WorkoutSession.fromJson(jsonDecode(raw));
  }

  Future<void> saveDraft(WorkoutSession session) async {
    await _prefs.setString(_draftKey, jsonEncode(session.toJson()));
  }

  Future<void> clearDraft() async {
    await _prefs.remove(_draftKey);
  }
}
