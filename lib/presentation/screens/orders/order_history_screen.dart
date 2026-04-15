import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmarket/core/constants/app_strings.dart';
import 'package:quickmarket/domain/entities/order_entity.dart';
import 'package:quickmarket/domain/entities/order_status.dart';
import 'package:quickmarket/presentation/providers/order_stream_providers.dart';

/// Historial de pedidos del usuario.
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrders = ref.watch(myOrdersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.ordersTitle)),
      body: asyncOrders.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('Aún no tienes pedidos.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _OrderTile(order: orders[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(order.storeName),
        subtitle: Text(
          '${_label(order.status)} · \$${order.totalAmount.toStringAsFixed(2)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/orders/tracking/${order.id}'),
      ),
    );
  }

  String _label(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.inPreparation:
      case OrderStatus.preparing:
      case OrderStatus.readyForPickup:
        return 'En preparación';
      case OrderStatus.onTheWay:
      case OrderStatus.assigned:
      case OrderStatus.pickedUp:
      case OrderStatus.delivering:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}
