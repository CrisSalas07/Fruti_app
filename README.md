# frutiapp_web — Donde el Verdugo de la fruta

Aplicación de control de acceso desarrollada en Flutter Web, que evoluciona los
laboratorios iniciales agregando persistencia local, bitácora de accesos y
exportación/importación de datos en JSON.

## Requisitos

- Flutter SDK (canal stable)
- Google Chrome

## Cómo ejecutar

```bash
flutter pub get
flutter run -d chrome
```

## Credenciales de prueba

- Usuario: `admin@gmail.com`
- Contraseña: `123456`

## Funcionalidades

- Login con validación de campos obligatorios
- Mostrar/ocultar contraseña
- Checkbox "Recordarme" con persistencia vía `shared_preferences`
- Bitácora de intentos de acceso (usuario, fecha/hora, resultado)
- Filtro de bitácora por Todos / Exitosos / Fallidos
- Exportación de la bitácora a archivo `.json`
- Importación de un `.json` previamente exportado, con manejo de errores

## Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada, arranca MyApp
├── catalog.dart                 # Pantalla posterior al login
├── models/
│   └── access_record.dart       # Modelo de un intento de acceso (toJson/fromJson)
├── screens/
│   └── login_screen.dart        # Pantalla de login + bitácora
└── services/
    ├── access_log_service.dart  # Maneja la lista de registros
    └── preferences_service.dart # Guarda/carga el usuario recordado
```