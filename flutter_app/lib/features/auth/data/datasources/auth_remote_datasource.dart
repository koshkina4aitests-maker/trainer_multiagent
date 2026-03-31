import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../models/auth_response.dart';
import '../models/google_auth_payload.dart';

class AuthRemoteDatasource {
  final http.Client _client;

  AuthRemoteDatasource({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthResponseDto> signInWithGoogle({
    required GoogleAuthPayload payload,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/v1/auth/google');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Auth API error: ${response.statusCode}');
    }
    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResponseDto.fromJson(raw);
  }
}
