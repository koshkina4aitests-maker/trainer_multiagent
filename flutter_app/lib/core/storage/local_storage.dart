import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyOnboardingDone = 'onboarding_done';
  static const String _keyDraftSession = 'draft_session';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserGoal = 'user_goal';
  static const String _keyHealthLimits = 'health_limits';
  static const String _keyUserAge = 'user_age';
  static const String _keyUserWeight = 'user_weight';
  static const String _keyUserHeight = 'user_height';
  static const String _keyUserGender = 'user_gender';

  String? get authToken => _prefs.getString(_keyAuthToken);
  Future<void> setAuthToken(String token) => _prefs.setString(_keyAuthToken, token);
  Future<void> clearAuthToken() => _prefs.remove(_keyAuthToken);

  String? get userId => _prefs.getString(_keyUserId);
  Future<void> setUserId(String id) => _prefs.setString(_keyUserId, id);

  String? get userName => _prefs.getString(_keyUserName);
  Future<void> setUserName(String name) => _prefs.setString(_keyUserName, name);

  String? get userEmail => _prefs.getString(_keyUserEmail);
  Future<void> setUserEmail(String email) => _prefs.setString(_keyUserEmail, email);

  bool get isOnboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;
  Future<void> setOnboardingDone() => _prefs.setBool(_keyOnboardingDone, true);

  String? get draftSession => _prefs.getString(_keyDraftSession);
  Future<void> setDraftSession(String json) => _prefs.setString(_keyDraftSession, json);
  Future<void> clearDraftSession() => _prefs.remove(_keyDraftSession);

  String? get userGoal => _prefs.getString(_keyUserGoal);
  Future<void> setUserGoal(String goal) => _prefs.setString(_keyUserGoal, goal);

  List<String> get healthLimits => _prefs.getStringList(_keyHealthLimits) ?? [];
  Future<void> setHealthLimits(List<String> limits) => _prefs.setStringList(_keyHealthLimits, limits);

  int? get userAge => _prefs.getInt(_keyUserAge);
  Future<void> setUserAge(int age) => _prefs.setInt(_keyUserAge, age);

  double? get userWeight => _prefs.getDouble(_keyUserWeight);
  Future<void> setUserWeight(double weight) => _prefs.setDouble(_keyUserWeight, weight);

  double? get userHeight => _prefs.getDouble(_keyUserHeight);
  Future<void> setUserHeight(double height) => _prefs.setDouble(_keyUserHeight, height);

  String? get userGender => _prefs.getString(_keyUserGender);
  Future<void> setUserGender(String gender) => _prefs.setString(_keyUserGender, gender);

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
