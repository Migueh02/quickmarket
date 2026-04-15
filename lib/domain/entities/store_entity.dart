import 'package:quickmarket/domain/entities/store_category.dart';

/// Tienda que ofrece productos en el catálogo.
class StoreEntity {
  const StoreEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.deliveryTime,
    required this.category,
    required this.city,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;

  /// Tiempo estimado de entrega en minutos.
  final int deliveryTime;
  final StoreCategory category;

  /// Ciudad para simular tiendas cercanas (filtro en catálogo).
  final String city;

  /// Alias legado / compatibilidad con pedidos anteriores.
  int get deliveryEtaMinutes => deliveryTime;

  /// Placeholder cuando solo tenemos `storeId` (p. ej. búsqueda sin tienda en caché).
  factory StoreEntity.minimal({
    required String id,
    String name = 'Tienda',
  }) {
    return StoreEntity(
      id: id,
      name: name,
      description: '',
      imageUrl: '',
      rating: 0,
      deliveryTime: 30,
      category: StoreCategory.supermarket,
      city: '',
    );
  }
}
