import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickmarket/core/utils/firestore_parsers.dart';
import 'package:quickmarket/domain/entities/store_category.dart';
import 'package:quickmarket/domain/entities/store_entity.dart';

/// Modelo de tienda en Firestore.
class StoreModel {
  const StoreModel({
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
  final int deliveryTime;
  final StoreCategory category;
  final String city;

  factory StoreModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final delivery =
        FirestoreParsers.toInt(data['deliveryTime'], fallback: 0) != 0
            ? FirestoreParsers.toInt(data['deliveryTime'], fallback: 30)
            : FirestoreParsers.toInt(data['deliveryEtaMinutes'], fallback: 30);
    return StoreModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Tienda',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      rating: FirestoreParsers.toDouble(data['rating'], fallback: 0),
      deliveryTime: delivery,
      category: StoreCategory.fromFirestore(data['category'] as String?),
      city: data['city'] as String? ?? '',
    );
  }

  StoreEntity toEntity() {
    return StoreEntity(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      rating: rating,
      deliveryTime: deliveryTime,
      category: category,
      city: city,
    );
  }
}
