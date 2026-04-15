/// Producto publicado por una tienda.
class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.subcategory,
  });

  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;

  /// Agrupa productos dentro de la tienda (góndolas, pasillos, etc.).
  final String subcategory;

  bool get inStock => stock > 0;
}
