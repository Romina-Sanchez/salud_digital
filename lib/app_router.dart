import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/bloc/sesion_bloc.dart';
import 'features/auth/presentation/bloc/sesion_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/citas/presentation/pages/citas_page.dart';
import 'features/medicamentos/presentation/pages/medicamentos_page.dart';
import 'features/perfil/presentation/pages/perfil_page.dart';
import 'firebase_bootstrap.dart';
import 'home_shell.dart';

class AppRouter {
  AppRouter({
    required this.sesion,
    required this.refresh,
    required this.resultadoFirebase,
  });

  final SesionBloc sesion;
  final Listenable refresh;
  final ResultadoFirebase resultadoFirebase;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: _redirigir,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/acceso', builder: (_, _) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => HomeShell(
          ubicacion: state.matchedLocation,
          resultadoFirebase: resultadoFirebase,
          child: child,
        ),
        routes: [
          GoRoute(path: '/citas', builder: (_, _) => const CitasPage()),
          GoRoute(
            path: '/medicamentos',
            builder: (_, _) => const MedicamentosPage(),
          ),
          GoRoute(
            path: '/perfil',
            builder: (_, _) => PerfilPage(resultadoFirebase: resultadoFirebase),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        PaginaError(ubicacion: state.uri.toString()),
  );

  String? _redirigir(BuildContext context, GoRouterState state) {
    final ubicacion = state.matchedLocation;
    final estado = sesion.state;

    // Mientras se verifica la sesión, solo se muestra el splash.
    if (estado is SesionVerificando) {
      return ubicacion == '/' ? null : '/';
    }

    final autenticado = estado is SesionConUsuario;

    // Sin sesión: solo se permite el acceso.
    if (!autenticado) {
      return ubicacion == '/acceso' ? null : '/acceso';
    }

    // Con sesión: el splash y el acceso llevan a la agenda.
    if (ubicacion == '/' || ubicacion == '/acceso') {
      return '/citas';
    }

    return null;
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Preparando tu agenda…', style: tema.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class PaginaError extends StatelessWidget {
  const PaginaError({super.key, required this.ubicacion});

  final String ubicacion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: tema.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'No encontramos la ruta "$ubicacion".',
                style: tema.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
