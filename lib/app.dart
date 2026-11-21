import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_firebase_repository.dart';
import 'features/auth/data/auth_repositorio_memoria.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/sesion_bloc.dart';
import 'features/citas/data/citas_repositorio_memoria.dart';
import 'features/citas/data/citas_repository.dart';
import 'features/citas/presentation/bloc/citas_bloc.dart';
import 'features/citas/presentation/bloc/citas_event.dart';
import 'features/medicamentos/data/medicamentos_repositorio_memoria.dart';
import 'features/medicamentos/data/medicamentos_repository.dart';
import 'features/medicamentos/presentation/bloc/medicamentos_bloc.dart';
import 'features/medicamentos/presentation/bloc/medicamentos_event.dart';
import 'firebase_bootstrap.dart';
import 'router_refresh.dart';

/// Raíz de la aplicación.
class AppSalud extends StatefulWidget {
  const AppSalud({
    super.key,
    this.resultadoFirebase = ResultadoFirebase.noConfigurado,
    this.authRepository,
    this.citasRepository,
    this.medicamentosRepository,
  });

  final ResultadoFirebase resultadoFirebase;
  final AuthRepository? authRepository;
  final CitasRepository? citasRepository;
  final MedicamentosRepository? medicamentosRepository;

  @override
  State<AppSalud> createState() => _AppSaludState();
}

class _AppSaludState extends State<AppSalud> {
  late final AuthRepository _authRepository;
  late final CitasRepository _citasRepository;
  late final MedicamentosRepository _medicamentosRepository;
  late final SesionBloc _sesionBloc;
  late final RouterRefresh _refresh;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authRepository =
        widget.authRepository ??
        (widget.resultadoFirebase.inicializado
            ? AuthFirebaseRepository()
            : AuthRepositorioMemoria(conSesionDemo: false));
    _citasRepository = widget.citasRepository ?? CitasRepositorioMemoria.demo();
    _medicamentosRepository =
        widget.medicamentosRepository ?? MedicamentosRepositorioMemoria.demo();

    _sesionBloc = SesionBloc(_authRepository);
    _refresh = RouterRefresh(_sesionBloc.stream);
    _appRouter = AppRouter(
      sesion: _sesionBloc,
      refresh: _refresh,
      resultadoFirebase: widget.resultadoFirebase,
    );
  }

  @override
  void dispose() {
    _appRouter.router.dispose();
    _refresh.dispose();
    _sesionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<CitasRepository>.value(value: _citasRepository),
        RepositoryProvider<MedicamentosRepository>.value(
          value: _medicamentosRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SesionBloc>.value(value: _sesionBloc),
          BlocProvider<CitasBloc>(
            create: (_) =>
                CitasBloc(_citasRepository)..add(const CargarCitas()),
          ),
          BlocProvider<MedicamentosBloc>(
            create: (_) =>
                MedicamentosBloc(_medicamentosRepository)
                  ..add(const CargarMedicamentos()),
          ),
        ],
        child: MaterialApp.router(
          title: 'Salud Digital',
          debugShowCheckedModeBanner: false,
          routerConfig: _appRouter.router,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          highContrastTheme: AppTheme.altoContrasteClaro,
          highContrastDarkTheme: AppTheme.altoContrasteOscuro,
          themeMode: ThemeMode.system,
          locale: const Locale('es', 'PE'),
          supportedLocales: const [Locale('es', 'PE')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
