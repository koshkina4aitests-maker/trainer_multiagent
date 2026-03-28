import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDatasource _local;
  ProfileRepositoryImpl(this._local);

  @override
  Future<UserProfile?> getProfile() async => _local.getProfile();

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    await _local.saveProfile(profile);
    return profile;
  }
}
