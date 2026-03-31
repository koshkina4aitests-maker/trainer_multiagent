import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/exercise.dart';
import '../cubit/exercise_cubit.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _muscleGroup = 'Грудь';
  String _equipment = 'Без оборудования';
  final Set<String> _healthRestrictions = {};

  static const _groups = [
    'Грудь', 'Спина', 'Ноги', 'Плечи', 'Руки', 'Пресс', 'Кардио', 'Другое',
  ];
  static const _equipments = [
    'Без оборудования', 'Штанга', 'Гантели', 'Тренажёр', 'Блок', 'Турник', 'Другое',
  ];
  static const _healthOptions = [
    'Боль в спине', 'Боль в коленях', 'Гипотиреоз', 'Повышенное давление',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Добавить упражнение'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                validator: (v) => Validators.required(v, fieldName: 'Название'),
                decoration: const InputDecoration(labelText: 'Название упражнения'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Описание (необязательно)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              Text('Группа мышц', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _groups.map((g) => FilterChip(
                  label: Text(g),
                  selected: _muscleGroup == g,
                  onSelected: (_) => setState(() => _muscleGroup = g),
                  selectedColor: AppColors.primaryLight,
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: _muscleGroup == g ? AppColors.primary : AppColors.text,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              Text('Оборудование', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _equipments.map((e) => FilterChip(
                  label: Text(e),
                  selected: _equipment == e,
                  onSelected: (_) => setState(() => _equipment = e),
                  selectedColor: AppColors.primaryLight,
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: _equipment == e ? AppColors.primary : AppColors.text,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              Text('Ограничения по здоровью', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 4),
              Text(
                'Отметьте, если упражнение противопоказано при данных состояниях',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              ..._healthOptions.map((opt) => CheckboxListTile(
                title: Text(opt, style: AppTextStyles.body),
                value: _healthRestrictions.contains(opt),
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _healthRestrictions.add(opt);
                  } else {
                    _healthRestrictions.remove(opt);
                  }
                }),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                dense: true,
              )),
              const SizedBox(height: 32),
              BlocBuilder<ExerciseCubit, ExerciseState>(
                builder: (context, state) {
                  return AppButton(
                    label: 'Сохранить упражнение',
                    loading: state is ExerciseLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final exercise = Exercise(
                          id: const Uuid().v4(),
                          name: _nameCtrl.text.trim(),
                          description: _descCtrl.text.trim(),
                          muscleGroup: _muscleGroup,
                          equipment: _equipment,
                          healthRestrictions: _healthRestrictions.toList(),
                          isCustom: true,
                        );
                        context.read<ExerciseCubit>().add(exercise);
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Упражнение добавлено')),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
