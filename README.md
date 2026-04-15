# QuickMarket

App tipo **delivery** (estilo Rappi) construida con **Flutter** + **Firebase** (Auth + Firestore) siguiendo un enfoque de **Clean Architecture** y **Riverpod** para estado/DI.

## Funcionalidades

- **Catálogo** de tiendas y productos.
- **Carrito** persistido localmente (Hive).
- **Checkout** (dirección + método de pago simulado).
- **Pedidos** con estados y seguimiento.
- **Modo repartidor (demo)**: ver pedidos listos, tomar pedido, avanzar estados logísticos.
- **Notificaciones in‑app** (persistidas en Firestore) + badge de no leídas.

## Stack / dependencias principales

- **Flutter** (Material 3)
- **flutter_riverpod**
- **go_router**
- **firebase_core**, **firebase_auth**, **cloud_firestore**
- **hive / hive_flutter**
- **cached_network_image**, **shimmer**

## Arquitectura

Estructura de capas:

- `lib/domain/`: entidades, repositorios (interfaces), casos de uso.
- `lib/data/`: modelos, datasources (Firestore), implementaciones de repositorios.
- `lib/presentation/`: UI (screens/widgets), providers (Riverpod), router.
- `lib/core/`: constantes, tema, utilidades, errores.

## Estructura del proyecto (resumen)

```
lib/
  core/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    providers/
    router/
    screens/
    widgets/
  main.dart
  firebase_options.dart
firestore.rules
firestore.indexes.json
firebase.json
pubspec.yaml
```

## Configuración Firebase

### Requisitos

- Tener un proyecto en Firebase.
- Habilitar **Authentication (Email/Password)**.
- Crear **Cloud Firestore** (modo production o test, según tu caso).

### Archivo `firebase_options.dart`

Este repo ya incluye `lib/firebase_options.dart` (generado por FlutterFire). Si cambias de proyecto, vuelve a generarlo con FlutterFire CLI.

## Reglas e índices de Firestore (importante)

Este proyecto versiona:

- `firestore.rules`: reglas sugeridas para desarrollo/demos con clientes y repartidores.
- `firestore.indexes.json`: índice compuesto para consultas del repartidor.

### Por qué es necesario

- El repartidor consulta pedidos con:
  - `status == 'ready_for_pickup'`
  - `availableForDrivers == true`
- Esa consulta requiere un **índice compuesto** (`status` + `availableForDrivers`).

### Reglas incluidas

Las reglas permiten:

- `users/{uid}`: cada usuario solo lee/escribe su perfil.
- `users/{uid}/notifications/{id}`: cada usuario solo lee/escribe **sus** notificaciones.
- `stores/*` y `products/*`: lectura para autenticados.
- `orders/*`:
  - **create**: el dueño crea su orden.
  - **read/update**: dueño, repartidor asignado, o pool público de pedidos listos para tomar (`ready_for_pickup` + `availableForDrivers == true`).

> Nota: la actualización de stock en `products` está limitada a **solo disminuir** stock desde el cliente (útil para demos). Para producción, lo ideal es mover stock/orden a un backend (Cloud Functions).

## Modelo de datos (Firestore)

### `users/{uid}`

Campos típicos (pueden variar según tu implementación):

- `displayName` (string)
- `phone` (string|null)
- `city` (string|null)
- `role` (string: `customer` / `driver`)

Subcolección:

- `users/{uid}/notifications/{notificationId}`

### `stores/{storeId}`

- `name`, `category`, `city`, `rating`, `imageUrl`, `deliveryTime`, etc.

Subcolección:

- `stores/{storeId}/products/{productId}`
  - `name`, `price`, `stock`, `imageUrl`, etc.

### `orders/{orderId}`

Ejemplo de campos:

- `userId` (string)
- `storeId` (string)
- `storeName` (string)
- `items` (array)
- `status` (string, ver estados abajo)
- `totalAmount` (number)
- `address` (string)
- `paymentMethod` (string: `cash` / `card`)
- `driverId` (string|null)
- `driverName` (string|null)
- `availableForDrivers` (bool)
- `createdAt`, `updatedAt` (timestamp)

#### Estados de pedido

Definidos en `lib/domain/entities/order_status.dart`:

- `pending`, `confirmed`, `in_preparation`, `preparing`, `ready_for_pickup`,
- `assigned`, `picked_up`, `delivering` / `on_the_way`, `delivered`, `cancelled`

## Notificaciones in‑app

Las notificaciones se guardan en:

`users/{uid}/notifications/{notificationId}`

Campos:

- `title`, `body`
- `createdAt`
- `read` (bool)
- `orderId` (opcional)
- `kind` (string) — ver `lib/domain/entities/notification_kind.dart`

### Eventos notificados

- Cliente:
  - Pedido recibido (`order_placed`)
  - Confirmado / en preparación / listo para reparto
  - Repartidor asignado
  - Pedido recogido / en camino / entregado / cancelado
- Repartidor:
  - Pedido tomado (cuando asigna)
  - Entrega finalizada (cuando marca `delivered`)

## Flujos (cómo probar rápido)

### Cliente (hacer pedido)

1. Inicia sesión/crea cuenta.
2. En **Tiendas**, entra a una tienda, agrega productos al **carrito**.
3. Ve a **Checkout**, ingresa dirección y confirma.
4. Verás:
   - Pedido creado en `orders`
   - Notificación in‑app de pedido recibido

### Simulación tienda (demo)

En el **detalle del pedido** (`/orders/:orderId`), si eres el dueño:

- Usa **“Tienda: paso siguiente”** para avanzar:
  - `pending → confirmed → in_preparation → preparing → ready_for_pickup`
- Al llegar a `ready_for_pickup`, el pedido queda:
  - `availableForDrivers = true`
  - visible para el repartidor en “Disponibles para tomar”.

### Repartidor (demo)

1. En **Perfil**, pulsa **“Activar modo repartidor (demo)”**.
2. Ve a la pestaña **Reparto**.
3. En “Disponibles para tomar”, pulsa **“Tomar pedido”**.
4. En el detalle, avanza estados:
   - `assigned → picked_up → delivering → delivered`
5. Se disparan notificaciones al cliente en cada paso, y al repartidor al tomar/finalizar.

## Ejecutar el proyecto

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar (ejemplos):

```bash
flutter run
flutter run -d chrome
flutter run -d android
```

## Troubleshooting

### `cloud_firestore/permission-denied`

Casi siempre significa que:

- Las **reglas** no cubren la ruta exacta (por ejemplo `users/{uid}/notifications/...` requiere un `match` específico).
- La consulta requiere un **índice** (revisar “Índices” en Firestore Console).
- Estás intentando leer pedidos de otros usuarios sin condiciones permitidas por reglas.

Revisa/usa los archivos `firestore.rules` y `firestore.indexes.json`.

## Notas / límites del demo

- El flujo “tienda” y los cambios de estado son **simulación** desde la app.
- Para producción real se recomienda:
  - Cambios de estado desde backend/Cloud Functions
  - Control estricto de stock y consistencia
  - Push notifications con FCM (aparte de las in‑app)
