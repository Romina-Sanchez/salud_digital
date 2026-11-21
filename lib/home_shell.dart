import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/widgets/aviso_configuracion.dart';
import 'firebase_bootstrap.dart';

/// Contenedor principal con la navegación declarativa entre funcionalidades.
class HomeShell extends StatelessWidget {
  const HomeShell({
    super.key,
    required this.ubicacion,
    required this.resultadoFirebase,
    required this.child,
  });

  final String ubicacion;
  final ResultadoFirebase resultadoFirebase;
  final Widget child;

  int get _indiceActual {
    if (ubicacion.startsWith('/medicamentos')) return 1;
    if (ubicacion.startsWith('/perfil')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (!resultadoFirebase.inicializado)
            AvisoConfiguracion(
              mensaje: resultadoFirebase.mensaje,
              detalle: resultadoFirebase.detalle,
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (nuevo) {
          const rutas = ['/citas', '/medicamentos', '/perfil'];
          context.go(rutas[nuevo]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Citas',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Medicamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
