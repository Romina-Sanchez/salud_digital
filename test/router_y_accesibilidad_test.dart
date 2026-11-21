import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:salud_digital/app.dart';
import 'package:salud_digital/app_router.dart';
import 'package:salud_digital/core/theme/app_theme.dart';
import 'package:salud_digital/features/auth/data/auth_repositorio_memoria.dart';
import 'package:salud_digital/features/citas/data/citas_repositorio_memoria.dart';
import 'package:salud_digital/features/medicamentos/data/medicamentos_repositorio_memoria.dart';

void main() {
  group('GoRouter y protección de rutas', () {
    testWidgets(
      'sin sesión redirige a /acceso aunque se intente abrir /perfil',
      (tester) async {
        await tester.pumpWidget(
          AppSalud(
            authRepository: AuthRepositorioMemoria(conSesionDemo: false),
            citasRepository: CitasRepositorioMemoria(),
            medicamentosRepository: MedicamentosRepositorioMemoria(),
            rutaInicial: '/perfil',
          ),
        );
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
          rutaInicial: '/acceso',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mis citas'), findsOneWidget);
    });

    testWidgets('cerrar sesión desde Perfil redirige automáticamente a /acceso', (
      tester,
    ) async {
      await tester.pumpWidget(
        AppSalud(
          authRepository: AuthRepositorioMemoria(conSesionDemo: true),
          citasRepository: CitasRepositorioMemoria(),
          medicamentosRepository: MedicamentosRepositorioMemoria(),
        ),
      );
      await tester.pumpAndSettle();

      // Entrar a Perfil desde la barra inferior
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      expect(find.text('Mi perfil'), findsOneWidget);

      // Desplazar hasta el botón Cerrar sesión y tocarlo
      final botonCerrar = find.text('Cerrar sesión');
      await tester.scrollUntilVisible(botonCerrar, 200);
      await tester.tap(botonCerrar);
      await tester.pumpAndSettle();

      // Confirmar en el AlertDialog (el segundo texto 'Cerrar sesión' en pantalla)
      await tester.tap(find.text('Cerrar sesión').last);
      await tester.pumpAndSettle();

      expect(find.text('Ingresar'), findsOneWidget);
    });

    testWidgets('ruta desconocida muestra PaginaError', (tester) async {
      await tester.pumpWidget(
        AppSalud(
          authRepository: AuthRepositorioMemoria(conSesionDemo: true),
          citasRepository: CitasRepositorioMemoria(),
          medicamentosRepository: MedicamentosRepositorioMemoria(),
        ),
      );
      await tester.pumpAndSettle();

      final contexto = tester.element(find.text('Mis citas'));
      GoRouter.of(contexto).go('/ruta-que-no-existe');
      await tester.pumpAndSettle();

      expect(find.byType(PaginaError), findsOneWidget);
    });
  });

  group('Temas y accesibilidad', () {
    testWidgets('LoginPage soporta texto escalado al 200% sin overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: AppSalud(
            authRepository: AuthRepositorioMemoria(conSesionDemo: false),
            citasRepository: CitasRepositorioMemoria(),
            medicamentosRepository: MedicamentosRepositorioMemoria(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Salud Digital'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, timeout: const Timeout(Duration(seconds: 15)));

    testWidgets(
      'configura temas claro, oscuro y alto contraste con área táctil mínima de 48x48',
      (tester) async {
        expect(AppTheme.claro.colorScheme.brightness, Brightness.light);
        expect(AppTheme.oscuro.colorScheme.brightness, Brightness.dark);
        expect(
          AppTheme.altoContrasteClaro.colorScheme.brightness,
          Brightness.light,
        );
        expect(
          AppTheme.altoContrasteOscuro.colorScheme.brightness,
          Brightness.dark,
        );

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
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final tamanoBoton = tester.getSize(
          find.widgetWithText(FilledButton, 'Ingresar'),
        );
        expect(tamanoBoton.width, greaterThanOrEqualTo(48));
        expect(tamanoBoton.height, greaterThanOrEqualTo(48));
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );
  });
}
