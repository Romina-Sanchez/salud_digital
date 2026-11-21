# Salud Digital del Adulto Mayor · código base

Aplicación Android en Flutter para la Unidad III de **Desarrollo de Software II
(SIS048)**. Este repositorio es la **base técnica** del proyecto integrador RSU
«Salud Digital del Adulto Mayor»: agenda de citas, recordatorios de medicamentos y
perfil, organizada con BLoC, repositorios y una estructura por funcionalidad.

> **Estado:** base S1 con el avance de autenticación S2: Firebase Authentication
> para registro, inicio, cierre y restauración de sesión. Las rutas protegidas,
> Firestore, las notificaciones y la IA se incorporan en las sesiones posteriores.

---

## 1. Qué incluye

- Proyecto Flutter para Android con paquete `pe.edu.uandina.salud_digital`.
- Arquitectura en tres capas y organización **feature-first**.
- Módulos `citas` y `medicamentos` completos sobre repositorios en memoria.
- Módulo `auth` con contrato de repositorio, repositorio Firebase y modo en memoria
  para desarrollo sin Firebase; el `SesionBloc` observa los cambios de sesión.
- Tema Material 3 con criterios de accesibilidad (texto base 18, objetivos de
  48 × 48, etiquetas semánticas y mensajes de error claros).
- Inicialización tolerante de Firebase: con Firebase inicializado se usa Firebase
  Authentication; si no está disponible, la app abre sin sesión y muestra un aviso.
- Pruebas de bloques, repositorios y una prueba de widget.
- Documentación: este README, un ADR y los Checkpoints S1 y S2.

## 2. Requisitos

| Herramienta | Versión o condición |
|---|---|
| Flutter | Canal estable (probado con 3.41.1 / Dart 3.11) |
| Android Studio | Versión estable con SDK de Android |
| Emulador | Imagen con servicios de Google Play |
| Node.js | 18.0.0 o superior (solo si se configura Firebase) |
| Firebase CLI y FlutterFire CLI | `firebase-tools` y `flutterfire_cli` |

Verificación rápida:

```bash
flutter --version
flutter doctor
flutter doctor --android-licenses
flutter emulators && flutter devices
```

## 3. Puesta en marcha

```bash
# 1. Dependencias
flutter pub get

# 2. Ejecutar; Firebase Authentication se usa si Firebase está inicializado
flutter run
```

La configuración de Android incluida corresponde al proyecto `appflutter-f037b`.
Si se cambia de proyecto Firebase, ejecutar `flutterfire configure` con el nuevo
proyecto y revisar el `applicationId` de Android.

Al inicializar correctamente, la consola imprime:

```
Firebase conectado: <identificador-del-proyecto>
```

Si Firebase no está configurado, la app continúa con repositorios en memoria y
presenta el acceso sin una sesión de demostración.

La inicialización usa `DefaultFirebaseOptions.currentPlatform` en
`lib/firebase_bootstrap.dart`. Para este proyecto hay opciones configuradas para
Android en `lib/firebase_options.dart` y `android/app/google-services.json`.
En Firebase Console debe estar habilitado **Authentication → Método de acceso →
Correo electrónico/contraseña**. La dependencia `firebase_auth` conecta el
repositorio de autenticación con ese proveedor.

El proyecto usa `minSdk` 24 (`flutter.minSdkVersion`), por encima del mínimo 23 que
exige Firebase para Android, y declara el permiso `INTERNET` en el manifiesto.

### Cuenta de prueba

Con Firebase Authentication habilitado, crea la cuenta desde el formulario **Crear
cuenta** de la app. Usa un correo y contraseña ficticios de prueba; no compartas
credenciales reales ni datos de salud. En modo memoria el flujo solo sirve para
demostrar la interfaz y no crea cuentas persistentes.

## 4. Estructura

```text
lib/
├── main.dart                     # Arranque: Firebase y runApp
├── app.dart                      # Providers, tema y flujo de sesión
├── firebase_bootstrap.dart       # Inicialización tolerante de Firebase
├── home_shell.dart               # Navegación principal (Citas, Medicamentos, Perfil)
├── core/
│   ├── theme/app_theme.dart      # Material 3 y tipografía accesible
│   ├── utils/                     # Fechas, validadores y errores de Auth
│   └── widgets/                  # Estados vacío/error y aviso de configuración
└── features/
    ├── auth/
    │   ├── domain/usuario.dart
    │   ├── data/                 # Contrato + repositorios Firebase y memoria
    │   └── presentation/         # SesionBloc y formulario de acceso/registro
    ├── citas/
    │   ├── domain/cita.dart
    │   ├── data/                 # CitasRepository + memoria
    │   └── presentation/         # Bloc, página, tarjeta y formulario
    ├── medicamentos/
    │   ├── domain/medicamento.dart
    │   ├── data/                 # MedicamentosRepository + memoria
    │   └── presentation/         # Bloc, página y formulario
    └── perfil/presentation/      # Estado de la sesión y de Firebase
```

### Regla de dependencia

```text
presentation  →  business logic  →  data  →  fuente de datos
   (UI)            (Bloc/Cubit)     (Repository)   (memoria / Firestore)
```

La presentación no conoce Firestore; la capa de datos no conoce widgets. El bloque
recibe el repositorio por constructor y nunca lo instancia.

## 5. Decisiones de arquitectura

- **BLoC** para el estado: eventos y estados explícitos, pruebas con `bloc_test`.
- **Repositorios** como contrato: en S1 la implementación es en memoria; en S4 se
  sustituye por Firestore sin tocar los bloques ni las pantallas.
- **Feature-first**: cada funcionalidad agrupa `domain`, `data` y `presentation`.
- **Material 3** y accesibilidad desde el primer commit.
- **Firebase opcional en desarrollo**: la app no depende de la nube para arrancar.

El detalle está en [`docs/adr/0001-arquitectura-bloc-firebase.md`](docs/adr/0001-arquitectura-bloc-firebase.md).

## 6. Calidad

```bash
flutter analyze     # sin errores
flutter test        # pruebas de bloques, repositorios y widget
```

O en una sola línea:

```bash
./tool/verificar.sh
```

Ejecuta estos comandos después de los cambios para verificar análisis estático y
pruebas. La verificación de Firebase real y accesibilidad con TalkBack requiere un
emulador/dispositivo y la consola del proyecto.

Cobertura actual de la base:

| Prueba | Qué verifica |
|---|---|
| `citas_bloc_test.dart` | Carga, creación, eliminación y estado de error |
| `citas_repositorio_memoria_test.dart` | Contrato del repositorio y lista inmutable |
| `medicamentos_bloc_test.dart` | Carga y creación de medicamentos |
| `sesion_bloc_test.dart` | Restauración desde stream, registro, cierre y errores |
| `validadores_test.dart` | Validación de correo, contraseña y confirmación |
| `login_page_test.dart` | Mensajes de validación y alternancia registro/acceso |
| `widget_test.dart` | La app abre en la agenda de citas |

## 7. Ruta de la unidad

| Sesión | Qué se agrega a esta base |
|---|---|
| S1 | Estructura, BLoC, repositorios, tema y Firebase inicializado |
| S2 | Firebase Authentication, sesión persistente y formularios accesibles |
| S3 | GoRouter, rutas protegidas y tema Material 3 completo |
| S4–S6 | Firestore, reglas, CRUD en tiempo real y tablero de adherencia |
| S7 | Notificaciones locales y permisos de Android |
| S8 | Modo claro con IA y guardarraíles |
| S9 | Pruebas unitarias, de widgets y de integración |
| S10–S11 | CI con GitHub Actions, AAB firmado y distribución |

## 8. Datos, privacidad y ética

- Solo se usan datos ficticios. No se incorporan nombres, documentos ni historias
  clínicas reales.
- La aplicación no diagnostica, no prescribe y no modifica dosis.
- No se versionan keystore, `key.properties`, claves privadas ni archivos `.env`.
- Los archivos de configuración de Firebase contienen identificadores, no secretos;
  se versionan según la política del equipo.

## 9. Uso de asistentes de IA

- Herramienta: la indicada por el equipo.
- Uso: explicación de conceptos, revisión de borradores y generación de pruebas.
- Verificación: cada fragmento se ejecutó con `flutter analyze` y `flutter test`, y
  el equipo puede explicarlo.
- Datos compartidos: ninguno. No se enviaron datos personales ni de salud.

## 10. Créditos

Universidad Andina del Cusco · Facultad de Ingeniería y Arquitectura · Escuela
Profesional de Ingeniería de Sistemas · SIS048 · Semestre 2026-II.
Docente: Mtro. Ing. Yover Collantes Valer.
