import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmarket/domain/entities/order_entity.dart';
import 'package:quickmarket/presentation/providers/di_providers.dart';

/// Pedidos del usuario autenticado.
final myOrdersStreamProvider = StreamProvider<List<OrderEntity>>((ref) {
  final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(orderRepositoryProvider).watchOrdersForUser(uid);
});

/// Detalle de un pedido.
final orderDetailStreamProvider =
    StreamProvider.family<OrderEntity?, String>(
  (ref, orderId) => ref.watch(orderRepositoryProvider).watchOrder(orderId),
);
