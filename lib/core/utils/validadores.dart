class Validadores {
  const Validadores._();

  static String? correo(String? valor) {
    final texto = (valor ?? '').trim();

    if (texto.isEmpty) return 'Escribe tu correo electrónico.';
    if (texto.contains(' ')) return 'El correo no puede tener espacios.';

    final partes = texto.split('@');
    if (partes.length != 2) return 'El correo debe tener un solo @.';

    final usuario = partes.first;
    final dominio = partes.last;

    if (usuario.isEmpty || dominio.isEmpty) {
      return 'El correo está incompleto.';
    }

    if (!dominio.contains('.') ||
        dominio.startsWith('.') ||
        dominio.endsWith('.')) {
      return 'El dominio del correo no parece válido.';
    }

    return null;
  }

  static String? contrasena(String? valor) {
    final texto = valor ?? '';

    if (texto.isEmpty) return 'Escribe una contraseña.';
    if (texto.length < 8) return 'Usa al menos 8 caracteres.';

    return null;
  }

  static String? confirmacion(String? valor, String contrasena) {
    if ((valor ?? '').isEmpty) return 'Repite la contraseña.';
    if (valor != contrasena) return 'Las contraseñas no coinciden.';

    return null;
  }
}
