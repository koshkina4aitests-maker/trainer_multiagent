import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../workout/domain/entities/workout_session.dart';

class ProgressLocalDatasource {
  final SharedPreferences _prefs;
  static const String _historyKey = 'workout_history';

  ProgressLocalDatasource(this._prefs);

  Future<List<WorkoutSession>> getHistory() async {
    final raw = _prefs.getStringList(_historyKey) ?? [];
    return raw
        .map((e) => WorkoutSession.fromJson(jsonDecode(e)))
        .where((s) => s.status == WorkoutStatus.completed)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }
}
