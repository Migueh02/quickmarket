import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmarket/core/constants/app_strings.dart';
import 'package:quickmarket/domain/entities/order_status.dart';
import 'package:quickmarket/domain/entities/store_category.dart';
import 'package:quickmarket/domain/entities/store_entity.dart';
import 'package:quickmarket/presentation/providers/cart_provider.dart';
import 'package:quickmarket/presentation/providers/catalog_providers.dart';
import 'package:quickmarket/presentation/providers/notification_stream_providers.dart';
import 'package:quickmarket/presentation/providers/order_stream_providers.dart';
import 'package:quickmarket/presentation/widgets/catalog/cached_catalog_image.dart';

/// Home del catálogo: banner, categorías horizontales y grid de tiendas.
class CatalogHomeScreen extends ConsumerWidget {
  const CatalogHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStores = ref.watch(filteredStoresProvider);
    final cartCount = ref.watch(cartProvider).length;
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);
    final selectedCat = ref.watch(selectedCatalogCategoryProvider);
    final minRating = ref.watch(homeMinStoreRatingProvider);
    final pageController = ref.watch(promoPageControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.storesTitle),
        actions: [
          IconButton(
            tooltip: 'Buscar productos',
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: unreadNotifications > 0,
              label: Text(
                unreadNotifications > 99 ? '99+' : '$unreadNotifications',
                style: const TextStyle(fontSize: 10),
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          Badge.count(
            count: cartCount,
            isLabelVisible: cartCount > 0,
            child: IconButton(
              tooltip: 'Carrito',
              onPressed: () => context.push('/cart'),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const _ActiveOrdersBanner(),
                SizedBox(
                  height: 140,
                  child: PageView(
                    controller: pageController,
                    children: const [
                      _PromoBanner(
                        title: 'Envío gratis',
                        subtitle: 'En pedidos seleccionados esta semana',
                        color: Color(0xFF0D9488),
                      ),
                      _PromoBanner(
                        title: '-20% farmacia',
                        subtitle: 'Cuida tu salud con QuickMarket',
                        color: Color(0xFF7C3AED),
                      ),
                      _PromoBanner(
                        title: 'Super a tu puerta',
                        subtitle: 'Mercado en minutos',
                        color: Color(0xFFEA580C),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: const Text('Todas'),
                          selected: selectedCat == null,
                          onSelected: (_) {
                            ref.read(selectedCatalogCategoryProvider.notifier).state =
                                null;
                          },
                        ),
                      ),
                      for (final c in StoreCategory.values)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(c.label),
                            selected: selectedCat == c,
                            onSelected: (_) {
                              ref.read(selectedCatalogCategoryProvider.notifier).state =
                                  c;
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Calificación mínima',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (final r in <double>[0, 4.0, 4.5])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(r == 0 ? 'Todas' : '≥ $r ★'),
                            selected: minRating == r,
                            onSelected: (_) {
                              ref.read(homeMinStoreRatingProvider.notifier).state = r;
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          asyncStores.when(
            data: (stores) {
              if (stores.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No hay tiendas para tu ciudad o filtros. '
                      'Ajusta perfil/ciudad o datos en Firestore (`stores`, campo `city`, `category`).',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final s = stores[i];
                      return _StoreGridCard(
                        store: s,
                        onTap: () => context.push('/store/${s.id}', extra: s),
                      );
                    },
                    childCount: stores.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Resumen visible en inicio: pedidos que aún no están entregados o cancelados.
class _ActiveOrdersBanner extends ConsumerWidget {
  const _ActiveOrdersBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myOrdersStreamProvider);
    return async.when(
      data: (orders) {
        final active = orders
            .where(
              (o) =>
                  o.status != OrderStatus.delivered &&
                  o.status != OrderStatus.cancelled,
            )
            .take(2)
            .toList();
        if (active.isEmpty) return const SizedBox.shrink();
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_shipping_outlined, size: 22, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Tus pedidos en curso',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final o in active)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: scheme.primaryContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => context.push('/orders/${o.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    o.storeName,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _orderStatusLabelEs(o.status),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: scheme.outline),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

String _orderStatusLabelEs(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:
      return 'Pendiente';
    case OrderStatus.confirmed:
      return 'Confirmado';
    case OrderStatus.inPreparation:
    case OrderStatus.preparing:
      return 'En preparación';
    case OrderStatus.readyForPickup:
      return 'Listo para reparto';
    case OrderStatus.assigned:
      return 'Repartidor asignado';
    case OrderStatus.pickedUp:
      return 'Recogido por repartidor';
    case OrderStatus.delivering:
    case OrderStatus.onTheWay:
      return 'En camino';
    case OrderStatus.delivered:
      return 'Entregado';
    case OrderStatus.cancelled:
      return 'Cancelado';
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreGridCard extends StatelessWidget {
  const _StoreGridCard({required this.store, required this.onTap});

  final StoreEntity store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedCatalogImage(
                imageUrl: store.imageUrl,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.category.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: scheme.secondary),
                      Text(
                        ' ${store.rating.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const Spacer(),
                      Icon(Icons.schedule, size: 14, color: scheme.tertiary),
                      Text(
                        ' ${store.deliveryTime}m',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
