import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource _local;

  AppUser? _currentUser;

  AuthRepositoryImpl(this._local) {
    _restoreUser();
  }

  void _restoreUser() {
    final data = _local.getUserData();
    final id = data['id'];
    final name = data['name'];
    final email = data['email'];
    if (id != null && name != null && email != null) {
      _currentUser = AppUser(id: id, name: name, email: email);
    }
  }

  @override
  bool get isAuthenticated => _local.getToken() != null && _currentUser != null;

  @override
  Future<AppUser?> getCurrentUser() async => _currentUser;

  @override
  Future<AppUser> signInWithGoogle() async {
    // Demo: simulated Google Sign-In without real OAuth
    // In production, integrate google_sign_in package with a real client ID
    const demoUser = AppUser(
      id: 'demo-user-001',
      // Use a neutral non-hardcoded profile name in demo mode.
      name: '',
      email: 'alexey@example.com',
    );
    await _local.saveToken('demo-token-xyz');
    await _local.saveUserId(demoUser.id);
    await _local.saveUserName(demoUser.name);
    await _local.saveUserEmail(demoUser.email);
    _currentUser = demoUser;
    return demoUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await _local.clearAll();
  }
}
