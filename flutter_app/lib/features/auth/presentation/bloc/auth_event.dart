abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}
