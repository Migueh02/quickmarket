import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/domain/entities/order_item_entity.dart';
import 'package:quickmarket/domain/entities/payment_method.dart';
import 'package:quickmarket/presentation/providers/cart_provider.dart';
import 'package:quickmarket/presentation/providers/checkout_providers.dart';
import 'package:quickmarket/presentation/providers/di_providers.dart';

/// Checkout: dirección, pago (simulado) y confirmación de pedido.
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  Future<void> _placeOrder(BuildContext context, WidgetRef ref) async {
    final lines = ref.read(cartProvider);
    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu carrito está vacío')),
      );
      return;
    }
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (uid == null) {
      context.go('/login');
      return;
    }
    final checkout = ref.read(checkoutFormProvider);
    if (checkout.address.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes ingresar una dirección de entrega')),
      );
      return;
    }
    final ok = await _showSummaryDialog(context, ref);
    if (!ok) return;
    try {
      final store = lines.first.store;
      final items = lines
          .map(
            (l) => OrderItemEntity(
              productId: l.product.id,
              name: l.product.name,
              unitPrice: l.product.price,
              quantity: l.quantity,
            ),
          )
          .toList();
      final orderId = await ref.read(placeOrderUseCaseProvider).call(
            userId: uid,
            storeId: store.id,
            storeName: store.name,
            items: items,
            deliveryAddress: checkout.address,
            paymentMethod: checkout.paymentMethod,
          );
      ref.read(cartProvider.notifier).clear();
      if (context.mounted) {
        context.go('/orders/confirmation/$orderId');
      }
    } on Failure catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<bool> _showSummaryDialog(BuildContext context, WidgetRef ref) async {
    final lines = ref.read(cartProvider);
    final subtotal = ref.read(cartProvider.notifier).subtotal;
    final checkout = ref.read(checkoutFormProvider);
    final total = subtotal;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmación de pedido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tienda: ${lines.first.store.name}'),
            Text('Productos: ${lines.length}'),
            Text('Dirección: ${checkout.address}'),
            Text('Pago: ${checkout.paymentMethod.label}'),
            const SizedBox(height: 8),
            Text('Total: \$${total.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartProvider);
    final subtotal = ref.watch(cartProvider.notifier).subtotal;
    final checkout = ref.watch(checkoutFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (lines.isEmpty) ...[
            const Center(child: Text('No hay productos en el carrito.')),
          ] else ...[
            for (final line in lines)
              Card(
                child: ListTile(
                  title: Text(line.product.name),
                  subtitle: Text('${line.store.name} · x${line.quantity}'),
                  trailing: Text('\$${line.lineTotal.toStringAsFixed(2)}'),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'Subtotal: \$${subtotal.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: checkout.address)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: checkout.address.length),
                ),
              onChanged: ref.read(checkoutFormProvider.notifier).setAddress,
              decoration: const InputDecoration(
                labelText: 'Dirección de entrega',
                hintText: 'Calle, número, barrio, referencias',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            SegmentedButton(
              segments: const [
                ButtonSegment(
                  value: 'cash',
                  label: Text('Efectivo'),
                  icon: Icon(Icons.payments_outlined),
                ),
                ButtonSegment(
                  value: 'card',
                  label: Text('Tarjeta'),
                  icon: Icon(Icons.credit_card_outlined),
                ),
              ],
              selected: {
                checkout.paymentMethod.firestoreValue,
              },
              onSelectionChanged: (set) {
                final value = set.first;
                ref.read(checkoutFormProvider.notifier).setPaymentMethod(
                      value == 'card' ? PaymentMethod.card : PaymentMethod.cash,
                    );
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _placeOrder(context, ref),
              child: const Text('Confirmar pedido'),
            ),
          ],
        ],
      ),
    );
  }
}
