import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository _repo;
  SignInWithGoogle(this._repo);

  Future<AppUser> call() => _repo.signInWithGoogle();
}
