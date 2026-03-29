import '../entities/user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
  bool get isAuthenticated;
}
