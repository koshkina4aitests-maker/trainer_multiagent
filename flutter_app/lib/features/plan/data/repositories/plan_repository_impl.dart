import 'package:uuid/uuid.dart';
import '../../domain/entities/plan.dart';
import '../../domain/repositories/plan_repository.dart';
import '../datasources/plan_local_datasource.dart';
import '../../../../core/storage/local_storage.dart';

class PlanRepositoryImpl implements PlanRepository {
  final PlanLocalDatasource _local;
  final LocalStorage _storage;
  final _uuid = const Uuid();

  PlanRepositoryImpl(this._local, this._storage);

  @override
  Future<List<PlannedWorkout>> getWeekPlan(DateTime weekStart) async {
    final all = await _local.getAll();
    final weekEnd = weekStart.add(const Duration(days: 7));
    return all.where((w) {
      final d = w.scheduledDate;
      return !d.isBefore(weekStart) && d.isBefore(weekEnd);
    }).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<PlannedWorkout> addPlannedWorkout(PlannedWorkout workout) async {
    final w = PlannedWorkout(
      id: workout.id.isEmpty ? _uuid.v4() : workout.id,
      name: workout.name,
      scheduledDate: workout.scheduledDate,
      exerciseNames: workout.exerciseNames,
      exerciseDetails: workout.exerciseDetails,
      recommendationReason: workout.recommendationReason,
      intensityLabel: workout.intensityLabel,
      intensityReasonShort: workout.intensityReasonShort,
    );
    await _local.save(w);
    return w;
  }

  @override
  Future<void> deletePlannedWorkout(String id) => _local.delete(id);

  @override
  Future<PlannedWorkout> markCompleted(String id) async {
    final all = await _local.getAll();
    final w = all.firstWhere((w) => w.id == id);
    final updated = w.copyWith(completed: true);
    await _local.save(updated);
    return updated;
  }

  @override
  Future<PlannedWorkout?> getTodayRecommendation({
    RecommendationStyle? style,
    ReadinessData? readiness,
  }) async {
    final goal = _storage.userGoal ?? 'Здоровье';
    final healthLimits = _storage.healthLimits;
    final recommendationStyle = style ?? RecommendationStyle.fullbody;

    String reason;
    List<PlannedExerciseDetail> exerciseDetails;

    String intensityLabel;
    String intensityReasonShort;

    if (readiness != null) {
      if (readiness.fatigue > 7 || readiness.soreness > 7) {
        reason = 'Высокая усталость — рекомендуется восстановительная тренировка';
        exerciseDetails = _toDetails([
          'Лёгкое кардио',
          'Стретчинг',
          'Дыхательные упражнения',
        ]);
        intensityLabel = 'easy';
        intensityReasonShort = 'Снижена из-за высокого уровня усталости или болезненности мышц.';
      } else if (readiness.sleepQuality < 4) {
        reason = 'Недостаточный сон — рекомендована тренировка низкой интенсивности';
        exerciseDetails = _toDetails(['Ходьба', 'Мобильность суставов', 'Планка']);
        intensityLabel = 'easy';
        intensityReasonShort = 'Снижена из-за недостаточного качества сна.';
      } else {
        reason = _buildReasonByGoal(goal, healthLimits, recommendationStyle);
        exerciseDetails = _buildExercisesByGoal(goal, healthLimits, recommendationStyle);
        intensityLabel = _intensityByGoal(goal, readiness);
        intensityReasonShort = _intensityReasonByGoal(goal, readiness);
      }
    } else {
      reason = _buildReasonByGoal(goal, healthLimits, recommendationStyle);
      exerciseDetails = _buildExercisesByGoal(goal, healthLimits, recommendationStyle);
      intensityLabel = 'moderate';
      intensityReasonShort = 'Стандартная нагрузка по вашему профилю и целям.';
    }

    return PlannedWorkout(
      id: _uuid.v4(),
      name: _nameByGoal(goal, recommendationStyle),
      scheduledDate: DateTime.now(),
      exerciseNames: exerciseDetails.map((e) => e.exerciseName).toList(),
      exerciseDetails: exerciseDetails,
      recommendationReason: reason,
      intensityLabel: intensityLabel,
      intensityReasonShort: intensityReasonShort,
    );
  }

  String _nameByGoal(String goal, RecommendationStyle style) {
    if (style == RecommendationStyle.splitUpper) return 'Split: Верх тела';
    if (style == RecommendationStyle.splitLower) return 'Split: Низ тела';
    switch (goal) {
      case 'Похудение':
        return 'Кардио-тренировка';
      case 'Сила':
        return 'Силовая тренировка';
      case 'Выносливость':
        return 'Тренировка на выносливость';
      default:
        return 'Оздоровительная тренировка';
    }
  }

  String _buildReasonByGoal(
    String goal,
    List<String> healthLimits,
    RecommendationStyle style,
  ) {
    final limitNote = healthLimits.isNotEmpty
        ? ' Учтены ограничения: ${healthLimits.join(", ")}.'
        : '';
    final styleNote = switch (style) {
      RecommendationStyle.fullbody => ' Формат: fullbody.',
      RecommendationStyle.splitUpper => ' Формат: split верх.',
      RecommendationStyle.splitLower => ' Формат: split низ.',
    };
    switch (goal) {
      case 'Похудение':
        return 'На основе вашей цели "Похудение" и истории тренировок рекомендована кардио-нагрузка.$limitNote$styleNote';
      case 'Сила':
        return 'На основе вашей цели "Сила" рекомендована силовая тренировка с прогрессией нагрузки.$limitNote$styleNote';
      case 'Выносливость':
        return 'На основе цели "Выносливость" рекомендована тренировка с умеренной интенсивностью.$limitNote$styleNote';
      default:
        return 'На основе вашего профиля и истории тренировок рекомендована сбалансированная тренировка.$limitNote$styleNote';
    }
  }

  String _intensityByGoal(String goal, ReadinessData readiness) {
    if (goal == 'Сила' && readiness.fatigue <= 4) return 'hard';
    if (goal == 'Похудение') return 'moderate';
    return 'moderate';
  }

  String _intensityReasonByGoal(String goal, ReadinessData readiness) {
    if (goal == 'Сила' && readiness.fatigue <= 4) {
      return 'Хорошая готовность — можно работать с повышенной нагрузкой.';
    }
    return 'Умеренная нагрузка соответствует вашей цели и текущей готовности.';
  }

  List<PlannedExerciseDetail> _buildExercisesByGoal(
    String goal,
    List<String> healthLimits,
    RecommendationStyle style,
  ) {
    final hasBackPain = healthLimits.contains('Боль в спине');
    final hasKneePain = healthLimits.contains('Боль в коленях');
    final names = switch (style) {
      RecommendationStyle.splitUpper => <String>[
          'Жим штанги лёжа',
          'Подтягивания',
          'Жим гантелей сидя',
          'Сгибание рук с гантелями',
        ],
      RecommendationStyle.splitLower => <String>[
          hasKneePain ? 'Жим ногами' : 'Приседания',
          hasBackPain ? 'Жим ногами' : 'Становая тяга',
          'Выпады',
          'Подъёмы на носки',
        ],
      RecommendationStyle.fullbody => switch (goal) {
          'Похудение' => <String>[
              'Эллипсоид',
              'Велотренажёр',
              hasKneePain ? 'Плавание' : 'Бег',
              'Берпи',
            ],
          'Сила' => <String>[
              'Жим штанги лёжа',
              hasBackPain ? 'Жим ногами' : 'Становая тяга',
              hasKneePain ? 'Жим ногами' : 'Приседания',
              'Подтягивания',
            ],
          'Выносливость' => <String>['Бег на дорожке', 'Гребной тренажёр', 'Скакалка', 'Планка'],
          _ => <String>[
              hasBackPain ? 'Тяга горизонтального блока' : 'Становая тяга',
              hasKneePain ? 'Жим ногами' : 'Приседания',
              'Жим штанги лёжа',
              'Планка',
            ],
        },
    };
    return _toDetails(names);
  }

  List<PlannedExerciseDetail> _toDetails(List<String> names) {
    return names
        .map(
          (name) => PlannedExerciseDetail(
            exerciseId: _resolveExerciseId(name),
            exerciseName: name,
            sets: 3,
            reps: 10,
            weightKg: _defaultWeight(name),
            rir: 2,
          ),
        )
        .toList();
  }

  String _resolveExerciseId(String name) {
    // Keep IDs stable for known defaults; fallback stays deterministic.
    final slug = name.toLowerCase().replaceAll(' ', '-');
    return 'rec-$slug';
  }

  double _defaultWeight(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('бег') || lower.contains('кардио') || lower.contains('скакалка')) {
      return 0;
    }
    if (lower.contains('планка') || lower.contains('стретчинг')) return 0;
    if (lower.contains('жим') || lower.contains('тяга') || lower.contains('присед')) {
      return 30;
    }
    return 20;
  }
}
