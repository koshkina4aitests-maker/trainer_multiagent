import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/local_storage.dart';

abstract class OnboardingState {}
class OnboardingInitial extends OnboardingState {}
class OnboardingSaving extends OnboardingState {}
class OnboardingDone extends OnboardingState {}
class OnboardingError extends OnboardingState {
  final String message;
  OnboardingError(this.message);
}

class OnboardingCubit extends Cubit<OnboardingState> {
  final LocalStorage _storage;
  OnboardingCubit(this._storage) : super(OnboardingInitial());

  String? selectedGoal;
  int? age;
  double? weight;
  double? height;
  String? gender;
  List<String> healthLimits = [];

  void setGoal(String goal) => selectedGoal = goal;
  void setAge(int v) => age = v;
  void setWeight(double v) => weight = v;
  void setHeight(double v) => height = v;
  void setGender(String v) => gender = v;
  void toggleHealthLimit(String limit) {
    if (healthLimits.contains(limit)) {
      healthLimits = healthLimits.where((l) => l != limit).toList();
    } else {
      healthLimits = [...healthLimits, limit];
    }
  }

  Future<void> complete() async {
    emit(OnboardingSaving());
    try {
      if (selectedGoal != null) await _storage.setUserGoal(selectedGoal!);
      if (age != null) await _storage.setUserAge(age!);
      if (weight != null) await _storage.setUserWeight(weight!);
      if (height != null) await _storage.setUserHeight(height!);
      if (gender != null) await _storage.setUserGender(gender!);
      await _storage.setHealthLimits(healthLimits);
      await _storage.setOnboardingDone();
      emit(OnboardingDone());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}
