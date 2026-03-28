import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../bloc/onboarding_cubit.dart';

class GoalSelectionPage extends StatefulWidget {
  const GoalSelectionPage({super.key});

  @override
  State<GoalSelectionPage> createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<GoalSelectionPage> {
  String? _selected;

  static const _goals = [
    (icon: Icons.monitor_weight_outlined, label: 'Похудение', desc: 'Снизить вес и жировую массу'),
    (icon: Icons.fitness_center, label: 'Сила', desc: 'Увеличить силовые показатели'),
    (icon: Icons.directions_run, label: 'Выносливость', desc: 'Улучшить кардиовыносливость'),
    (icon: Icons.favorite_outline, label: 'Здоровье', desc: 'Общее укрепление организма'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Выберите цель')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Какова ваша цель?', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text('Это поможет подобрать оптимальный план тренировок',
                  style: AppTextStyles.body.copyWith(color: AppColors.muted)),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: _goals.map((g) => _GoalCard(
                    icon: g.icon,
                    label: g.label,
                    desc: g.desc,
                    selected: _selected == g.label,
                    onTap: () => setState(() => _selected = g.label),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Далее',
                onPressed: _selected == null
                    ? null
                    : () {
                        context.read<OnboardingCubit>().setGoal(_selected!);
                        context.push('/onboarding/metrics');
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: selected ? Colors.white : AppColors.muted, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.h4),
                  Text(desc,
                      style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
