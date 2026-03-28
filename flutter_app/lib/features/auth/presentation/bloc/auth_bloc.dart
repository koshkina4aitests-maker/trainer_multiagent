import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signIn;
  final SignOutUseCase _signOut;
  final AuthRepository _repo;

  AuthBloc(this._signIn, this._signOut, this._repo) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<GoogleSignInRequested>(_onSignIn);
    on<SignOutRequested>(_onSignOut);
  }

  Future<void> _onCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    if (_repo.isAuthenticated) {
      final user = await _repo.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
        return;
      }
    }
    emit(AuthUnauthenticated());
  }

  Future<void> _onSignIn(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _signIn();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Ошибка входа: ${e.toString()}'));
    }
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    await _signOut();
    emit(AuthUnauthenticated());
  }
}
