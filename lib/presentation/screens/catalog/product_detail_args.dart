import 'package:quickmarket/domain/entities/product_entity.dart';
import 'package:quickmarket/domain/entities/store_entity.dart';

/// Argumentos de navegación a [ProductDetailScreen].
class ProductDetailArgs {
  const ProductDetailArgs({
    required this.product,
    required this.store,
  });

  final ProductEntity product;
  final StoreEntity store;
}
