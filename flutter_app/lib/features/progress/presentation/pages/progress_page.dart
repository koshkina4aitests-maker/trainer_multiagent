import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../cubit/progress_cubit.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  int _days = 30;

  @override
  void initState() {
    super.initState();
    context.read<ProgressCubit>().load(days: _days);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Прогресс'),
      ),
      body: Column(
        children: [
          _PeriodSelector(
            selected: _days,
            onSelect: (d) {
              setState(() => _days = d);
              context.read<ProgressCubit>().load(days: d);
            },
          ),
          Expanded(
            child: BlocBuilder<ProgressCubit, ProgressState>(
              builder: (context, state) {
                if (state is ProgressLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProgressLoaded) {
                  final s = state.summary;
                  if (s.totalSessions == 0) {
                    return const EmptyStateWidget(
                      icon: Icons.bar_chart,
                      title: 'Нет данных',
                      subtitle: 'Завершите первую тренировку, чтобы увидеть прогресс',
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      _SummaryCards(summary: s),
                      const SizedBox(height: 24),
                      if (s.weeklyVolumes.length >= 2) ...[
                        Text('Объём по неделям', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        _VolumeChart(volumes: s.weeklyVolumes),
                        const SizedBox(height: 24),
                      ],
                      if (s.personalRecords.isNotEmpty) ...[
                        Text('Личные рекорды', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        ...s.personalRecords
                            .take(10)
                            .map((pr) => _PRCard(pr: pr)),
                      ],
                    ],
                  );
                }
                if (state is ProgressError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onRetry: () => context.read<ProgressCubit>().load(days: _days),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _PeriodSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [7, 30, 90].map((d) {
          final isSelected = d == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('$d дней'),
              selected: isSelected,
              onSelected: (_) => onSelect(d),
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
              labelStyle: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.text,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final dynamic summary;
  const _SummaryCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Icon(Icons.fitness_center, color: AppColors.primary, size: 26),
                const SizedBox(height: 4),
                Text('${summary.totalSessions}', style: AppTextStyles.h3),
                Text('Тренировок', style: AppTextStyles.caption, textAlign: TextAlign.center),
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
                const Icon(Icons.bar_chart, color: AppColors.success, size: 26),
                const SizedBox(height: 4),
                Text('${(summary.totalVolume / 1000).toStringAsFixed(1)}т',
                    style: AppTextStyles.h3),
                Text('Общий объём', style: AppTextStyles.caption, textAlign: TextAlign.center),
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
                const Icon(Icons.local_fire_department, color: AppColors.warning, size: 26),
                const SizedBox(height: 4),
                Text('${summary.currentStreak}', style: AppTextStyles.h3),
                Text('Дней подряд', style: AppTextStyles.caption, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VolumeChart extends StatelessWidget {
  final List volumes;
  const _VolumeChart({required this.volumes});

  @override
  Widget build(BuildContext context) {
    final spots = volumes.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.totalVolume,
            color: AppColors.primary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return AppCard(
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            barGroups: spots,
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(
              show: true,
              drawVerticalLine: false,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, _) => Text(
                    '${(v / 1000).toStringAsFixed(1)}т',
                    style: AppTextStyles.label,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx >= volumes.length) return const SizedBox.shrink();
                    return Text(
                      AppDateUtils.weekDayShort(volumes[idx].weekStart.weekday),
                      style: AppTextStyles.label,
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
          ),
        ),
      ),
    );
  }
}

class _PRCard extends StatelessWidget {
  final dynamic pr;
  const _PRCard({required this.pr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pr.exerciseName, style: AppTextStyles.bodyMedium),
                Text(AppDateUtils.formatDate(pr.achievedAt),
                    style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${pr.weight} кг', style: AppTextStyles.h4),
              Text('× ${pr.reps} повт.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}
