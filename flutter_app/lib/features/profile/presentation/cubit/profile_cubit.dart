import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  ProfileLoaded(this.profile);
}
class ProfileSaving extends ProfileState {
  final UserProfile profile;
  ProfileSaving(this.profile);
}
class ProfileSaved extends ProfileState {
  final UserProfile profile;
  ProfileSaved(this.profile);
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;
  ProfileCubit(this._repo) : super(ProfileInitial());

  Future<void> load() async {
    emit(ProfileLoading());
    final profile = await _repo.getProfile();
    if (profile != null) {
      emit(ProfileLoaded(profile));
    } else {
      emit(ProfileError('Профиль не найден'));
    }
  }

  Future<void> save(UserProfile profile) async {
    emit(ProfileSaving(profile));
    try {
      final saved = await _repo.updateProfile(profile);
      emit(ProfileSaved(saved));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
