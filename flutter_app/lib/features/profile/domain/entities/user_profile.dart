class UserProfile {
  final String userId;
  final String name;
  final String email;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final String? gender;
  final String goal;
  final String trainingStyle;
  final List<String> healthLimits;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.age,
    this.weightKg,
    this.heightCm,
    this.gender,
    required this.goal,
    this.trainingStyle = 'fullbody',
    required this.healthLimits,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    int? age,
    double? weightKg,
    double? heightCm,
    String? gender,
    String? goal,
    String? trainingStyle,
    List<String>? healthLimits,
  }) {
    return UserProfile(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      trainingStyle: trainingStyle ?? this.trainingStyle,
      healthLimits: healthLimits ?? this.healthLimits,
    );
  }
}
