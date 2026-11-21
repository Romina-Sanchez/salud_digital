import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/errores_auth.dart';
import '../domain/usuario.dart';
import 'auth_repository.dart';

class AuthFirebaseRepository implements AuthRepository {
  AuthFirebaseRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Usuario? _mapear(User? usuarioFirebase) {
    if (usuarioFirebase == null) return null;

    final correo = usuarioFirebase.email ?? '';
    final nombreFirebase = usuarioFirebase.displayName?.trim();
    final nombre = nombreFirebase != null && nombreFirebase.isNotEmpty
        ? nombreFirebase
        : correo.split('@').first;

    return Usuario(id: usuarioFirebase.uid, correo: correo, nombre: nombre);
  }

  Usuario _usuarioDe(UserCredential credencial) {
    final usuario = _mapear(credencial.user);
    if (usuario == null) {
      throw const AuthException('Firebase no devolvió los datos del usuario.');
    }
    return usuario;
  }

  @override
  Future<Usuario?> usuarioActual() async => _mapear(_auth.currentUser);

  @override
  Stream<Usuario?> get cambiosDeSesion => _auth.authStateChanges().map(_mapear);

  @override
  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
      return _usuarioDe(credencial);
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeDeErrorAutenticacion(error));
    }
  }

  @override
  Future<Usuario> registrar({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
      return _usuarioDe(credencial);
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeDeErrorAutenticacion(error));
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeDeErrorAutenticacion(error));
    }
  }
}
