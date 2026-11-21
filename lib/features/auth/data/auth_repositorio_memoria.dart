import 'dart:async';

import '../domain/usuario.dart';
import 'auth_repository.dart';

/// Implementación local para demostración y pruebas sin conexión a Firebase.
///
/// La app la usa como alternativa cuando Firebase no está inicializado; no crea
/// cuentas persistentes ni sustituye la autenticación real.
class AuthRepositorioMemoria implements AuthRepository {
  /// Si [conSesionDemo] es `true`, la app abre con una sesión ya iniciada.
  AuthRepositorioMemoria({bool conSesionDemo = true})
    : _usuario = conSesionDemo ? _usuarioDemo : null;

  static const Usuario _usuarioDemo = Usuario(
    id: 'demo',
    correo: 'demo@uandina.edu.pe',
    nombre: 'Usuario de demostración',
  );

  final StreamController<Usuario?> _controlador =
      StreamController<Usuario?>.broadcast();

  Usuario? _usuario;

  @override
  Future<Usuario?> usuarioActual() async => _usuario;

  @override
  Stream<Usuario?> get cambiosDeSesion async* {
    yield _usuario;
    yield* _controlador.stream;
  }

  @override
  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!correo.contains('@')) {
      throw const AuthException('Escribe un correo electrónico válido.');
    }
    if (contrasena.length < 8) {
      throw const AuthException('Usa al menos 8 caracteres.');
    }

    final usuario = Usuario(
      id: correo.toLowerCase(),
      correo: correo.toLowerCase(),
      nombre: correo.split('@').first,
    );
    _usuario = usuario;
    _controlador.add(usuario);
    return usuario;
  }

  @override
  Future<Usuario> registrar({
    required String correo,
    required String contrasena,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!correo.contains('@')) {
      throw const AuthException('Escribe un correo electrónico válido.');
    }
    if (contrasena.length < 8) {
      throw const AuthException('Usa al menos 8 caracteres.');
    }

    final usuario = Usuario(
      id: correo.toLowerCase(),
      correo: correo.toLowerCase(),
      nombre: correo.trim().split('@').first,
    );
    _usuario = usuario;
    _controlador.add(usuario);
    return usuario;
  }

  @override
  Future<void> cerrarSesion() async {
    _usuario = null;
    _controlador.add(null);
  }

  /// Libera el controlador del stream. Se usa en pruebas.
  Future<void> dispose() => _controlador.close();
}
