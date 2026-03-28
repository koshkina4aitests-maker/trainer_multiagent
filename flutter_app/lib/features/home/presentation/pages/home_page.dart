import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../plan/domain/entities/plan.dart';
import '../../../plan/domain/repositories/plan_repository.dart';
import '../../../plan/presentation/bloc/plan_bloc.dart';
import '../../../workout/presentation/bloc/workout_bloc.dart';
import '../../../workout/presentation/bloc/workout_event.dart';
import '../../../workout/presentation/bloc/workout_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<PlanBloc>().add(PlanWeekLoaded(DateTime.now()));
    context.read<WorkoutBloc>().add(WorkoutDraftRestored());
  }

  @override
  Widget build(BuildContext context) {
    final storage = sl<LocalStorage>();
    final name = storage.userName ?? 'Спортсмен';
    final goal = storage.userGoal ?? 'Здоровье';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Привет, ${name.split(' ').first}!',
                      style: AppTextStyles.h3),
                  Text('Цель: $goal',
                      style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.person, size: 18, color: AppColors.primary),
                  ),
                  onPressed: () => context.go('/home/profile'),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _DraftSessionBanner(),
                  const SizedBox(height: 16),
                  _RecommendationCard(),
                  const SizedBox(height: 24),
                  _QuickStatsRow(),
                  const SizedBox(height: 24),
                  Text('Тренировки на этой неделе', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  _WeekWorkoutsSection(),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickStart(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.flash_on, color: Colors.white),
        label: Text('Быстрый старт',
            style: AppTextStyles.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showQuickStart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WorkoutBloc>(),
        child: const _QuickStartSheet(),
      ),
    );
  }
}

class _DraftSessionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      builder: (context, state) {
        if (state is WorkoutInProgress) {
          return GestureDetector(
            onTap: () => context.push('/workout/active'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_outline,
                      color: AppColors.warning, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Тренировка в процессе',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.warning)),
                        Text(state.session.name,
                            style:
                                AppTextStyles.caption.copyWith(color: AppColors.text)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.warning),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanBloc, PlanState>(
      builder: (context, state) {
        if (state is PlanLoaded && state.recommendation != null) {
          final rec = state.recommendation!;
          return AppCard(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Рекомендация',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.primary)),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showReadinessSheet(context),
                      icon: const Icon(Icons.tune, size: 16),
                      label: const Text('Обновить'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.muted,
                        textStyle: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(rec.name, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(rec.exerciseNames.take(3).join(' • '),
                    style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                if (rec.recommendationReason != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppColors.success, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(rec.recommendationReason!,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.text)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AppButton(
                  label: 'Начать тренировку',
                  onPressed: () {
                    context.read<WorkoutBloc>().add(WorkoutStartRequested(
                          rec.name,
                          [],
                          rec.exerciseNames,
                        ));
                    context.push('/workout/active');
                  },
                ),
              ],
            ),
          );
        }
        if (state is PlanLoading) {
          return const AppCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return AppCard(
          child: Column(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: AppColors.warning, size: 40),
              const SizedBox(height: 12),
              const Text('Получить рекомендацию', style: AppTextStyles.h4),
              const SizedBox(height: 4),
              Text('Введите текущее состояние',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
              const SizedBox(height: 16),
              AppButton(
                label: 'Оценить состояние',
                style: AppButtonStyle.secondary,
                onPressed: () => _showReadinessSheet(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReadinessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PlanBloc>(),
        child: const _ReadinessSheet(),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.local_fire_department,
          iconColor: AppColors.warning,
          value: '0',
          label: 'Дней подряд',
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.bar_chart,
          iconColor: AppColors.primary,
          value: '0',
          label: 'Тренировок',
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.emoji_events_outlined,
          iconColor: AppColors.success,
          value: '0',
          label: 'Рекордов',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.h3),
            Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _WeekWorkoutsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanBloc, PlanState>(
      builder: (context, state) {
        if (state is PlanLoaded) {
          final today = DateTime.now();
          final weekDays = AppDateUtils.weekDays(today);
          return Column(
            children: weekDays.map((day) {
              final workouts = state.weekPlan.where((w) {
                final d = w.scheduledDate;
                return d.year == day.year && d.month == day.month && d.day == day.day;
              }).toList();
              final isToday =
                  day.year == today.year && day.month == today.month && day.day == today.day;
              return _DayRow(day: day, workouts: workouts, isToday: isToday);
            }).toList(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _DayRow extends StatelessWidget {
  final DateTime day;
  final List<PlannedWorkout> workouts;
  final bool isToday;

  const _DayRow({required this.day, required this.workouts, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(AppDateUtils.weekDayShort(day.weekday),
                    style: AppTextStyles.label.copyWith(
                        color: isToday ? Colors.white : AppColors.muted)),
                Text('${day.day}',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: isToday ? Colors.white : AppColors.text)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: workouts.isEmpty
                ? Container(
                    height: 44,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('Отдых',
                          style:
                              AppTextStyles.caption.copyWith(color: AppColors.muted)),
                    ),
                  )
                : Column(
                    children: workouts
                        .map((w) => Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                    w.completed ? AppColors.successLight : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    w.completed ? Icons.check_circle : Icons.fitness_center,
                                    color: w.completed ? AppColors.success : AppColors.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(w.name, style: AppTextStyles.bodyMedium),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartSheet extends StatefulWidget {
  const _QuickStartSheet();

  @override
  State<_QuickStartSheet> createState() => _QuickStartSheetState();
}

class _QuickStartSheetState extends State<_QuickStartSheet> {
  final _nameCtrl = TextEditingController(text: 'Быстрая тренировка');

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Быстрый старт', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Название тренировки'),
          ),
          const SizedBox(height: 24),
          BlocListener<WorkoutBloc, WorkoutState>(
            listener: (context, state) {
              if (state is WorkoutInProgress) {
                Navigator.of(context).pop();
                context.push('/workout/active');
              }
            },
            child: BlocBuilder<WorkoutBloc, WorkoutState>(
              builder: (context, state) {
                return AppButton(
                  label: 'Начать',
                  loading: state is WorkoutLoading,
                  onPressed: () {
                    context.read<WorkoutBloc>().add(
                          WorkoutStartRequested(_nameCtrl.text, [], []),
                        );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessSheet extends StatefulWidget {
  const _ReadinessSheet();

  @override
  State<_ReadinessSheet> createState() => _ReadinessSheetState();
}

class _ReadinessSheetState extends State<_ReadinessSheet> {
  double _fatigue = 5;
  double _soreness = 5;
  double _sleep = 5;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Текущее состояние', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text('Оцените своё самочувствие сейчас',
              style: AppTextStyles.body.copyWith(color: AppColors.muted)),
          const SizedBox(height: 24),
          _SliderRow(label: 'Усталость', value: _fatigue,
              onChanged: (v) => setState(() => _fatigue = v)),
          _SliderRow(label: 'Болезненность мышц', value: _soreness,
              onChanged: (v) => setState(() => _soreness = v)),
          _SliderRow(label: 'Качество сна', value: _sleep,
              onChanged: (v) => setState(() => _sleep = v), reversed: true),
          const SizedBox(height: 24),
          AppButton(
            label: 'Получить рекомендацию',
            onPressed: () {
              context.read<PlanBloc>().add(PlanRecommendationRequested(
                readiness: ReadinessData(
                  fatigue: _fatigue.round(),
                  soreness: _soreness.round(),
                  sleepQuality: _sleep.round(),
                ),
              ));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final bool reversed;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.reversed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.bodyMedium),
              Text('${value.round()}/10',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ],
          ),
          Slider(
            value: value,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(reversed ? 'Плохо' : 'Слабо',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
              Text(reversed ? 'Отлично' : 'Очень высокая',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}
