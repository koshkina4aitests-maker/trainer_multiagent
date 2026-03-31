class AuthResponseDto {
  final int userId;
  final String accessToken;
  final String tokenType;

  const AuthResponseDto({
    required this.userId,
    required this.accessToken,
    required this.tokenType,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      accessToken: (json['access_token'] as String?) ?? '',
      tokenType: (json['token_type'] as String?) ?? 'bearer',
    );
  }
}
