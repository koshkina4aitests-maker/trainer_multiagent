import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                _buildHero(),
                const SizedBox(height: 48),
                _buildValueProps(),
                const Spacer(),
                _buildActions(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.fitness_center, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 24),
        const Text('FitApp', style: AppTextStyles.h1),
        const SizedBox(height: 8),
        Text(
          'Тренируйся умнее.\nОтслеживай быстрее.\nВосстанавливайся лучше.',
          style: AppTextStyles.body.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildValueProps() {
    final props = [
      (Icons.track_changes, 'Персональные тренировки', 'Планы под ваши цели и уровень'),
      (Icons.insights, 'Умные рекомендации', 'AI анализирует ваше состояние'),
      (Icons.health_and_safety, 'Безопасность прежде всего', 'Учитываем медицинские ограничения'),
    ];
    return Column(
      children: props
          .map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(p.$1, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.$2, style: AppTextStyles.h4),
                          Text(p.$3,
                              style:
                                  AppTextStyles.caption.copyWith(color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return AppButton(
              label: 'Начать с Google',
              loading: state is AuthLoading,
              onPressed: () {
                context.read<AuthBloc>().add(GoogleSignInRequested());
              },
              icon: const Icon(Icons.login, color: Colors.white, size: 18),
            );
          },
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Войти в существующий аккаунт',
          style: AppButtonStyle.secondary,
          onPressed: () => context.push('/sign-in'),
        ),
      ],
    );
  }
}
