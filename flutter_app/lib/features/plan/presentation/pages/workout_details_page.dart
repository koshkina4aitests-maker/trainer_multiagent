import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/plan.dart';
import '../bloc/plan_bloc.dart';
import '../../../workout/presentation/bloc/workout_bloc.dart';
import '../../../workout/presentation/bloc/workout_event.dart';
import '../../../workout/presentation/bloc/workout_state.dart';

class WorkoutDetailsPage extends StatelessWidget {
  final PlannedWorkout workout;

  const WorkoutDetailsPage({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkoutBloc, WorkoutState>(
      listener: (context, state) {
        if (state is WorkoutInProgress) {
          context.push('/workout/active');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: Text(workout.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Редактировать',
              onPressed: () => _showEditSheet(context, workout),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                icon: Icons.calendar_today,
                text: AppDateUtils.formatDate(workout.scheduledDate),
              ),
              const SizedBox(height: 16),
              if (workout.recommendationReason != null) ...[
                AppCard(
                  color: AppColors.successLight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Почему эта тренировка?', style: AppTextStyles.h4),
                            const SizedBox(height: 4),
                            Text(workout.recommendationReason!,
                                style: AppTextStyles.body.copyWith(color: AppColors.text)),
                            if (workout.intensityLabel != null) ...[
                              const SizedBox(height: 8),
                              _IntensityChip(
                                label: workout.intensityLabel!,
                                reason: workout.intensityReasonShort,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text('Упражнения', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              if (workout.exerciseNames.isEmpty)
                Text('Список упражнений не задан',
                    style: AppTextStyles.body.copyWith(color: AppColors.muted))
              else
                ...workout.normalizedDetails.asMap().entries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text('${e.key + 1}',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.primary)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${e.value.exerciseName} · ${e.value.sets}x${e.value.reps} · '
                              '${e.value.weightKg.toStringAsFixed(1)} кг · RIR ${e.value.rir}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: 32),
              _DisclaimerCard(),
              const SizedBox(height: 24),
              BlocBuilder<WorkoutBloc, WorkoutState>(
                builder: (context, state) {
                  return AppButton(
                    label: 'Начать тренировку',
                    loading: state is WorkoutLoading,
                    onPressed: workout.completed
                        ? null
                        : () {
                            final details = workout.normalizedDetails;
                            context.read<WorkoutBloc>().add(
                                  WorkoutStartRequested(
                                    workout.name,
                                    details.map((d) => d.exerciseId).toList(),
                                    details.map((d) => d.exerciseName).toList(),
                                  ),
                                );
                          },
                  );
                },
              ),
              if (workout.completed) ...[
                const SizedBox(height: 8),
                const Center(
                  child: Text('Тренировка уже выполнена',
                      style: AppTextStyles.caption),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IntensityChip extends StatelessWidget {
  final String label;
  final String? reason;

  const _IntensityChip({required this.label, this.reason});

  Color _chipColor() {
    switch (label) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'hard':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFFFF9800);
    }
  }

  String _chipText() {
    switch (label) {
      case 'easy':
        return 'Лёгкая';
      case 'hard':
        return 'Высокая';
      default:
        return 'Умеренная';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _chipColor().withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _chipColor().withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: _chipColor(), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Интенсивность: ${_chipText()}',
                    style: TextStyle(
                      fontSize: 13,
                      height: 18 / 13,
                      color: _chipColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (reason != null && reason!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            reason!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 18 / 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.muted, size: 18),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.body.copyWith(color: AppColors.muted)),
      ],
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.health_and_safety_outlined,
              color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Не является медицинской консультацией. При наличии ограничений проконсультируйтесь с врачом.',
              style: AppTextStyles.caption.copyWith(color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

void _showEditSheet(BuildContext context, PlannedWorkout workout) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<PlanBloc>(),
      child: _EditWorkoutSheet(workout: workout),
    ),
  );
}

class _EditWorkoutSheet extends StatefulWidget {
  final PlannedWorkout workout;
  const _EditWorkoutSheet({required this.workout});

  @override
  State<_EditWorkoutSheet> createState() => _EditWorkoutSheetState();
}

class _EditWorkoutSheetState extends State<_EditWorkoutSheet> {
  late final TextEditingController _titleCtrl = TextEditingController(text: widget.workout.name);
  late final List<PlannedExerciseDetail> _items = widget.workout.normalizedDetails.isNotEmpty
      ? widget.workout.normalizedDetails
          .map((e) => PlannedExerciseDetail(
                exerciseId: e.exerciseId,
                exerciseName: e.exerciseName,
                sets: e.sets,
                reps: e.reps,
                weightKg: e.weightKg,
                rir: e.rir,
              ))
          .toList()
      : widget.workout.exerciseNames
          .map((name) => PlannedExerciseDetail(
                exerciseId: name,
                exerciseName: name,
                sets: 3,
                reps: 10,
                weightKg: 20,
                rir: 2,
              ))
          .toList();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Редактировать тренировку', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 16),
            ..._items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.exerciseName, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _NumField(
                            label: 'Подх',
                            initial: item.sets,
                            onChanged: (v) => _items[i] = item.copyWith(sets: v as int),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _NumField(
                            label: 'Повт',
                            initial: item.reps,
                            onChanged: (v) => _items[i] = item.copyWith(reps: v as int),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _NumField(
                            label: 'Вес',
                            initial: item.weightKg,
                            onChanged: (v) => _items[i] = item.copyWith(weightKg: v as double),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _NumField(
                            label: 'RIR',
                            initial: item.rir,
                            onChanged: (v) => _items[i] = item.copyWith(rir: v as int),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            AppButton(
              label: 'Сохранить',
              onPressed: () {
                context.read<PlanBloc>().add(
                      PlanWorkoutUpdated(
                        widget.workout.copyWith(
                          name: _titleCtrl.text.trim().isEmpty ? widget.workout.name : _titleCtrl.text.trim(),
                          exerciseDetails: _items,
                          exerciseNames: _items.map((e) => e.exerciseName).toList(),
                        ),
                      ),
                    );
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final String label;
  final num initial;
  final ValueChanged<num> onChanged;
  const _NumField({required this.label, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: '$initial');
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) {
        if (initial is int) {
          onChanged(int.tryParse(v) ?? initial);
        } else {
          onChanged(double.tryParse(v.replaceAll(',', '.')) ?? initial);
        }
      },
    );
  }
}
