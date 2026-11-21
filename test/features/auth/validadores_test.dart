import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/core/utils/validadores.dart';

void main() {
  group('Validadores.correo', () {
    test('rechaza el correo vacío', () {
      expect(Validadores.correo(''), 'Escribe tu correo electrónico.');
    });

    test('rechaza un correo sin un único @', () {
      expect(Validadores.correo('usuario-ejemplo.com'), isNotNull);
      expect(Validadores.correo('uno@@ejemplo.com'), isNotNull);
    });

    test('acepta un correo válido con espacios exteriores', () {
      expect(Validadores.correo('  persona@ejemplo.com  '), isNull);
    });
  });

  group('Validadores.contrasena', () {
    test('requiere contraseña y mínimo ocho caracteres', () {
      expect(Validadores.contrasena(''), 'Escribe una contraseña.');
      expect(Validadores.contrasena('1234567'), 'Usa al menos 8 caracteres.');
      expect(Validadores.contrasena('12345678'), isNull);
    });
  });

  group('Validadores.confirmacion', () {
    test('requiere confirmar y que los valores coincidan', () {
      expect(
        Validadores.confirmacion('', 'secreta123'),
        'Repite la contraseña.',
      );
      expect(
        Validadores.confirmacion('diferente', 'secreta123'),
        'Las contraseñas no coinciden.',
      );
      expect(Validadores.confirmacion('secreta123', 'secreta123'), isNull);
    });
  });
}
