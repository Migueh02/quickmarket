import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmarket/domain/entities/order_status.dart';
import 'package:quickmarket/presentation/providers/order_stream_providers.dart';

/// Tracking en tiempo real con timeline animado.
class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  static const List<OrderStatus> _flow = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.inPreparation,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrder = ref.watch(orderDetailStreamProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento de pedido')),
      body: asyncOrder.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Pedido no encontrado'));
          }
          final current = _normalize(order.status);
          final index = _flow.indexOf(current);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                order.storeName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Entrega: ${order.address}'),
              Text('Pago: ${order.paymentMethod.label}'),
              const SizedBox(height: 20),
              for (var i = 0; i < _flow.length; i++)
                _TimelineStep(
                  title: _label(_flow[i]),
                  done: i <= index,
                  last: i == _flow.length - 1,
                ),
              const SizedBox(height: 16),
              Text(
                'Actualización en tiempo real activa',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  OrderStatus _normalize(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
      case OrderStatus.readyForPickup:
        return OrderStatus.inPreparation;
      case OrderStatus.delivering:
      case OrderStatus.assigned:
      case OrderStatus.pickedUp:
        return OrderStatus.onTheWay;
      default:
        return status;
    }
  }

  String _label(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.inPreparation:
        return 'En preparación';
      case OrderStatus.onTheWay:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      default:
        return s.name;
    }
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.done,
    required this.last,
  });

  final String title;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = done ? Theme.of(context).colorScheme.primary : Colors.grey;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: done ? color : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: done
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (!last)
              AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                width: 2,
                height: 42,
                color: done ? color : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Text(title),
        ),
      ],
    );
  }
}
