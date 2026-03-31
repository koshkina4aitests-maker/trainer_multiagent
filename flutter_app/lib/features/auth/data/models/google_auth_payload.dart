class GoogleAuthPayload {
  final String idToken;

  const GoogleAuthPayload({
    required this.idToken,
  });

  Map<String, dynamic> toJson() => {
        'id_token': idToken,
      };
}
