import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/domain/entities/order_status.dart';
import 'package:quickmarket/presentation/providers/di_providers.dart';
import 'package:quickmarket/presentation/providers/order_stream_providers.dart';

String _orderStatusLabel(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:
      return 'Pendiente';
    case OrderStatus.confirmed:
      return 'Confirmado';
    case OrderStatus.inPreparation:
    case OrderStatus.preparing:
      return 'Preparando';
    case OrderStatus.readyForPickup:
      return 'Listo para recoger';
    case OrderStatus.assigned:
      return 'Asignado';
    case OrderStatus.pickedUp:
      return 'Recogido';
    case OrderStatus.onTheWay:
    case OrderStatus.delivering:
      return 'En camino';
    case OrderStatus.delivered:
      return 'Entregado';
    case OrderStatus.cancelled:
      return 'Cancelado';
  }
}

OrderStatus? _nextStoreDemo(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:
      return OrderStatus.confirmed;
    case OrderStatus.confirmed:
      return OrderStatus.inPreparation;
    case OrderStatus.inPreparation:
      return OrderStatus.preparing;
    case OrderStatus.preparing:
      return OrderStatus.readyForPickup;
    default:
      return null;
  }
}

OrderStatus? _nextDriver(OrderStatus s) {
  switch (s) {
    case OrderStatus.assigned:
      return OrderStatus.pickedUp;
    case OrderStatus.pickedUp:
      return OrderStatus.delivering;
    case OrderStatus.delivering:
      return OrderStatus.delivered;
    default:
      return null;
  }
}

/// Detalle del pedido con acciones demo de tienda y repartidor.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrder = ref.watch(orderDetailStreamProvider(orderId));
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Pedido $orderId')),
      body: asyncOrder.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Pedido no encontrado'));
          }
          final storeNext = _nextStoreDemo(order.status);
          final driverNext = _nextDriver(order.status);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                order.storeName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Estado: ${_orderStatusLabel(order.status)}'),
              Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
              Text('Entrega: ${order.address}'),
              if (order.driverName != null)
                Text('Repartidor: ${order.driverName}'),
              const Divider(height: 32),
              Text(
                'Productos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final item in order.items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.name),
                  subtitle: Text('x${item.quantity}'),
                  trailing: Text('\$${item.lineTotal.toStringAsFixed(2)}'),
                ),
              const SizedBox(height: 24),
              if (uid == order.userId) ...[
                Text(
                  'Simulación tienda (demo)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Avanza el flujo como si fueras la tienda hasta dejar el '
                  'pedido listo para reparto.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: storeNext == null
                      ? null
                      : () async {
                          await _advanceStore(
                            context,
                            ref,
                            order.id,
                            storeNext,
                          );
                        },
                  child: Text(
                    storeNext == null
                        ? 'Tienda: sin más pasos'
                        : 'Tienda: paso siguiente',
                  ),
                ),
              ],
              if (uid != null && uid == order.driverId) ...[
                const SizedBox(height: 24),
                Text(
                  'Repartidor',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: driverNext == null
                      ? null
                      : () async {
                          await _advanceDriver(
                            context,
                            ref,
                            order.id,
                            driverNext,
                          );
                        },
                  child: Text(
                    driverNext == null
                        ? 'Entrega completada'
                        : 'Siguiente etapa de entrega',
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

Future<void> _advanceStore(
  BuildContext context,
  WidgetRef ref,
  String orderId,
  OrderStatus next,
) async {
  try {
    await ref.read(orderRepositoryProvider).updateOrderStatus(
          orderId: orderId,
          status: next,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado: ${_orderStatusLabel(next)}')),
      );
    }
  } on Failure catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }
}

Future<void> _advanceDriver(
  BuildContext context,
  WidgetRef ref,
  String orderId,
  OrderStatus next,
) async {
  try {
    await ref.read(advanceDeliveryStatusUseCaseProvider).call(
          orderId: orderId,
          nextStatus: next,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado: ${_orderStatusLabel(next)}')),
      );
    }
  } on Failure catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }
}
