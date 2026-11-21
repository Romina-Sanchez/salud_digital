import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/features/auth/data/auth_repositorio_memoria.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_bloc.dart';
import 'package:salud_digital/features/auth/presentation/pages/login_page.dart';

void main() {
  Future<void> mostrarFormulario(
    WidgetTester tester,
    AuthRepositorioMemoria repositorio,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SesionBloc>(
          create: (_) => SesionBloc(repositorio),
          child: const LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('valida correo y contraseña vacíos', (tester) async {
    final repositorio = AuthRepositorioMemoria(conSesionDemo: false);
    addTearDown(repositorio.dispose);
    await mostrarFormulario(tester, repositorio);

    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe tu correo electrónico.'), findsOneWidget);
    expect(find.text('Escribe una contraseña.'), findsOneWidget);
  });

  testWidgets('muestra confirmación al cambiar a crear cuenta', (tester) async {
    final repositorio = AuthRepositorioMemoria(conSesionDemo: false);
    addTearDown(repositorio.dispose);
    await mostrarFormulario(tester, repositorio);

    await tester.tap(find.text('¿No tienes cuenta? Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar contraseña'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });
}
