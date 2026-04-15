import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickmarket/core/utils/firestore_parsers.dart';
import 'package:quickmarket/domain/entities/product_entity.dart';

/// Modelo de producto (subcolección bajo tienda).
class ProductModel {
  const ProductModel({
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
  final String subcategory;

  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String storeId,
  }) {
    final data = doc.data() ?? {};
    return ProductModel(
      id: doc.id,
      storeId: storeId,
      name: data['name'] as String? ?? 'Producto',
      description: data['description'] as String? ?? '',
      price: FirestoreParsers.toDouble(data['price'], fallback: 0),
      imageUrl: data['imageUrl'] as String? ?? '',
      stock: FirestoreParsers.toInt(data['stock'], fallback: 0),
      subcategory: data['subcategory'] as String? ?? 'General',
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      storeId: storeId,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      stock: stock,
      subcategory: subcategory,
    );
  }
}
