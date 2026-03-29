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

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

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
        appBar: AppBar(
          title: const Text('Войти'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('Добро пожаловать!', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text('Войдите, чтобы продолжить',
                    style: AppTextStyles.body.copyWith(color: AppColors.muted)),
                const SizedBox(height: 48),
                const _MedicalDisclaimerCard(),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        AppButton(
                          label: 'Войти через Google',
                          loading: state is AuthLoading,
                          onPressed: () {
                            context.read<AuthBloc>().add(GoogleSignInRequested());
                          },
                          icon: const Icon(Icons.login, color: Colors.white, size: 18),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Создать аккаунт',
                          style: AppButtonStyle.secondary,
                          onPressed: state is AuthLoading ? null : () {
                            context.read<AuthBloc>().add(GoogleSignInRequested());
                          },
                        ),
                      ],
                    );
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

class _MedicalDisclaimerCard extends StatelessWidget {
  const _MedicalDisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Приложение предоставляет информационную поддержку и не является медицинской консультацией.',
              style: AppTextStyles.caption.copyWith(color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}
