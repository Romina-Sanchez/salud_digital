import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salud_digital/features/auth/data/auth_repositorio_memoria.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_bloc.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_event.dart';
import 'package:salud_digital/features/auth/presentation/bloc/sesion_state.dart';

void main() {
  group('SesionBloc', () {
    blocTest<SesionBloc, SesionState>(
      'restaura la sesión existente desde el stream del repositorio',
      build: () => SesionBloc(AuthRepositorioMemoria()),
      wait: const Duration(milliseconds: 20),
      expect: () => <Matcher>[
        isA<SesionConUsuario>().having(
          (estado) => estado.usuario.correo,
          'correo',
          'demo@uandina.edu.pe',
        ),
      ],
    );

    blocTest<SesionBloc, SesionState>(
      'emite SesionSinUsuario cuando el stream inicia vacío',
      build: () => SesionBloc(
        AuthRepositorioMemoria(conSesionDemo: false),
      ),
      wait: const Duration(milliseconds: 20),
      expect: () => <Matcher>[isA<SesionSinUsuario>()],
    );

    blocTest<SesionBloc, SesionState>(
      'muestra un error si falla el inicio de sesión',
      build: () => SesionBloc(
        AuthRepositorioMemoria(conSesionDemo: false),
      ),
      act: (bloc) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(
          const IniciarSesion(
            correo: 'demo@uandina.edu.pe',
            contrasena: '123',
          ),
        );
      },
      wait: const Duration(milliseconds: 400),
      expect: () => <Matcher>[
        isA<SesionSinUsuario>(),
        isA<SesionIniciando>(),
        isA<SesionError>().having(
          (estado) => estado.mensaje,
          'mensaje',
          contains('8'),
        ),
      ],
    );

    blocTest<SesionBloc, SesionState>(
      'registra una cuenta y recibe el usuario desde el stream',
      build: () => SesionBloc(
        AuthRepositorioMemoria(conSesionDemo: false),
      ),
      act: (bloc) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(
          const RegistrarUsuario(
            correo: 'nueva@uandina.edu.pe',
            contrasena: 'contrasena-segura',
          ),
        );
      },
      wait: const Duration(milliseconds: 400),
      expect: () => <Matcher>[
        isA<SesionSinUsuario>(),
        isA<SesionRegistrando>(),
        isA<SesionConUsuario>().having(
          (estado) => estado.usuario.correo,
          'correo',
          'nueva@uandina.edu.pe',
        ),
      ],
    );

    blocTest<SesionBloc, SesionState>(
      'cierra la sesión y recibe el estado desde el stream',
      build: () => SesionBloc(AuthRepositorioMemoria()),
      act: (bloc) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const CerrarSesion());
      },
      expect: () => <Matcher>[
        isA<SesionConUsuario>(),
        isA<SesionSinUsuario>(),
      ],
    );
  });
}
