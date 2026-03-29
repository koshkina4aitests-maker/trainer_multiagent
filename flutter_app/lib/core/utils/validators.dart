class Validators {
  Validators._();

  static String? required(String? value, {String fieldName = 'Поле'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName обязательно для заполнения';
    }
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите возраст';
    final n = int.tryParse(value);
    if (n == null) return 'Введите число';
    if (n < 10 || n > 120) return 'Возраст должен быть от 10 до 120';
    return null;
  }

  static String? weight(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите вес';
    final n = double.tryParse(value.replaceAll(',', '.'));
    if (n == null) return 'Введите число';
    if (n < 20 || n > 500) return 'Вес должен быть от 20 до 500 кг';
    return null;
  }

  static String? height(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите рост';
    final n = double.tryParse(value.replaceAll(',', '.'));
    if (n == null) return 'Введите число';
    if (n < 50 || n > 300) return 'Рост должен быть от 50 до 300 см';
    return null;
  }

  static String? reps(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите повторения';
    final n = int.tryParse(value);
    if (n == null || n < 1) return 'Введите положительное число';
    return null;
  }

  static String? sets(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите подходы';
    final n = int.tryParse(value);
    if (n == null || n < 1) return 'Введите положительное число';
    return null;
  }

  static String? rir(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите RIR';
    final n = int.tryParse(value);
    if (n == null || n < 0 || n > 10) return 'RIR от 0 до 10';
    return null;
  }
}
