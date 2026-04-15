import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmarket/domain/entities/store_entity.dart';
import 'package:quickmarket/presentation/providers/catalog_providers.dart';
import 'package:quickmarket/presentation/screens/catalog/product_detail_args.dart';
import 'package:quickmarket/presentation/widgets/catalog/cached_catalog_image.dart';

/// Búsqueda de productos con debounce (ver [searchProvider]).
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: SearchBar(
          hintText: 'Buscar productos…',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              notifier.clear();
              context.pop();
            },
          ),
          trailing: [
            if (search.query.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: notifier.clear,
              ),
          ],
          onChanged: notifier.onQueryChanged,
          autoFocus: true,
        ),
      ),
      body: search.loading
          ? const Center(child: CircularProgressIndicator())
          : search.query.trim().isEmpty
              ? const Center(
                  child: Text('Escribe para buscar en tus tiendas cercanas.'),
                )
              : search.results.isEmpty
                  ? const Center(child: Text('Sin resultados.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: search.results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final p = search.results[i];
                        final store = ref.watch(storeLookupProvider(p.storeId)) ??
                            StoreEntity.minimal(id: p.storeId);
                        return Card(
                          child: ListTile(
                            leading: Hero(
                              tag: 'catalog-product-${p.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: CachedCatalogImage(
                                    imageUrl: p.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(p.name),
                            subtitle: Text(
                              '${store.name} · \$${p.price.toStringAsFixed(2)}',
                            ),
                            trailing: p.stock < 1
                                ? Text(
                                    'Agotado',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  )
                                : null,
                            onTap: () => context.push(
                              '/product/${p.storeId}/${p.id}',
                              extra: ProductDetailArgs(product: p, store: store),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
