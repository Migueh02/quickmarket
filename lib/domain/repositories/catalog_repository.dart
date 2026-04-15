import 'package:quickmarket/domain/entities/product_entity.dart';
import 'package:quickmarket/domain/entities/store_entity.dart';
import 'package:quickmarket/domain/value_objects/product_page_result.dart';

/// Catálogo de tiendas y productos (Firestore + caché local).
abstract class CatalogRepository {
  /// Tiendas opcionalmente filtradas por ciudad (simula cercanía).
  Stream<List<StoreEntity>> watchStores({String? city});

  /// Paginación de productos por tienda (orden por campo `name`).
  Future<ProductPageResult> fetchProductsPage({
    required String storeId,
    int limit = 20,
    String? cursorProductId,
  });

  /// Búsqueda en subcolecciones `products` (Firestore + filtro local).
  Future<List<ProductEntity>> searchProducts({
    required String query,
    String? city,
  });
}
