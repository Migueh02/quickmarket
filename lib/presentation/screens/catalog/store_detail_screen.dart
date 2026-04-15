import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmarket/domain/entities/store_entity.dart';
import 'package:quickmarket/presentation/providers/catalog_providers.dart';
import 'package:quickmarket/presentation/screens/catalog/product_detail_args.dart';
import 'package:quickmarket/presentation/widgets/catalog/cached_catalog_image.dart';

/// Detalle de tienda: SliverAppBar, filtros y productos por subcategoría.
class StoreDetailScreen extends ConsumerWidget {
  const StoreDetailScreen({
    super.key,
    required this.storeId,
    this.initialStore,
  });

  final String storeId;
  final StoreEntity? initialStore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = initialStore ??
        ref.watch(storeLookupProvider(storeId)) ??
        StoreEntity.minimal(id: storeId);
    final grouped = ref.watch(groupedStoreProductsProvider(storeId));
    final productsState = ref.watch(productsProvider(storeId));
    final keys = grouped.keys.toList()..sort();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFilters(context, ref, storeId),
        icon: const Icon(Icons.tune),
        label: const Text('Filtros'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 400) {
            ref.read(productsProvider(storeId).notifier).loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                title: Text(store.name),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedCatalogImage(
                      imageUrl: store.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: () =>
                      ref.read(productsProvider(storeId).notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: 'Carrito',
                  onPressed: () => context.push('/cart'),
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          store.category.label,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.star,
                          size: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        Text(
                          ' ${store.rating.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.schedule,
                          size: 20,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        Text(
                          ' ${store.deliveryTime} min',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      store.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (productsState.loadingMore)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            if (productsState.loading && productsState.items.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (productsState.error != null && productsState.items.isEmpty)
              SliverFillRemaining(
                child: Center(child: Text('Error: ${productsState.error}')),
              )
            else if (keys.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Sin productos con los filtros actuales. '
                    'Si en Firestore sí existen, verifica que estén en la ruta '
                    '`stores/{storeId}/products` (subcolección EXACTA: `products`).',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              for (final k in keys) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      k,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final p = grouped[k]![i];
                      final disabled = p.stock < 1;
                      return Opacity(
                        opacity: disabled ? 0.55 : 1,
                        child: ListTile(
                          leading: Hero(
                            tag: 'catalog-product-${p.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: CachedCatalogImage(
                                  imageUrl: p.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          title: Text(p.name),
                          subtitle: Text(
                            '\$${p.price.toStringAsFixed(2)} · Stock ${p.stock}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            '/product/${p.storeId}/${p.id}',
                            extra: ProductDetailArgs(product: p, store: store),
                          ),
                        ),
                      );
                    },
                    childCount: grouped[k]!.length,
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }

  static void _openFilters(BuildContext context, WidgetRef ref, String sid) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => _StoreFiltersSheet(storeId: sid),
    );
  }
}

class _StoreFiltersSheet extends ConsumerWidget {
  const _StoreFiltersSheet({required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(storeDetailFiltersProvider(storeId));
    final notifier = ref.read(storeDetailFiltersProvider(storeId).notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filtros de productos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Solo con stock'),
            value: f.inStockOnly,
            onChanged: notifier.setInStockOnly,
          ),
          const SizedBox(height: 8),
          Text(
            'Precio máximo',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          DropdownButton<double?>(
            isExpanded: true,
            value: f.maxPrice,
            items: const [
              DropdownMenuItem<double?>(
                value: null,
                child: Text('Sin límite'),
              ),
              DropdownMenuItem(value: 5, child: Text('Hasta \$5')),
              DropdownMenuItem(value: 10, child: Text('Hasta \$10')),
              DropdownMenuItem(value: 25, child: Text('Hasta \$25')),
              DropdownMenuItem(value: 50, child: Text('Hasta \$50')),
              DropdownMenuItem(value: 100, child: Text('Hasta \$100')),
            ],
            onChanged: notifier.setMaxPrice,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
