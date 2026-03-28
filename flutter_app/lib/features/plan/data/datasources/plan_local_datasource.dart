import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/plan.dart';

class PlanLocalDatasource {
  final SharedPreferences _prefs;
  static const String _key = 'planned_workouts';

  PlanLocalDatasource(this._prefs);

  Future<List<PlannedWorkout>> getAll() async {
    final raw = _prefs.getStringList(_key) ?? [];
    return raw.map((e) => PlannedWorkout.fromJson(jsonDecode(e))).toList();
  }

  Future<void> save(PlannedWorkout workout) async {
    final all = await getAll();
    final updated = all.where((w) => w.id != workout.id).toList()..add(workout);
    await _saveAll(updated);
  }

  Future<void> delete(String id) async {
    final all = await getAll();
    await _saveAll(all.where((w) => w.id != id).toList());
  }

  Future<void> _saveAll(List<PlannedWorkout> list) async {
    await _prefs.setStringList(_key, list.map((w) => jsonEncode(w.toJson())).toList());
  }
}
