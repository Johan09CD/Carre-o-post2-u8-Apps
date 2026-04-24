# Carreño Post2 U8 — Flutter DevTools, Isolates y Firebase Performance

Aplicación Flutter desarrollada para la **Unidad 8 Post-Contenido 2: Rendimiento, Optimización y Experiencia Fluida** de la asignatura Aplicaciones Móviles — Ingeniería de Sistemas, Universidad de Santander (UDES) 2026.

## Descripción

La app procesa un catálogo de 1000 productos en JSON, permitiendo evidenciar problemas de jank cuando el parse ocurre en el main thread, y demostrar la mejora al migrar el procesamiento a un Isolate secundario con `compute()`. Incluye trazas personalizadas con Firebase Performance Monitoring para medir tiempos de operación reales.

---

## Requisitos

- Flutter SDK 3.16+ y Dart 3.2+
- Android Studio con plugin Flutter instalado
- Dispositivo físico o emulador con API 26+
- Proyecto Firebase configurado con FlutterFire CLI

---

## Configuración y ejecución

1. Clona el repositorio:
```bash
git clone https://github.com/Johan09CD/Carre-o-post2-u8-Apps
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Configura Firebase:
```bash
flutterfire configure
```

4. Ejecuta la app:
```bash
flutter run
```

---

## Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| Flutter 3.27 + Dart 3.6 | Framework principal |
| compute() | Migración de parse JSON a Isolate secundario |
| dart:developer Timeline | Trazas manuales en DevTools |
| Firebase Performance | Métricas personalizadas en producción |
| Flutter DevTools | Análisis de frames y detección de jank |

---

## Estructura del proyecto

```
lib/
├── models/
│   ├── product_model.dart      # Modelo Product con factory fromJson
│   └── catalog_generator.dart  # Generador de JSON de prueba (1000 items)
├── screens/
│   └── catalog_screen.dart     # Pantalla principal con versión optimizada
├── firebase_options.dart        # Configuración Firebase (generado por FlutterFire)
└── main.dart                   # Inicialización Firebase y punto de entrada
```

---

## Optimizaciones implementadas

### 1. Versión bloqueante (baseline)
El parse del JSON se ejecutaba directamente en el **main thread** usando `jsonDecode()`, bloqueando la UI durante el procesamiento de 1000 productos. Esto generaba jank visible con frames superando los 16ms y un promedio de solo **6 FPS**.

### 2. Migración a Isolate con compute()
Se migró el procesamiento pesado a un **Isolate secundario** usando `compute()`. La función `_parseProducts()` se definió como función top-level (requerimiento de compute) y recibe el JSON como String. El UI thread permanece libre para renderizar animaciones durante el procesamiento.

```dart
final products = await compute(_parseProducts, jsonString);
```

### 3. Trazas con dart:developer
Se agregaron trazas manuales con `dev.Timeline.startSync()` para identificar las secciones más costosas en el DevTools Timeline:
- `generateJson` — generación del JSON
- `compute_parseProducts` — parse en Isolate

### 4. Firebase Performance Monitoring
Se integró `firebase_performance` para medir tiempos reales de la operación `catalog_load` en producción, incluyendo la métrica custom `product_count`.

---

## Análisis de métricas

### DevTools Timeline — Antes de compute() (baseline)
- **6 FPS promedio** durante la carga del catálogo
- Frames en **rojo** superando los 27ms
- `jsonDecode` bloqueaba el main thread causando jank visible
- El `CircularProgressIndicator` se congelaba durante el parse

### DevTools Timeline — Después de compute()
- **15 FPS promedio** durante la carga
- Frames más estables con menos jank
- El `CircularProgressIndicator` gira continuamente sin congelarse
- El parse ocurre en un Isolate separado sin bloquear la UI

---

## Capturas de pantalla

### DevTools Timeline — Antes de compute() (frames rojos)
![DevTools antes](capturas/screenshot_devtools_before.png)

### DevTools Timeline — Después de compute() (mejorado)
![DevTools después](capturas/screenshot_devtools_after.png)

### Logcat con Firebase Performance
![Firebase Logcat](capturas/screenshot_firebase_logcat.png)

---