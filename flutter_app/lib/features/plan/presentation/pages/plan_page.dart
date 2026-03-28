import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/plan.dart';
import '../bloc/plan_bloc.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  DateTime _weekStart = _mondayOf(DateTime.now());

  static DateTime _mondayOf(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));

  @override
  void initState() {
    super.initState();
    context.read<PlanBloc>().add(PlanWeekLoaded(_weekStart));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('План тренировок'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWorkoutDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _WeekNavigator(
            weekStart: _weekStart,
            onPrev: () {
              setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
              context.read<PlanBloc>().add(PlanWeekLoaded(_weekStart));
            },
            onNext: () {
              setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
              context.read<PlanBloc>().add(PlanWeekLoaded(_weekStart));
            },
          ),
          Expanded(
            child: BlocBuilder<PlanBloc, PlanState>(
              builder: (context, state) {
                if (state is PlanLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PlanLoaded) {
                  return _buildWeekView(context, state);
                }
                return const EmptyStateWidget(
                  icon: Icons.calendar_today,
                  title: 'Нет тренировок',
                  subtitle: 'Добавьте первую тренировку в план',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, PlanLoaded state) {
    final weekDays = AppDateUtils.weekDays(_weekStart);
    if (state.weekPlan.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.calendar_today_outlined,
        title: 'На этой неделе пусто',
        subtitle: 'Добавьте тренировки в план',
        actionLabel: 'Добавить тренировку',
        onAction: () => _showAddWorkoutDialog(context),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: weekDays.map((day) {
        final dayWorkouts = state.weekPlan.where((w) {
          final d = w.scheduledDate;
          return d.year == day.year && d.month == day.month && d.day == day.day;
        }).toList();
        return _DaySection(day: day, workouts: dayWorkouts);
      }).toList(),
    );
  }

  void _showAddWorkoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PlanBloc>(),
        child: _AddWorkoutSheet(initialDate: _weekStart),
      ),
    );
  }
}

class _WeekNavigator extends StatelessWidget {
  final DateTime weekStart;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _WeekNavigator({
    required this.weekStart,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          Text(
            '${AppDateUtils.formatDate(weekStart)} – ${AppDateUtils.formatDate(weekEnd)}',
            style: AppTextStyles.bodyMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<PlannedWorkout> workouts;

  const _DaySection({required this.day, required this.workouts});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday =
        day.year == today.year && day.month == today.month && day.day == today.day;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : AppColors.bg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isToday ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  '${AppDateUtils.weekDayShort(day.weekday)}, ${day.day}',
                  style: AppTextStyles.label.copyWith(
                    color: isToday ? AppColors.white : AppColors.muted,
                  ),
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Text('Сегодня',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (workouts.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Отдых',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
            )
          else
            ...workouts.map((w) => _WorkoutChip(workout: w)),
        ],
      ),
    );
  }
}

class _WorkoutChip extends StatelessWidget {
  final PlannedWorkout workout;

  const _WorkoutChip({required this.workout});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/plan/${workout.id}', extra: workout),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: workout.completed ? AppColors.successLight : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              workout.completed ? Icons.check_circle : Icons.fitness_center,
              color: workout.completed ? AppColors.success : AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.name, style: AppTextStyles.bodyMedium),
                  if (workout.exerciseNames.isNotEmpty)
                    Text(
                      workout.exerciseNames.take(2).join(', '),
                      style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _AddWorkoutSheet extends StatefulWidget {
  final DateTime initialDate;
  const _AddWorkoutSheet({required this.initialDate});

  @override
  State<_AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<_AddWorkoutSheet> {
  final _nameCtrl = TextEditingController();
  late DateTime _selectedDate;
  final _exercises = <String>[''];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Добавить тренировку', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 16),
            Text('Дата', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppColors.muted, size: 18),
                    const SizedBox(width: 8),
                    Text(AppDateUtils.formatDate(_selectedDate),
                        style: AppTextStyles.body),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Упражнения', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            ..._exercises.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    initialValue: e.value,
                    decoration: InputDecoration(
                      labelText: 'Упражнение ${e.key + 1}',
                    ),
                    onChanged: (v) => _exercises[e.key] = v,
                  ),
                )),
            TextButton.icon(
              onPressed: () => setState(() => _exercises.add('')),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Добавить упражнение'),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Сохранить',
              onPressed: () {
                if (_nameCtrl.text.isEmpty) return;
                context.read<PlanBloc>().add(PlanWorkoutAdded(PlannedWorkout(
                  id: '',
                  name: _nameCtrl.text,
                  scheduledDate: _selectedDate,
                  exerciseNames: _exercises.where((e) => e.isNotEmpty).toList(),
                )));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
