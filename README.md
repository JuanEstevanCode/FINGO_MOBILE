# FINGO Mobile

Aplicación multiplataforma de finanzas personales creada con Flutter. Permite crear una cuenta e iniciar sesión, consultar el resumen financiero, administrar presupuestos y registrar ingresos y gastos. La aplicación móvil se comunica con el backend de FINGO mediante una API HTTP JSON.

## Contenido

- [Requisitos](#requisitos)
- [Puesta en marcha](#puesta-en-marcha)
- [Configuración del backend](#configuración-del-backend)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Flujos principales](#flujos-principales)
- [API utilizada](docs/api.md)
- [Convenciones para cambios](#convenciones-para-cambios)

## Requisitos

- Flutter compatible con el SDK de Dart `^3.13.5`, según `pubspec.yaml`.
- Un dispositivo, emulador o navegador compatible con la plataforma objetivo.
- Acceso al backend de FINGO para utilizar autenticación y datos financieros.

Comprueba la instalación local de Flutter con `flutter doctor`.

## Puesta en marcha

Desde la raíz del repositorio:

```sh
flutter pub get
flutter run
```

La aplicación inicia en la pantalla de acceso. Para compilar una plataforma concreta, usa los comandos habituales de Flutter, por ejemplo `flutter build apk` o `flutter build web`.

## Configuración del backend

La URL base se define en `lib/core/api/api_client.dart` mediante la constante de compilación `API_BASE_URL`. Si no se proporciona, el valor predeterminado es `https://fingo-backend-eag1.onrender.com`.

Para apuntar a un backend distinto, pasa la URL al ejecutar o compilar:

```sh
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Usa la dirección accesible desde el dispositivo o emulador; `localhost` dentro de un emulador normalmente se refiere al propio emulador. La aplicación guarda el token de acceso y algunos datos de perfil con `flutter_secure_storage`.

## Estructura del proyecto

El código de la aplicación vive en `lib/` y se organiza por responsabilidad:

```text
lib/
  main.dart                       Inicialización y rutas de Flutter
  core/
    api/api_client.dart           HTTP, errores, token y perfil local
    theme/fingo_theme.dart        Tema visual
    widgets/fingo_brand.dart      Identidad visual reutilizable
  features/
    auth/                          Registro e inicio de sesión
    navigation/                    Navegación principal
    dashboard/                     Resumen financiero
    budgets/                       Presupuestos, modelos y servicios
    movements/                     Movimientos, categorías, formularios y servicio
    profile/                       Perfil del usuario
test/                              Pruebas de widgets
```

Las funciones de la aplicación se separan en módulos. Las páginas y widgets presentan la interfaz; los modelos convierten datos de dominio y API; los servicios coordinan las operaciones de cada módulo; `ApiClient` concentra el transporte HTTP y la sesión.

## Flujos principales

### Sesión

Al arrancar, `main()` inicializa Flutter y carga el token almacenado. La ruta inicial es `/` (inicio de sesión). El registro usa `POST /auth/registro`; el acceso usa `POST /auth/login`. Al iniciar sesión correctamente, el token `access_token` se guarda en almacenamiento seguro y la navegación continúa a `/app`.

### Navegación autenticada

`MainNavigationPage` contiene las secciones Inicio, Presupuestos, Movimientos y Perfil en un `IndexedStack`, conservando el estado de las páginas al cambiar de sección.

### Presupuestos y movimientos

`BudgetService` administra operaciones remotas de presupuestos. `MovementService` carga movimientos y categorías y mantiene una copia en memoria para calcular ingresos, gastos y balance. Las operaciones y rutas observadas están detalladas en [API utilizada](docs/api.md).

## Manejo de API y sesión

`ApiClient.instance` es un cliente singleton. Admite solicitudes `GET`, `POST`, `PUT`, `PATCH` y `DELETE`, codifica los cuerpos como JSON, agrega `Authorization: Bearer <token>` a solicitudes autenticadas y usa un tiempo límite de 25 segundos. Las respuestas HTTP fuera del rango 2xx producen `ApiException`; ante un 401 se elimina el token guardado.

El perfil local conserva nombre, correo y fecha de nacimiento. Al iniciar sesión con otro correo se limpian el nombre y la fecha de nacimiento asociados anteriormente.

## Pruebas y análisis

Las pruebas de widgets están en `test/`. Ejecuta `flutter test` para correrlas y `flutter analyze` para revisar problemas estáticos.

## Convenciones para cambios

- Conserva la organización por dominios dentro de `lib/features/`.
- Mantén las llamadas HTTP y la gestión de sesión en la capa de servicios y `ApiClient`, en vez de duplicarlas en widgets.
- Al cambiar rutas, parámetros o esquemas consumidos del backend, actualiza [docs/api.md](docs/api.md).
- Al cambiar módulos, navegación, configuración o flujos de usuario, actualiza este README y las páginas de documentación relacionadas.
- Documenta únicamente comportamientos comprobables en el código o en el contrato confirmado del backend; anota explícitamente cualquier diferencia o supuesto.

## Dependencias principales

Las dependencias de ejecución declaradas en `pubspec.yaml` incluyen Flutter, `http`, `flutter_secure_storage`, `google_fonts` y `cupertino_icons`. Las herramientas de desarrollo incluyen `flutter_test` y `flutter_lints`.
