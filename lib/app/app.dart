import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../data/datasources/firebase/auth_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_event.dart';
import 'router.dart';

class ZenFlowApp extends StatefulWidget {
  const ZenFlowApp({super.key});

  @override
  State<ZenFlowApp> createState() => _ZenFlowAppState();
}

class _ZenFlowAppState extends State<ZenFlowApp> {
  late final AuthDatasource _authDatasource;
  late final AuthRepository _authRepository;
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authDatasource = AuthDatasource();
    _authRepository = AuthRepositoryImpl(_authDatasource);
    _authBloc = AuthBloc(_authRepository)..add(AuthCheckRequested());
    _appRouter = AppRouter(_authBloc);
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
        title: 'ZenFlow',
        theme: AppTheme.lightTheme,
        routerConfig: _appRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
