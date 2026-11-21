import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validadores.dart';
import '../bloc/sesion_bloc.dart';
import '../bloc/sesion_event.dart';
import '../bloc/sesion_state.dart';

/// Formulario para iniciar sesión o crear una cuenta.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _contrasena = TextEditingController();
  final TextEditingController _confirmacion = TextEditingController();

  bool _esRegistro = false;
  bool _verContrasena = false;
  bool _verConfirmacion = false;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!(_formulario.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    final bloc = context.read<SesionBloc>();
    final correo = _correo.text.trim();
    final contrasena = _contrasena.text;

    if (_esRegistro) {
      bloc.add(RegistrarUsuario(correo: correo, contrasena: contrasena));
    } else {
      bloc.add(IniciarSesion(correo: correo, contrasena: contrasena));
    }
  }

  void _alternarModo() {
    setState(() {
      _esRegistro = !_esRegistro;
      _confirmacion.clear();
      _formulario.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SesionBloc, SesionState>(
          builder: (context, estado) {
            final ocupado =
                estado is SesionIniciando || estado is SesionRegistrando;
            final mensajeError =
                estado is SesionError ? estado.mensaje : null;
            final textoBoton = ocupado
                ? (_esRegistro ? 'Creando cuenta…' : 'Ingresando…')
                : (_esRegistro ? 'Crear cuenta' : 'Ingresar');

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formulario,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            size: 64,
                            color: tema.colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Salud Digital',
                            textAlign: TextAlign.center,
                            style: tema.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _esRegistro
                                ? 'Crea una cuenta para usar tu agenda de salud.'
                                : 'Agenda de citas y medicamentos para el adulto mayor',
                            textAlign: TextAlign.center,
                            style: tema.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 28),
                          TextFormField(
                            controller: _correo,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: Validadores.correo,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contrasena,
                            obscureText: !_verContrasena,
                            textInputAction: _esRegistro
                                ? TextInputAction.next
                                : TextInputAction.done,
                            autofillHints: _esRegistro
                                ? const [AutofillHints.newPassword]
                                : const [AutofillHints.password],
                            onFieldSubmitted: _esRegistro
                                ? null
                                : (_) => _enviar(),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _verContrasena
                                    ? 'Ocultar contraseña'
                                    : 'Mostrar contraseña',
                                onPressed: () => setState(
                                  () => _verContrasena = !_verContrasena,
                                ),
                                icon: Icon(
                                  _verContrasena
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: Validadores.contrasena,
                          ),
                          if (_esRegistro) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmacion,
                              obscureText: !_verConfirmacion,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              onFieldSubmitted: (_) => _enviar(),
                              decoration: InputDecoration(
                                labelText: 'Confirmar contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _verConfirmacion
                                      ? 'Ocultar confirmación'
                                      : 'Mostrar confirmación',
                                  onPressed: () => setState(
                                    () => _verConfirmacion =
                                        !_verConfirmacion,
                                  ),
                                  icon: Icon(
                                    _verConfirmacion
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                              validator: (valor) => Validadores.confirmacion(
                                valor,
                                _contrasena.text,
                              ),
                            ),
                          ],
                          if (mensajeError != null) ...[
                            const SizedBox(height: 16),
                            Semantics(
                              liveRegion: true,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: tema.colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: tema.colorScheme.onErrorContainer,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        mensajeError,
                                        style: TextStyle(
                                          color: tema.colorScheme.onErrorContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(48, 48),
                            ),
                            onPressed: ocupado ? null : _enviar,
                            icon: ocupado
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _esRegistro ? Icons.person_add : Icons.login,
                                  ),
                            label: Text(textoBoton),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: ocupado ? null : _alternarModo,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48),
                            ),
                            child: Text(
                              _esRegistro
                                  ? '¿Ya tienes cuenta? Inicia sesión'
                                  : '¿No tienes cuenta? Crear cuenta',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
