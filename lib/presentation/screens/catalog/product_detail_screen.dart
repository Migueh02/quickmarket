import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/presentation/providers/cart_provider.dart';
import 'package:quickmarket/presentation/screens/catalog/product_detail_args.dart';
import 'package:quickmarket/presentation/widgets/catalog/cached_catalog_image.dart';

/// Detalle de producto con hero y acción de carrito.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({
    super.key,
    required this.storeId,
    required this.productId,
    this.args,
  });

  final String storeId;
  final String productId;
  final ProductDetailArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = args;
    if (a == null || a.product.id != productId || a.product.storeId != storeId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Producto')),
        body: const Center(
          child: Text('Abre el producto desde el catálogo o la búsqueda.'),
        ),
      );
    }

    final p = a.product;
    final store = a.store;
    final disabled = p.stock < 1;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              background: Hero(
                tag: 'catalog-product-${p.id}',
                child: CachedCatalogImage(
                  imageUrl: p.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.subcategory,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$${p.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stock: ${p.stock}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    p.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: disabled
                          ? null
                          : () {
                              try {
                                ref.read(cartProvider.notifier).addItem(
                                      product: p,
                                      store: store,
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${p.name} agregado al carrito'),
                                  ),
                                );
                              } on Failure catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message)),
                                );
                              }
                            },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(
                        disabled ? 'Sin stock' : 'Agregar al carrito',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
