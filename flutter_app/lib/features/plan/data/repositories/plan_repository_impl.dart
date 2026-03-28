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
  Future<PlannedWorkout?> getTodayRecommendation({ReadinessData? readiness}) async {
    final goal = _storage.userGoal ?? 'Здоровье';
    final healthLimits = _storage.healthLimits;

    String reason;
    List<String> exercises;

    String intensityLabel;
    String intensityReasonShort;

    if (readiness != null) {
      if (readiness.fatigue > 7 || readiness.soreness > 7) {
        reason = 'Высокая усталость — рекомендуется восстановительная тренировка';
        exercises = ['Лёгкое кардио', 'Стретчинг', 'Дыхательные упражнения'];
        intensityLabel = 'easy';
        intensityReasonShort = 'Снижена из-за высокого уровня усталости или болезненности мышц.';
      } else if (readiness.sleepQuality < 4) {
        reason = 'Недостаточный сон — рекомендована тренировка низкой интенсивности';
        exercises = ['Ходьба', 'Мобильность суставов', 'Планка'];
        intensityLabel = 'easy';
        intensityReasonShort = 'Снижена из-за недостаточного качества сна.';
      } else {
        reason = _buildReasonByGoal(goal, healthLimits);
        exercises = _buildExercisesByGoal(goal, healthLimits);
        intensityLabel = _intensityByGoal(goal, readiness);
        intensityReasonShort = _intensityReasonByGoal(goal, readiness);
      }
    } else {
      reason = _buildReasonByGoal(goal, healthLimits);
      exercises = _buildExercisesByGoal(goal, healthLimits);
      intensityLabel = 'moderate';
      intensityReasonShort = 'Стандартная нагрузка по вашему профилю и целям.';
    }

    return PlannedWorkout(
      id: _uuid.v4(),
      name: _nameByGoal(goal),
      scheduledDate: DateTime.now(),
      exerciseNames: exercises,
      recommendationReason: reason,
      intensityLabel: intensityLabel,
      intensityReasonShort: intensityReasonShort,
    );
  }

  String _nameByGoal(String goal) {
    switch (goal) {
      case 'Похудение': return 'Кардио-тренировка';
      case 'Сила': return 'Силовая тренировка';
      case 'Выносливость': return 'Тренировка на выносливость';
      default: return 'Оздоровительная тренировка';
    }
  }

  String _buildReasonByGoal(String goal, List<String> healthLimits) {
    final limitNote = healthLimits.isNotEmpty
        ? ' Учтены ограничения: ${healthLimits.join(", ")}.'
        : '';
    switch (goal) {
      case 'Похудение':
        return 'На основе вашей цели "Похудение" и истории тренировок рекомендована кардио-нагрузка.$limitNote';
      case 'Сила':
        return 'На основе вашей цели "Сила" рекомендована силовая тренировка с прогрессией нагрузки.$limitNote';
      case 'Выносливость':
        return 'На основе цели "Выносливость" рекомендована тренировка с умеренной интенсивностью.$limitNote';
      default:
        return 'На основе вашего профиля и истории тренировок рекомендована сбалансированная тренировка.$limitNote';
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

  List<String> _buildExercisesByGoal(String goal, List<String> healthLimits) {
    final hasBackPain = healthLimits.contains('Боль в спине');
    final hasKneePain = healthLimits.contains('Боль в коленях');

    switch (goal) {
      case 'Похудение':
        return ['Эллипсоид', 'Велотренажёр', hasKneePain ? 'Плавание' : 'Бег', 'Берпи'];
      case 'Сила':
        return [
          'Жим штанги лёжа',
          hasBackPain ? 'Жим ногами' : 'Становая тяга',
          hasKneePain ? 'Жим ногами' : 'Приседания',
          'Подтягивания',
        ];
      case 'Выносливость':
        return ['Бег на дорожке', 'Гребной тренажёр', 'Скакалка', 'Планка'];
      default:
        return [
          hasBackPain ? 'Тяга горизонтального блока' : 'Становая тяга',
          hasKneePain ? 'Жим ногами' : 'Приседания',
          'Жим штанги лёжа',
          'Планка',
        ];
    }
  }
}
