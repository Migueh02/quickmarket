import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmarket/core/constants/app_strings.dart';
import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/domain/entities/order_entity.dart';
import 'package:quickmarket/domain/entities/user_entity.dart';
import 'package:quickmarket/presentation/providers/delivery_stream_providers.dart';
import 'package:quickmarket/presentation/providers/di_providers.dart';
import 'package:quickmarket/presentation/providers/session_providers.dart';

/// Panel de repartidor: pedidos disponibles y entregas activas.
class DriverScreen extends ConsumerWidget {
  const DriverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final assignable = ref.watch(assignableOrdersStreamProvider);
    final active = ref.watch(driverActiveOrdersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.driverTitle)),
      body: profile.when(
        data: (UserEntity? user) {
          if (user == null || !user.isDriver) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Activa el modo repartidor desde Perfil para ver pedidos '
                'disponibles y gestionar entregas.',
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Disponibles para tomar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              assignable.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Text(
                      'No hay pedidos listos en este momento. Un pedido '
                      'aparece aquí cuando en Pedidos → detalle del pedido se '
                      'avanza la simulación de tienda hasta «Listo para recoger» '
                      '(estado ready_for_pickup y disponible para repartidores).',
                    );
                  }
                  return Column(
                    children: list.map((o) => _AssignableCard(order: o)).toList(),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),
              Text(
                'Mis entregas activas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              active.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Text('No tienes entregas en curso.');
                  }
                  return Column(
                    children: list
                        .map(
                          (o) => Card(
                            child: ListTile(
                              title: Text(o.storeName),
                              subtitle: Text('Estado: ${o.status.name}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push('/orders/${o.id}'),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AssignableCard extends ConsumerWidget {
  const _AssignableCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.storeName, style: Theme.of(context).textTheme.titleSmall),
            Text('Cliente: ${order.userId}'),
            Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    final name =
                        FirebaseAuth.instance.currentUser?.displayName ??
                            'Repartidor';
                    if (uid == null) return;
                    try {
                      await ref.read(assignDriverUseCaseProvider).call(
                            orderId: order.id,
                            driverId: uid,
                            driverName: name,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pedido asignado')),
                        );
                        context.push('/orders/${order.id}');
                      }
                    } on Failure catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message)),
                        );
                      }
                    }
                  },
                  child: const Text('Tomar pedido'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
