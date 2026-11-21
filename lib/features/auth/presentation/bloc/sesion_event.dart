import '../../domain/usuario.dart';

/// Eventos del bloque de sesión.
sealed class SesionEvent {
  const SesionEvent();
}

/// Solicita iniciar sesión con correo y contraseña.
final class IniciarSesion extends SesionEvent {
  const IniciarSesion({required this.correo, required this.contrasena});

  final String correo;
  final String contrasena;
}

/// Solicita registrar una cuenta con correo y contraseña.
final class RegistrarUsuario extends SesionEvent {
  const RegistrarUsuario({required this.correo, required this.contrasena});

  final String correo;
  final String contrasena;
}

/// Informa que cambió la sesión en el repositorio.
final class SesionCambiada extends SesionEvent {
  const SesionCambiada(this.usuario, {this.error = false});

  final Usuario? usuario;
  final bool error;
}

/// Solicita cerrar la sesión actual.
final class CerrarSesion extends SesionEvent {
  const CerrarSesion();
}
