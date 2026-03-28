import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../bloc/onboarding_cubit.dart';

class HealthLimitsPage extends StatefulWidget {
  const HealthLimitsPage({super.key});

  @override
  State<HealthLimitsPage> createState() => _HealthLimitsPageState();
}

class _HealthLimitsPageState extends State<HealthLimitsPage> {
  static const _limits = [
    (icon: Icons.back_hand_outlined, label: 'Боль в спине', desc: 'Хроническая или периодическая'),
    (icon: Icons.accessibility_new, label: 'Боль в коленях', desc: 'Ограничения на приседания'),
    (icon: Icons.medical_services_outlined, label: 'Гипотиреоз', desc: 'Сниженная функция щитовидной железы'),
    (icon: Icons.favorite_border, label: 'Боль в суставах', desc: 'Другие суставные проблемы'),
    (icon: Icons.monitor_heart_outlined, label: 'Повышенное давление', desc: 'Гипертония'),
  ];

  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingDone) {
          context.go('/home');
        } else if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text('Ограничения по здоровью')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Есть ли у вас ограничения?', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text('Необязательно — пропустите, если нет',
                    style: AppTextStyles.body.copyWith(color: AppColors.muted)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.warning, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Не является медицинской консультацией. Рекомендуем проконсультироваться с врачом.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: _limits
                        .map((l) => _LimitCheckTile(
                              icon: l.icon,
                              label: l.label,
                              desc: l.desc,
                              selected: _selected.contains(l.label),
                              onTap: () => setState(() {
                                if (_selected.contains(l.label)) {
                                  _selected.remove(l.label);
                                } else {
                                  _selected.add(l.label);
                                }
                              }),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<OnboardingCubit, OnboardingState>(
                  builder: (context, state) {
                    return AppButton(
                      label: 'Завершить',
                      loading: state is OnboardingSaving,
                      onPressed: () {
                        final cubit = context.read<OnboardingCubit>();
                        for (final l in _selected) {
                          cubit.toggleHealthLimit(l);
                        }
                        cubit.complete();
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Пропустить',
                  style: AppButtonStyle.ghost,
                  onPressed: () {
                    context.read<OnboardingCubit>().complete();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LimitCheckTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _LimitCheckTile({
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.muted, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyMedium),
                  Text(desc,
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
            Checkbox(
              value: selected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }
}
