import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmarket/domain/entities/product_entity.dart';
import 'package:quickmarket/domain/entities/store_category.dart';
import 'package:quickmarket/domain/entities/store_entity.dart';
import 'package:quickmarket/presentation/providers/di_providers.dart';
import 'package:quickmarket/presentation/providers/session_providers.dart';

// --- Shell catálogo / home ---

final shellTabIndexProvider = StateProvider<int>((ref) => 0);

final promoPageControllerProvider = Provider.autoDispose<PageController>((ref) {
  final c = PageController(viewportFraction: 0.92);
  ref.onDispose(c.dispose);
  return c;
});

/// Categoría de tienda seleccionada en el home (null = todas).
final selectedCatalogCategoryProvider =
    StateProvider<StoreCategory?>((ref) => null);

/// Calificación mínima de tienda en el listado home (solo lectura estrellas).
final homeMinStoreRatingProvider = StateProvider<double>((ref) => 0);

/// Stream de tiendas filtradas por ciudad del perfil (Firestore + caché).
final storesProvider = StreamProvider<List<StoreEntity>>((ref) {
  final city = ref.watch(userProfileProvider).valueOrNull?.city;
  return ref.watch(catalogRepositoryProvider).watchStores(city: city);
});

/// Tiendas con filtros de categoría y calificación (home).
final filteredStoresProvider = Provider<AsyncValue<List<StoreEntity>>>((ref) {
  final base = ref.watch(storesProvider);
  final cat = ref.watch(selectedCatalogCategoryProvider);
  final minR = ref.watch(homeMinStoreRatingProvider);
  return base.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (stores) {
      var list = stores;
      if (cat != null) {
        list = list.where((s) => s.category == cat).toList();
      }
      if (minR > 0) {
        list = list.where((s) => s.rating >= minR).toList();
      }
      return AsyncValue.data(list);
    },
  );
});

// --- Detalle de tienda: filtros de producto ---

class StoreDetailFilters {
  const StoreDetailFilters({
    this.maxPrice,
    this.inStockOnly = false,
  });

  final double? maxPrice;
  final bool inStockOnly;
}

class StoreDetailFiltersNotifier extends StateNotifier<StoreDetailFilters> {
  StoreDetailFiltersNotifier() : super(const StoreDetailFilters());

  void setMaxPrice(double? v) => state = StoreDetailFilters(
        maxPrice: v,
        inStockOnly: state.inStockOnly,
      );

  void setInStockOnly(bool v) => state = StoreDetailFilters(
        maxPrice: state.maxPrice,
        inStockOnly: v,
      );
}

final storeDetailFiltersProvider = StateNotifierProvider.family<
    StoreDetailFiltersNotifier, StoreDetailFilters, String>(
  (ref, _) => StoreDetailFiltersNotifier(),
);

// --- Paginación de productos por tienda ---

class ProductsState {
  const ProductsState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.cursor,
    this.error,
  });

  final List<ProductEntity> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? cursor;
  final Object? error;

  ProductsState copyWith({
    List<ProductEntity>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    String? cursor,
    Object? error,
  }) {
    return ProductsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      cursor: cursor ?? this.cursor,
      error: error ?? this.error,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  ProductsNotifier(this._ref, this.storeId)
      : super(const ProductsState(loading: true)) {
    scheduleMicrotask(_loadFirst);
  }

  final Ref _ref;
  final String storeId;

  Future<void> _loadFirst() async {
    state = state.copyWith(loading: true, error: null, items: []);
    try {
      final repo = _ref.read(catalogRepositoryProvider);
      final page = await repo.fetchProductsPage(storeId: storeId);
      state = ProductsState(
        items: page.items,
        loading: false,
        hasMore: page.nextCursor != null,
        cursor: page.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore || state.cursor == null) return;
    state = state.copyWith(loadingMore: true);
    try {
      final repo = _ref.read(catalogRepositoryProvider);
      final page = await repo.fetchProductsPage(
        storeId: storeId,
        cursorProductId: state.cursor,
      );
      state = state.copyWith(
        items: [...state.items, ...page.items],
        loadingMore: false,
        hasMore: page.nextCursor != null,
        cursor: page.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: e);
    }
  }

  Future<void> refresh() => _loadFirst();
}

/// Estado de productos cargados por tienda (paginación 20 en 20).
final productsProvider =
    StateNotifierProvider.family<ProductsNotifier, ProductsState, String>(
  (ref, storeId) => ProductsNotifier(ref, storeId),
);

/// Productos filtrados por precio y disponibilidad (detalle tienda).
final filteredStoreProductsProvider =
    Provider.family<List<ProductEntity>, String>((ref, storeId) {
  final raw = ref.watch(productsProvider(storeId)).items;
  final f = ref.watch(storeDetailFiltersProvider(storeId));
  return raw.where((p) {
    if (f.inStockOnly && p.stock <= 0) return false;
    if (f.maxPrice != null && p.price > f.maxPrice!) return false;
    return true;
  }).toList();
});

/// Agrupación por subcategoría para el detalle de tienda.
final groupedStoreProductsProvider =
    Provider.family<Map<String, List<ProductEntity>>, String>((ref, storeId) {
  final list = ref.watch(filteredStoreProductsProvider(storeId));
  return groupBy(list, (ProductEntity p) => p.subcategory);
});

// --- Búsqueda global (debounce 300 ms) ---

class SearchState {
  const SearchState({
    this.query = '',
    this.loading = false,
    this.results = const [],
  });

  final String query;
  final bool loading;
  final List<ProductEntity> results;

  SearchState copyWith({
    String? query,
    bool? loading,
    List<ProductEntity>? results,
  }) {
    return SearchState(
      query: query ?? this.query,
      loading: loading ?? this.loading,
      results: results ?? this.results,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._ref) : super(const SearchState());

  final Ref _ref;
  Timer? _debounce;

  void cancelDebouncer() => _debounce?.cancel();

  void onQueryChanged(String raw) {
    _debounce?.cancel();
    final trimmed = raw.trim();
    state = state.copyWith(query: raw);
    if (trimmed.isEmpty) {
      state = const SearchState();
      return;
    }
    state = state.copyWith(loading: true);
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final city = _ref.read(userProfileProvider).valueOrNull?.city;
      try {
        final list = await _ref.read(catalogRepositoryProvider).searchProducts(
              query: trimmed,
              city: city,
            );
        state = SearchState(query: raw, loading: false, results: list);
      } catch (_) {
        state = SearchState(query: raw, loading: false, results: const []);
      }
    });
  }

  void clear() {
    _debounce?.cancel();
    state = const SearchState();
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final n = SearchNotifier(ref);
  ref.onDispose(n.cancelDebouncer);
  return n;
});

/// Resuelve una tienda cargada en [storesProvider] por id.
final storeLookupProvider = Provider.family<StoreEntity?, String>((ref, storeId) {
  final list = ref.watch(storesProvider).valueOrNull;
  if (list == null) return null;
  for (final s in list) {
    if (s.id == storeId) return s;
  }
  return null;
});
