import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../cubit/exercise_cubit.dart';

class ExerciseLibraryPage extends StatefulWidget {
  const ExerciseLibraryPage({super.key});

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  final _searchCtrl = TextEditingController();
  String? _selectedGroup;

  static const _groups = [
    'Все', 'Грудь', 'Спина', 'Ноги', 'Плечи', 'Руки', 'Пресс',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ExerciseCubit>().load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('База упражнений'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/home/workouts/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppSearchInput(
              controller: _searchCtrl,
              hint: 'Поиск упражнения...',
              onChanged: (q) => context.read<ExerciseCubit>().load(
                    query: q,
                    muscleGroup: _selectedGroup == 'Все' ? null : _selectedGroup,
                  ),
            ),
          ),
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _groups.map((g) {
                  final selected = g == (_selectedGroup ?? 'Все');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(g),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedGroup = g == 'Все' ? null : g);
                        context.read<ExerciseCubit>().load(
                              query: _searchCtrl.text,
                              muscleGroup: g == 'Все' ? null : g,
                            );
                      },
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.caption.copyWith(
                          color: selected ? AppColors.primary : AppColors.text),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<ExerciseCubit, ExerciseState>(
              builder: (context, state) {
                if (state is ExerciseLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ExerciseLoaded) {
                  if (state.exercises.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.search_off,
                      title: 'Упражнения не найдены',
                      subtitle: 'Попробуйте другой запрос или добавьте своё упражнение',
                      actionLabel: 'Добавить упражнение',
                      onAction: () => context.push('/home/workouts/add'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: state.exercises.length,
                    itemBuilder: (context, i) {
                      final e = state.exercises[i];
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
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.fitness_center,
                                  color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.name, style: AppTextStyles.bodyMedium),
                                  Text(
                                    '${e.muscleGroup} • ${e.equipment}',
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.muted),
                                  ),
                                  if (e.healthRestrictions.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children: e.healthRestrictions
                                          .map((r) => Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.warningLight,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(r,
                                                    style: AppTextStyles.label
                                                        .copyWith(
                                                            color: AppColors.warning)),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (e.isCustom)
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.error, size: 20),
                                onPressed: () =>
                                    context.read<ExerciseCubit>().delete(e.id),
                              ),
                          ],
                        ),
                      );
                    },
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
