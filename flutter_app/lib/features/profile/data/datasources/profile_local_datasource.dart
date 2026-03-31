import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/user_profile.dart';

class ProfileLocalDatasource {
  final LocalStorage _storage;
  ProfileLocalDatasource(this._storage);

  UserProfile? getProfile() {
    final id = _storage.userId;
    final name = _storage.userName ?? '';
    final email = _storage.userEmail;
    if (id == null || email == null) return null;
    return UserProfile(
      userId: id,
      name: name,
      email: email,
      age: _storage.userAge,
      weightKg: _storage.userWeight,
      heightCm: _storage.userHeight,
      gender: _storage.userGender,
      goal: _storage.userGoal ?? 'Здоровье',
      trainingStyle: _storage.trainingStyle ?? 'fullbody',
      healthLimits: _storage.healthLimits,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _storage.setUserName(profile.name);
    await _storage.setUserEmail(profile.email);
    if (profile.age != null) await _storage.setUserAge(profile.age!);
    if (profile.weightKg != null) await _storage.setUserWeight(profile.weightKg!);
    if (profile.heightCm != null) await _storage.setUserHeight(profile.heightCm!);
    if (profile.gender != null) await _storage.setUserGender(profile.gender!);
    await _storage.setUserGoal(profile.goal);
    await _storage.setTrainingStyle(profile.trainingStyle);
    await _storage.setHealthLimits(profile.healthLimits);
  }
}
