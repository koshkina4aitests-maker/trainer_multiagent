import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/exercise.dart';

class ExerciseLocalDatasource {
  final SharedPreferences _prefs;
  static const String _key = 'exercises_list';

  ExerciseLocalDatasource(this._prefs);

  Future<List<Exercise>> getAll() async {
    final raw = _prefs.getStringList(_key);
    if (raw == null) return _defaultExercises();
    final custom = raw.map((e) => Exercise.fromJson(jsonDecode(e))).toList();
    return [..._defaultExercises(), ...custom];
  }

  Future<void> save(Exercise exercise) async {
    final raw = _prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(exercise.toJson()));
    await _prefs.setStringList(_key, raw);
  }

  Future<void> delete(String id) async {
    final raw = _prefs.getStringList(_key) ?? [];
    final updated = raw.where((e) {
      final ex = Exercise.fromJson(jsonDecode(e));
      return ex.id != id;
    }).toList();
    await _prefs.setStringList(_key, updated);
  }

  List<Exercise> _defaultExercises() => [
        const Exercise(
          id: 'ex-1',
          name: 'Жим штанги лёжа',
          description: 'Базовое упражнение для грудных мышц',
          muscleGroup: 'Грудь',
          equipment: 'Штанга',
        ),
        const Exercise(
          id: 'ex-2',
          name: 'Приседания со штангой',
          description: 'Базовое упражнение для ног',
          muscleGroup: 'Ноги',
          equipment: 'Штанга',
          healthRestrictions: ['Боль в коленях'],
        ),
        const Exercise(
          id: 'ex-3',
          name: 'Становая тяга',
          description: 'Базовое упражнение для спины и ног',
          muscleGroup: 'Спина',
          equipment: 'Штанга',
          healthRestrictions: ['Боль в спине'],
        ),
        const Exercise(
          id: 'ex-4',
          name: 'Подтягивания',
          description: 'Упражнение для широчайших мышц спины',
          muscleGroup: 'Спина',
          equipment: 'Турник',
        ),
        const Exercise(
          id: 'ex-5',
          name: 'Жим гантелей сидя',
          description: 'Упражнение для дельтовидных мышц',
          muscleGroup: 'Плечи',
          equipment: 'Гантели',
        ),
        const Exercise(
          id: 'ex-6',
          name: 'Сгибание рук с гантелями',
          description: 'Изолирующее упражнение для бицепса',
          muscleGroup: 'Руки',
          equipment: 'Гантели',
        ),
        const Exercise(
          id: 'ex-7',
          name: 'Разгибание рук на блоке',
          description: 'Изолирующее упражнение для трицепса',
          muscleGroup: 'Руки',
          equipment: 'Блок',
        ),
        const Exercise(
          id: 'ex-8',
          name: 'Планка',
          description: 'Статическое упражнение для кора',
          muscleGroup: 'Пресс',
          equipment: 'Без оборудования',
        ),
        const Exercise(
          id: 'ex-9',
          name: 'Скручивания',
          description: 'Упражнение для прямых мышц живота',
          muscleGroup: 'Пресс',
          equipment: 'Без оборудования',
          healthRestrictions: ['Боль в спине'],
        ),
        const Exercise(
          id: 'ex-10',
          name: 'Жим ногами',
          description: 'Упражнение для квадрицепсов',
          muscleGroup: 'Ноги',
          equipment: 'Тренажёр',
          healthRestrictions: ['Боль в коленях'],
        ),
        const Exercise(
          id: 'ex-11',
          name: 'Разведение гантелей лёжа',
          description: 'Изолирующее упражнение для грудных мышц',
          muscleGroup: 'Грудь',
          equipment: 'Гантели',
        ),
        const Exercise(
          id: 'ex-12',
          name: 'Тяга горизонтального блока',
          description: 'Упражнение для средней части спины',
          muscleGroup: 'Спина',
          equipment: 'Блок',
        ),
      ];
}
