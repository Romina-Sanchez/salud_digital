import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../../domain/usuario.dart';
import 'sesion_event.dart';
import 'sesion_state.dart';

class SesionBloc extends Bloc<SesionEvent, SesionState> {
  SesionBloc(this._repositorio) : super(const SesionVerificando()) {
    on<IniciarSesion>(_alIniciar);
    on<RegistrarUsuario>(_alRegistrar);
    on<CerrarSesion>(_alCerrar);
    on<SesionCambiada>(_alCambiar);

    _suscripcion = _repositorio.cambiosDeSesion.listen(
      (usuario) {
        if (!isClosed) add(SesionCambiada(usuario));
      },
      onError: (Object _) {
        if (!isClosed) {
          add(const SesionCambiada(null, error: true));
        }
      },
    );
  }

  final AuthRepository _repositorio;
  late final StreamSubscription<Usuario?> _suscripcion;

  void _alCambiar(SesionCambiada event, Emitter<SesionState> emit) {
    if (event.error) {
      emit(const SesionError('No se pudo verificar la sesión.'));
      return;
    }

    final usuario = event.usuario;
    emit(
      usuario == null ? const SesionSinUsuario() : SesionConUsuario(usuario),
    );
  }

  Future<void> _alIniciar(
    IniciarSesion event,
    Emitter<SesionState> emit,
  ) async {
    emit(const SesionIniciando());
    try {
      await _repositorio.iniciarSesion(
        correo: event.correo,
        contrasena: event.contrasena,
      );
      // El cambio de sesión llega por el stream.
    } on AuthException catch (error) {
      emit(SesionError(error.mensaje));
    } catch (_) {
      emit(const SesionError('No se pudo iniciar sesión. Intenta nuevamente.'));
    }
  }

  Future<void> _alRegistrar(
    RegistrarUsuario event,
    Emitter<SesionState> emit,
  ) async {
    emit(const SesionRegistrando());
    try {
      await _repositorio.registrar(
        correo: event.correo,
        contrasena: event.contrasena,
      );
      // El cambio de sesión llega por el stream.
    } on AuthException catch (error) {
      emit(SesionError(error.mensaje));
    } catch (_) {
      emit(
        const SesionError('No se pudo crear la cuenta. Intenta nuevamente.'),
      );
    }
  }

  Future<void> _alCerrar(CerrarSesion event, Emitter<SesionState> emit) async {
    try {
      await _repositorio.cerrarSesion();
      // La sesión sin usuario llega por el stream.
    } on AuthException catch (error) {
      emit(SesionError(error.mensaje));
    } catch (_) {
      emit(const SesionError('No se pudo cerrar la sesión.'));
    }
  }

  @override
  Future<void> close() async {
    await _suscripcion.cancel();
    await super.close();
  }
}
