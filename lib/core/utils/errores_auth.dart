import 'package:firebase_auth/firebase_auth.dart';

String mensajeDeErrorAutenticacion(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'El correo no tiene un formato válido.';

    case 'invalid-credential' ||
        'invalid-login-credentials' ||
        'user-not-found' ||
        'wrong-password':
      return 'El correo o la contraseña no son correctos.';

    case 'user-disabled':
      return 'Esta cuenta está deshabilitada.';

    case 'email-already-in-use':
      return 'Ya existe una cuenta con ese correo. Inicia sesión.';

    case 'weak-password':
      return 'La contraseña es demasiado débil. Usa al menos 8 caracteres.';

    case 'too-many-requests':
      return 'Demasiados intentos. Espera unos minutos.';

    case 'network-request-failed':
      return 'Sin conexión. Revisa tu red e inténtalo de nuevo.';

    case 'operation-not-allowed':
      return 'El acceso con correo y contraseña no está habilitado.';

    default:
      return 'No se pudo completar la operación. Inténtalo nuevamente.';
  }
}
