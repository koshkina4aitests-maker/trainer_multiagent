import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fitness_app/features/auth/domain/entities/user.dart';
import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_out.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}
class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late MockAuthRepository mockRepo;
  late MockSignInWithGoogle mockSignIn;
  late MockSignOutUseCase mockSignOut;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockSignIn = MockSignInWithGoogle();
    mockSignOut = MockSignOutUseCase();
  });

  const testUser = AppUser(id: '1', name: 'Test', email: 'test@test.com');

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when token exists',
      build: () {
        when(() => mockRepo.isAuthenticated).thenReturn(true);
        when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => testUser);
        return AuthBloc(mockSignIn, mockSignOut, mockRepo);
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when no token',
      build: () {
        when(() => mockRepo.isAuthenticated).thenReturn(false);
        return AuthBloc(mockSignIn, mockSignOut, mockRepo);
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful Google Sign-In',
      build: () {
        when(() => mockRepo.isAuthenticated).thenReturn(false);
        when(() => mockSignIn()).thenAnswer((_) async => testUser);
        return AuthBloc(mockSignIn, mockSignOut, mockRepo);
      },
      act: (bloc) => bloc.add(GoogleSignInRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on Sign-In failure',
      build: () {
        when(() => mockRepo.isAuthenticated).thenReturn(false);
        when(() => mockSignIn()).thenThrow(Exception('Auth error'));
        return AuthBloc(mockSignIn, mockSignOut, mockRepo);
      },
      act: (bloc) => bloc.add(GoogleSignInRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] on sign out',
      build: () {
        when(() => mockRepo.isAuthenticated).thenReturn(true);
        when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => testUser);
        when(() => mockSignOut()).thenAnswer((_) async {});
        return AuthBloc(mockSignIn, mockSignOut, mockRepo);
      },
      act: (bloc) => bloc.add(SignOutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });
}
