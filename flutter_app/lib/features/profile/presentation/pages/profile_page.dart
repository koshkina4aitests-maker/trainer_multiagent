import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Профиль сохранён')),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileLoaded || state is ProfileSaved || state is ProfileSaving) {
            final profile = state is ProfileLoaded
                ? state.profile
                : state is ProfileSaved
                    ? state.profile
                    : (state as ProfileSaving).profile;
            return _ProfileForm(profile: profile);
          }
          return ErrorStateWidget(
            message: 'Не удалось загрузить профиль',
            onRetry: () => context.read<ProfileCubit>().load(),
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_, false),
              child: const Text('Отмена')),
          TextButton(
              onPressed: () => Navigator.pop(_, true),
              child: const Text('Выйти',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(SignOutRequested());
      context.go('/welcome');
    }
  }
}

class _ProfileForm extends StatefulWidget {
  final UserProfile profile;
  const _ProfileForm({required this.profile});

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.profile.name);
  late final _ageCtrl =
      TextEditingController(text: widget.profile.age?.toString() ?? '');
  late final _weightCtrl = TextEditingController(
      text: widget.profile.weightKg?.toString() ?? '');
  late final _heightCtrl = TextEditingController(
      text: widget.profile.heightCm?.toString() ?? '');
  late String _goal = widget.profile.goal;
  late String _trainingStyle = widget.profile.trainingStyle;
  late Set<String> _healthLimits = Set.from(widget.profile.healthLimits);

  static const _goals = ['Похудение', 'Сила', 'Выносливость', 'Здоровье'];
  static const _trainingStyles = ['fullbody', 'split'];
  static const _healthOptions = [
    'Боль в спине',
    'Боль в коленях',
    'Гипотиреоз',
    'Боль в суставах',
    'Повышенное давление',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AvatarSection(name: widget.profile.name),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Личные данные', style: AppTextStyles.h4),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    validator: (_) => null,
                    decoration: const InputDecoration(labelText: 'Имя'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageCtrl,
                          validator: Validators.age,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(labelText: 'Возраст'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _weightCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Вес (кг)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _heightCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Рост (см)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Стиль тренировок', style: AppTextStyles.h4),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _trainingStyles.map((style) {
                      final selected = _trainingStyle == style;
                      return FilterChip(
                        label: Text(style == 'fullbody' ? 'Fullbody' : 'Split'),
                        selected: selected,
                        onSelected: (_) => setState(() => _trainingStyle = style),
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                        labelStyle: AppTextStyles.body.copyWith(
                          color: selected ? AppColors.primary : AppColors.text,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Цель тренировок', style: AppTextStyles.h4),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _goals.map((g) {
                      final selected = _goal == g;
                      return FilterChip(
                        label: Text(g),
                        selected: selected,
                        onSelected: (_) => setState(() => _goal = g),
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                        labelStyle: AppTextStyles.body.copyWith(
                          color: selected ? AppColors.primary : AppColors.text,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ограничения по здоровью', style: AppTextStyles.h4),
                  const SizedBox(height: 4),
                  Text(
                    'Не является медицинской консультацией',
                    style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  ..._healthOptions.map((opt) => CheckboxListTile(
                        title: Text(opt, style: AppTextStyles.body),
                        value: _healthLimits.contains(opt),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _healthLimits.add(opt);
                          } else {
                            _healthLimits.remove(opt);
                          }
                        }),
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                return AppButton(
                  label: 'Сохранить изменения',
                  loading: state is ProfileSaving,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<ProfileCubit>().save(
                            widget.profile.copyWith(
                              name: _nameCtrl.text.trim(),
                              age: int.tryParse(_ageCtrl.text),
                              weightKg: double.tryParse(
                                  _weightCtrl.text.replaceAll(',', '.')),
                              heightCm: double.tryParse(
                                  _heightCtrl.text.replaceAll(',', '.')),
                              goal: _goal,
                              trainingStyle: _trainingStyle,
                              healthLimits: _healthLimits.toList(),
                            ),
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
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final String name;
  const _AvatarSection({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: AppTextStyles.h1.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name.isNotEmpty ? name : 'Имя не указано',
            style: AppTextStyles.h3,
          ),
        ],
      ),
    );
  }
}
