import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/workout_session.dart';
import '../bloc/workout_bloc.dart';
import '../bloc/workout_event.dart';
import '../bloc/workout_state.dart';

class ActiveWorkoutPage extends StatefulWidget {
  const ActiveWorkoutPage({super.key});

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;
  int _selectedExerciseIdx = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutBloc, WorkoutState>(
      listener: (context, state) {
        if (state is WorkoutFinished) {
          context.go('/workout/summary');
        } else if (state is WorkoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        if (state is! WorkoutInProgress) {
          return Scaffold(
            appBar: AppBar(title: const Text('Тренировка')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final session = state.session;
        final isWide = MediaQuery.of(context).size.width >= 1000;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _confirmExit(context);
          },
          child: Scaffold(
            backgroundColor: AppColors.bg,
            appBar: AppBar(
              title: Text(session.name),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _confirmExit(context),
              ),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppDateUtils.formatDuration(_elapsed),
                      style:
                          AppTextStyles.h3.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                if (session.exercises.isNotEmpty) ...[
                  if (isWide)
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 280,
                            child: _ExerciseSideList(
                              exercises: session.exercises,
                              selectedIdx: _selectedExerciseIdx,
                              onSelect: (i) => setState(() => _selectedExerciseIdx = i),
                            ),
                          ),
                          const VerticalDivider(width: 1, color: AppColors.border),
                          Expanded(
                            child: _ExercisePanel(
                              session: session,
                              exerciseIdx: _selectedExerciseIdx,
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    _ExerciseTabBar(
                      exercises: session.exercises,
                      selectedIdx: _selectedExerciseIdx,
                      onSelect: (i) => setState(() => _selectedExerciseIdx = i),
                    ),
                    Expanded(
                      child: _ExercisePanel(
                        session: session,
                        exerciseIdx: _selectedExerciseIdx,
                      ),
                    ),
                  ],
                ] else
                  Expanded(
                    child: _FreeSessionPanel(session: session),
                  ),
                _BottomBar(session: session),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Завершить тренировку?'),
        content:
            const Text('Прогресс будет сохранён как черновик.'),
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
      context.go('/home');
    }
    return false;
  }
}

class _ExerciseSideList extends StatelessWidget {
  final List<ExerciseLog> exercises;
  final int selectedIdx;
  final ValueChanged<int> onSelect;

  const _ExerciseSideList({
    required this.exercises,
    required this.selectedIdx,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, i) {
          final selected = i == selectedIdx;
          final exercise = exercises[i];
          return ListTile(
            selected: selected,
            selectedTileColor: AppColors.primaryLight,
            leading: Icon(
              exercise.sets.isNotEmpty ? Icons.check_circle : Icons.fitness_center,
              color: exercise.sets.isNotEmpty ? AppColors.success : AppColors.primary,
            ),
            title: Text(
              exercise.exerciseName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? AppColors.primaryDark : AppColors.text,
              ),
            ),
            subtitle: Text(
              '${exercise.sets.length} подходов',
              style: AppTextStyles.caption,
            ),
            onTap: () => onSelect(i),
          );
        },
      ),
    );
  }
}

class _ExerciseTabBar extends StatelessWidget {
  final List<ExerciseLog> exercises;
  final int selectedIdx;
  final ValueChanged<int> onSelect;

  const _ExerciseTabBar({
    required this.exercises,
    required this.selectedIdx,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: exercises.length,
        itemBuilder: (context, i) {
          final selected = i == selectedIdx;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border),
              ),
              child: Row(
                children: [
                  if (exercises[i].sets.isNotEmpty) ...[
                    const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    exercises[i].exerciseName,
                    style: AppTextStyles.caption.copyWith(
                        color: selected ? Colors.white : AppColors.text),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExercisePanel extends StatelessWidget {
  final WorkoutSession session;
  final int exerciseIdx;

  const _ExercisePanel({required this.session, required this.exerciseIdx});

  @override
  Widget build(BuildContext context) {
    final exercise =
        exerciseIdx < session.exercises.length ? session.exercises[exerciseIdx] : null;
    if (exercise == null) return const SizedBox.shrink();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercise.exerciseName, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text('${exercise.sets.length} подходов выполнено',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
          const SizedBox(height: 16),
          if (exercise.sets.isNotEmpty) ...[
            _SetsTable(sets: exercise.sets),
            const SizedBox(height: 16),
          ],
          _LogSetForm(
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.exerciseName,
            setNumber: exercise.sets.length + 1,
            previousSet: exercise.sets.isNotEmpty ? exercise.sets.last : null,
          ),
        ],
      ),
    );
  }
}

class _FreeSessionPanel extends StatelessWidget {
  final WorkoutSession session;

  const _FreeSessionPanel({required this.session});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 60, color: AppColors.muted),
            const SizedBox(height: 16),
            const Text('Свободная тренировка', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text('Упражнения не заданы. Завершите тренировку, когда будете готовы.',
                style: AppTextStyles.body.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SetsTable extends StatelessWidget {
  final List<SetLog> sets;

  const _SetsTable({required this.sets});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: const BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                _HeaderCell('№', flex: 1),
                _HeaderCell('Повт.', flex: 2),
                _HeaderCell('Вес (кг)', flex: 3),
                _HeaderCell('RIR', flex: 2),
              ],
            ),
          ),
          ...sets.asMap().entries.map((e) {
            final s = e.value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  _Cell('${e.key + 1}', flex: 1, muted: true),
                  _Cell('${s.reps}', flex: 2),
                  _Cell('${s.weight}', flex: 3),
                  _Cell('${s.rir}', flex: 2),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text, style: AppTextStyles.label, textAlign: TextAlign.center),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final bool muted;

  const _Cell(this.text, {required this.flex, this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: muted
              ? AppTextStyles.caption
              : AppTextStyles.bodyMedium,
          textAlign: TextAlign.center),
    );
  }
}

class _LogSetForm extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final int setNumber;
  final SetLog? previousSet;

  const _LogSetForm({
    required this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    this.previousSet,
  });

  @override
  State<_LogSetForm> createState() => _LogSetFormState();
}

class _LogSetFormState extends State<_LogSetForm> {
  final _formKey = GlobalKey<FormState>();
  late final _repsCtrl = TextEditingController(
      text: widget.previousSet != null ? '${widget.previousSet!.reps}' : '');
  late final _weightCtrl = TextEditingController(
      text: widget.previousSet != null ? '${widget.previousSet!.weight}' : '');
  late final _rirCtrl = TextEditingController(
      text: widget.previousSet != null ? '${widget.previousSet!.rir}' : '2');

  @override
  void dispose() {
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    _rirCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Подход ${widget.setNumber}', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _repsCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.reps,
                    decoration: const InputDecoration(labelText: 'Повторения'),
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
                SizedBox(
                  width: 72,
                  child: TextFormField(
                    controller: _rirCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.rir,
                    decoration: const InputDecoration(labelText: 'RIR'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppButton(
              label: '✓  Записать подход',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final setLog = SetLog(
                    setNumber: widget.setNumber,
                    reps: int.parse(_repsCtrl.text),
                    weight: double.parse(
                        _weightCtrl.text.isEmpty ? '0' : _weightCtrl.text.replaceAll(',', '.')),
                    rir: int.parse(_rirCtrl.text),
                    timestamp: DateTime.now(),
                  );
                  context.read<WorkoutBloc>().add(WorkoutSetLogged(
                        widget.exerciseId,
                        widget.exerciseName,
                        setLog,
                      ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final WorkoutSession session;

  const _BottomBar({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Подходов: ${session.totalSets}', style: AppTextStyles.caption),
                Text('Объём: ${session.totalVolume.toStringAsFixed(0)} кг',
                    style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          AppButton(
            label: 'Завершить',
            fullWidth: false,
            style: AppButtonStyle.danger,
            onPressed: () => _confirm(context),
          ),
        ],
      ),
    );
  }

  void _confirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Завершить тренировку?'),
        content: Text(
            'Выполнено ${session.totalSets} подходов, объём ${session.totalVolume.toStringAsFixed(0)} кг'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_),
              child: const Text('Продолжить')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(_);
              context.read<WorkoutBloc>().add(WorkoutCompleted());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Завершить'),
          ),
        ],
      ),
    );
  }
}
