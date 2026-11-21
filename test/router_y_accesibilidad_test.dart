import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/app.dart';
import 'package:salud_digital/app_router.dart';
import 'package:salud_digital/core/theme/app_theme.dart';
import 'package:salud_digital/features/auth/data/auth_repositorio_memoria.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_bloc.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_event.dart';
import 'package:salud_digital/features/auth/presentation/pages/login_page.dart';
import 'package:salud_digital/features/citas/data/citas_repositorio_memoria.dart';
import 'package:salud_digital/features/citas/presentation/bloc/citas_bloc.dart';
import 'package:salud_digital/features/citas/presentation/bloc/citas_event.dart';
import 'package:salud_digital/features/medicamentos/data/medicamentos_repositorio_memoria.dart';
import 'package:salud_digital/features/medicamentos/presentation/bloc/medicamentos_bloc.dart';
import 'package:salud_digital/features/medicamentos/presentation/bloc/medicamentos_event.dart';
import 'package:salud_digital/firebase_bootstrap.dart';
import 'package:salud_digital/router_refresh.dart';

void main() {
  Widget envolverRouter({
    required SesionBloc sesion,
    required AppRouter appRouter,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SesionBloc>.value(value: sesion),
        BlocProvider<CitasBloc>(
          create: (_) =>
              CitasBloc(CitasRepositorioMemoria())..add(const CargarCitas()),
        ),
        BlocProvider<MedicamentosBloc>(
          create: (_) =>
              MedicamentosBloc(MedicamentosRepositorioMemoria())
                ..add(const CargarMedicamentos()),
        ),
      ],
      child: MaterialApp.router(routerConfig: appRouter.router),
    );
  }

  group('GoRouter y protección de rutas', () {
    testWidgets(
      'sin sesión redirige a /acceso aunque se intente abrir /perfil',
      (tester) async {
        final repo = AuthRepositorioMemoria(conSesionDemo: false);
        final sesion = SesionBloc(repo);
        final refresh = RouterRefresh(sesion.stream);
        final appRouter = AppRouter(
          sesion: sesion,
          refresh: refresh,
          resultadoFirebase: ResultadoFirebase.noConfigurado,
        );

        addTearDown(() async {
          appRouter.router.dispose();
          refresh.dispose();
          await sesion.close();
        });

        await tester.pumpWidget(
          envolverRouter(sesion: sesion, appRouter: appRouter),
        );
        await tester.pumpAndSettle();

        appRouter.router.go('/perfil');
        await tester.pumpAndSettle();

        expect(find.text('Ingresar'), findsOneWidget);
        expect(find.text('Mi perfil'), findsNothing);
      },
    );

    testWidgets('con sesión redirige de /acceso hacia /citas', (tester) async {
      await tester.pumpWidget(
        AppSalud(
          authRepository: AuthRepositorioMemoria(conSesionDemo: true),
          citasRepository: CitasRepositorioMemoria(),
          medicamentosRepository: MedicamentosRepositorioMemoria(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mis citas'), findsOneWidget);
    });

    testWidgets('cerrar sesión redirige automáticamente a /acceso', (
      tester,
    ) async {
      final repo = AuthRepositorioMemoria(conSesionDemo: true);
      final sesion = SesionBloc(repo);
      final refresh = RouterRefresh(sesion.stream);
      final appRouter = AppRouter(
        sesion: sesion,
        refresh: refresh,
        resultadoFirebase: ResultadoFirebase.noConfigurado,
      );

      addTearDown(() async {
        appRouter.router.dispose();
        refresh.dispose();
        await sesion.close();
      });

      await tester.pumpWidget(
        envolverRouter(sesion: sesion, appRouter: appRouter),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mis citas'), findsOneWidget);

      sesion.add(const CerrarSesion());
      await tester.pumpAndSettle();

      expect(find.text('Ingresar'), findsOneWidget);
    });

    testWidgets('ruta desconocida muestra PaginaError', (tester) async {
      final repo = AuthRepositorioMemoria(conSesionDemo: true);
      final sesion = SesionBloc(repo);
      final refresh = RouterRefresh(sesion.stream);
      final appRouter = AppRouter(
        sesion: sesion,
        refresh: refresh,
        resultadoFirebase: ResultadoFirebase.noConfigurado,
      );

      addTearDown(() async {
        appRouter.router.dispose();
        refresh.dispose();
        await sesion.close();
      });

      await tester.pumpWidget(
        envolverRouter(sesion: sesion, appRouter: appRouter),
      );
      await tester.pumpAndSettle();

      appRouter.router.go('/ruta-que-no-existe');
      await tester.pumpAndSettle();

      expect(find.text('Página no encontrada'), findsOneWidget);
    });
  });

  group('Temas y accesibilidad', () {
    testWidgets('LoginPage soporta texto escalado al 200% sin overflow', (
      tester,
    ) async {
      final sesion = SesionBloc(AuthRepositorioMemoria(conSesionDemo: false));
      addTearDown(sesion.close);

      await tester.pumpWidget(
        BlocProvider<SesionBloc>.value(
          value: sesion,
          child: MaterialApp(
            theme: AppTheme.claro,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2.0)),
              child: child!,
            ),
            home: const LoginPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'cumple guías de contraste y objetivos táctiles en alto contraste',
      (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(highContrast: true),
            child: AppSalud(
              authRepository: AuthRepositorioMemoria(conSesionDemo: false),
              citasRepository: CitasRepositorioMemoria(),
              medicamentosRepository: MedicamentosRepositorioMemoria(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      },
    );
  });
}
