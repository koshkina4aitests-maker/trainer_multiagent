import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/progress_data.dart';
import '../../domain/repositories/progress_repository.dart';

abstract class ProgressState {}
class ProgressInitial extends ProgressState {}
class ProgressLoading extends ProgressState {}
class ProgressLoaded extends ProgressState {
  final ProgressSummary summary;
  final int days;
  ProgressLoaded(this.summary, {this.days = 30});
}
class ProgressError extends ProgressState {
  final String message;
  ProgressError(this.message);
}

class ProgressCubit extends Cubit<ProgressState> {
  final ProgressRepository _repo;
  ProgressCubit(this._repo) : super(ProgressInitial());

  Future<void> load({int days = 30}) async {
    emit(ProgressLoading());
    try {
      final summary = await _repo.getSummary(days: days);
      emit(ProgressLoaded(summary, days: days));
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }
}
