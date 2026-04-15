import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmarket/presentation/providers/cart_provider.dart';

/// Carrito reactivo con edición de cantidades y resumen.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartProvider.notifier).subtotal;
    final total = subtotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: items.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in items)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text('\$${item.product.price.toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.product.id, item.quantity - 1),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.product.id, item.quantity + 1),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                          IconButton(
                            onPressed: () =>
                                ref.read(cartProvider.notifier).remove(item.product.id),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Total: \$${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.push('/checkout'),
                  child: const Text('Ir a checkout'),
                ),
              ],
            ),
    );
  }
}
