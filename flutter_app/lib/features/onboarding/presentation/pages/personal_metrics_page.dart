import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../bloc/onboarding_cubit.dart';

class PersonalMetricsPage extends StatefulWidget {
  const PersonalMetricsPage({super.key});

  @override
  State<PersonalMetricsPage> createState() => _PersonalMetricsPageState();
}

class _PersonalMetricsPageState extends State<PersonalMetricsPage> {
  final _formKey = GlobalKey<FormState>();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  String? _gender;

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Личные данные')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Расскажите о себе', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text('Поможет точнее подобрать нагрузку',
                    style: AppTextStyles.body.copyWith(color: AppColors.muted)),
                const SizedBox(height: 32),
                AppInput(
                  label: 'Возраст',
                  hint: 'Например, 35',
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: Validators.age,
                ),
                const SizedBox(height: 16),
                AppInput(
                  label: 'Вес (кг)',
                  hint: 'Например, 75',
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.weight,
                ),
                const SizedBox(height: 16),
                AppInput(
                  label: 'Рост (см)',
                  hint: 'Например, 175',
                  controller: _heightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.height,
                ),
                const SizedBox(height: 24),
                Text('Пол', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _GenderChip(
                      label: 'Мужской',
                      icon: Icons.male,
                      selected: _gender == 'Мужской',
                      onTap: () => setState(() => _gender = 'Мужской'),
                    ),
                    const SizedBox(width: 12),
                    _GenderChip(
                      label: 'Женский',
                      icon: Icons.female,
                      selected: _gender == 'Женский',
                      onTap: () => setState(() => _gender = 'Женский'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                AppButton(
                  label: 'Далее',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final cubit = context.read<OnboardingCubit>();
                      cubit.setAge(int.parse(_ageCtrl.text));
                      cubit.setWeight(double.parse(_weightCtrl.text.replaceAll(',', '.')));
                      cubit.setHeight(double.parse(_heightCtrl.text.replaceAll(',', '.')));
                      if (_gender != null) cubit.setGender(_gender!);
                      context.push('/onboarding/health');
                    }
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

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.muted, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected ? AppColors.primary : AppColors.text,
                )),
          ],
        ),
      ),
    );
  }
}
