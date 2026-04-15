import 'package:quickmarket/domain/entities/product_entity.dart';

/// Página de resultados de productos (paginación cursor-based).
class ProductPageResult {
  const ProductPageResult({
    required this.items,
    this.nextCursor,
  });

  final List<ProductEntity> items;

  /// ID del último documento para `startAfter`; null si no hay más páginas.
  final String? nextCursor;
}
