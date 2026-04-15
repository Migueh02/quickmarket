import 'package:quickmarket/data/datasources/firestore_catalog_data_source.dart';
import 'package:quickmarket/domain/entities/product_entity.dart';
import 'package:quickmarket/domain/entities/store_entity.dart';
import 'package:quickmarket/domain/repositories/catalog_repository.dart';
import 'package:quickmarket/domain/value_objects/product_page_result.dart';

/// Implementación Firestore del catálogo.
class FirestoreCatalogRepository implements CatalogRepository {
  FirestoreCatalogRepository(this._remote);

  final FirestoreCatalogDataSource _remote;

  @override
  Stream<List<StoreEntity>> watchStores({String? city}) {
    return _remote.watchStores(city: city).map(
          (list) => list.map((e) => e.toEntity()).toList(),
        );
  }

  @override
  Future<ProductPageResult> fetchProductsPage({
    required String storeId,
    int limit = 20,
    String? cursorProductId,
  }) async {
    final page = await _remote.fetchProductsPage(
      storeId: storeId,
      limit: limit,
      cursorProductId: cursorProductId,
    );
    return ProductPageResult(
      items: page.items.map((e) => e.toEntity()).toList(),
      nextCursor: page.nextCursor,
    );
  }

  @override
  Future<List<ProductEntity>> searchProducts({
    required String query,
    String? city,
  }) async {
    final list = await _remote.searchProducts(query: query, city: city);
    return list.map((e) => e.toEntity()).toList();
  }
}
