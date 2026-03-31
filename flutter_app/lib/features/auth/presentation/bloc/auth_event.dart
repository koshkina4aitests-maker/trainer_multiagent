abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {
  GoogleSignInRequested();
}

class SignOutRequested extends AuthEvent {}
