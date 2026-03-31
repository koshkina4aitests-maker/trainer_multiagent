import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/google_auth_payload.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource _local;
  final AuthRemoteDatasource _remote;
  final GoogleSignIn _googleSignIn;

  AppUser? _currentUser;

  AuthRepositoryImpl(this._local, this._remote, this._googleSignIn) {
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
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Вход через Google отменен');
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google не вернул id_token');
    }

    final response = await _remote.signInWithGoogle(
      payload: GoogleAuthPayload(
        idToken: idToken,
      ),
    );

    final appUser = AppUser(
      id: response.userId.toString(),
      name: account.displayName ?? '',
      email: account.email,
      avatarUrl: account.photoUrl,
    );

    await _local.saveToken(response.accessToken);
    await _local.saveUserId(appUser.id);
    await _local.saveUserName(appUser.name);
    await _local.saveUserEmail(appUser.email);
    _currentUser = appUser;
    return appUser;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    await _local.clearAll();
  }
}
