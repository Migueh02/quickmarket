import 'package:quickmarket/domain/entities/order_item_entity.dart';

/// Línea de pedido serializada en Firestore.
class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'unitPrice': unitPrice,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      productId: entity.productId,
      name: entity.name,
      unitPrice: entity.unitPrice,
      quantity: entity.quantity,
    );
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      productId: productId,
      name: name,
      unitPrice: unitPrice,
      quantity: quantity,
    );
  }
}
