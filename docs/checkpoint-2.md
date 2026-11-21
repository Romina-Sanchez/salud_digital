# Checkpoint S2 · Autenticación y estado de sesión

**Sesión:** S2 · Grupo B  
**Equipo:** ____________________  **Integrantes:** ____________________

Marca cada criterio después de comprobarlo en la consola, emulador o código. No
marques evidencia manual que todavía no se haya capturado.

## Lista de verificación

| Criterio | Estado | Evidencia / observación |
|---|---|---|
| Proveedor Correo electrónico/contraseña habilitado en Firebase | ☐ | Captura de Authentication → Método de acceso |
| `firebase_auth` declarado en `pubspec.yaml` y app compila | ☐ | `flutter analyze` |
| Registro crea usuario y deja sesión iniciada | ☐ | Authentication → Usuarios y captura de la app |
| Inicio de sesión funciona con la cuenta creada | ☐ | Captura o video corto |
| Credenciales incorrectas muestran un mensaje genérico | ☐ | Prueba manual |
| Cerrar sesión devuelve al acceso | ☐ | Captura o video corto |
| La sesión se restaura al reiniciar la app | ☐ | Captura o video corto |
| Correo, contraseña y confirmación se validan | ☐ | Pruebas unitarias y formulario |
| Contraseña oculta por defecto y puede mostrarse | ☐ | Captura de la app |
| Error visible en página y anunciado como live region | ☐ | Revisión con TalkBack |
| No se registran contraseñas en estados ni logs | ☐ | Revisión de código |
| Pruebas de validadores y BLoC pasan sin Firebase | ☐ | Salida de `flutter test` |

## Evidencias por guardar

- `docs/evidencias/auth-proveedor.png`
- `docs/evidencias/auth-registro.png`
- `docs/evidencias/auth-inicio-sesion.png`
- `docs/evidencias/auth-sesion-persistente.png`
- `docs/evidencias/auth-pruebas.txt`
- `docs/evidencias/auth-accesibilidad.png` o checklist TalkBack/escalado

## Notas de revisión

Resultado de revisión entre pares: __________________________________________

Hallazgos y correcciones pendientes: ________________________________________
