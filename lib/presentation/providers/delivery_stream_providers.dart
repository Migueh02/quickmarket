import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmarket/domain/entities/order_entity.dart';
import 'package:quickmarket/presentation/providers/di_providers.dart';

/// Pedidos disponibles para reparto.
final assignableOrdersStreamProvider = StreamProvider<List<OrderEntity>>(
  (ref) => ref.watch(deliveryRepositoryProvider).watchAssignableOrders(),
);

/// Pedidos activos del repartidor autenticado.
final driverActiveOrdersStreamProvider =
    StreamProvider<List<OrderEntity>>((ref) {
  final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(deliveryRepositoryProvider).watchActiveDeliveries(uid);
});
