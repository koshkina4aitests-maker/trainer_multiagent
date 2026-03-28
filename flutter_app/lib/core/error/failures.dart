abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Нет подключения к сети']);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Ошибка аутентификации']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Ошибка локального хранилища']);
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors = const {}});
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Неизвестная ошибка']);
}
