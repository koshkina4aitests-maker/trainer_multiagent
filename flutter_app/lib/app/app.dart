import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/di/service_locator.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class FitnessApp extends StatefulWidget {
  const FitnessApp({super.key});

  @override
  State<FitnessApp> createState() => _FitnessAppState();
}

class _FitnessAppState extends State<FitnessApp> {
  late final AuthBloc _authBloc;
  late final GoRouterWrapper _routerWrapper;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(AuthCheckRequested());
    _routerWrapper = GoRouterWrapper(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'FitApp',
        theme: AppTheme.light,
        routerConfig: _routerWrapper.router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru'),
          Locale('en'),
        ],
        locale: const Locale('ru'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class GoRouterWrapper {
  late final router;

  GoRouterWrapper(AuthBloc authBloc) {
    router = buildRouter(authBloc);
  }
}
