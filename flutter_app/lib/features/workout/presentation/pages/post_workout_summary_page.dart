import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../bloc/workout_bloc.dart';
import '../bloc/workout_state.dart';

class PostWorkoutSummaryPage extends StatelessWidget {
  const PostWorkoutSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      builder: (context, state) {
        if (state is! WorkoutFinished) {
          return Scaffold(
            appBar: AppBar(title: const Text('Итог тренировки')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final session = state.session;
        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            title: const Text('Тренировка завершена!'),
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _CelebrationBanner(),
                    const SizedBox(height: 24),
                    _StatCards(session: state.session),
                    const SizedBox(height: 24),
                    Text('Упражнения', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    ...session.exercises
                        .where((e) => e.sets.isNotEmpty)
                        .map((e) => _ExerciseSummaryCard(log: e)),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'На главную',
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Посмотреть прогресс',
                      style: AppButtonStyle.secondary,
                      onPressed: () => context.go('/home/progress'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CelebrationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
          const SizedBox(height: 12),
          Text('Отличная работа!',
              style: AppTextStyles.h2.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text('Тренировка успешно записана',
              style: AppTextStyles.body.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _StatCards extends StatelessWidget {
  final dynamic session;
  const _StatCards({required this.session});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.primary, size: 24),
                const SizedBox(height: 4),
                Text(AppDateUtils.formatDurationHM(session.duration),
                    style: AppTextStyles.h4),
                Text('Длительность', style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Icon(Icons.fitness_center, color: AppColors.warning, size: 24),
                const SizedBox(height: 4),
                Text('${session.totalSets}', style: AppTextStyles.h4),
                Text('Подходов', style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Icon(Icons.bar_chart, color: AppColors.success, size: 24),
                const SizedBox(height: 4),
                Text('${session.totalVolume.toStringAsFixed(0)}',
                    style: AppTextStyles.h4),
                Text('кг объём', style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseSummaryCard extends StatelessWidget {
  final dynamic log;
  const _ExerciseSummaryCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(log.exerciseName, style: AppTextStyles.h4),
          const SizedBox(height: 8),
          ...log.sets.map<Widget>((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text('Подход ${s.setNumber}: ',
                        style:
                            AppTextStyles.caption.copyWith(color: AppColors.muted)),
                    Text('${s.reps} повт × ${s.weight} кг  RIR ${s.rir}',
                        style: AppTextStyles.bodyMedium),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          Text(
            'Объём: ${log.totalVolume.toStringAsFixed(0)} кг  •  Макс. вес: ${log.maxWeight} кг',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
