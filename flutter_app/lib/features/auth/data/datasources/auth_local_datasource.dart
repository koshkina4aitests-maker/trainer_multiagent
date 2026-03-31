import '../../../../core/storage/local_storage.dart';

class AuthLocalDatasource {
  final LocalStorage _storage;
  AuthLocalDatasource(this._storage);

  String? getToken() => _storage.authToken;
  Future<void> saveToken(String token) => _storage.setAuthToken(token);
  Future<void> saveGoogleSub(String googleSub) => _storage.setGoogleSub(googleSub);
  Future<void> saveUserId(String id) => _storage.setUserId(id);
  Future<void> saveUserName(String name) => _storage.setUserName(name);
  Future<void> saveUserEmail(String email) => _storage.setUserEmail(email);
  Future<void> clearAll() => _storage.clearAll();

  Map<String, String?> getUserData() => {
        'id': _storage.userId,
        'name': _storage.userName,
        'email': _storage.userEmail,
        'google_sub': _storage.googleSub,
      };
}
