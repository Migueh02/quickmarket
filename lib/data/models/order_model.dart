import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickmarket/data/models/order_item_model.dart';
import 'package:quickmarket/domain/entities/order_entity.dart';
import 'package:quickmarket/domain/entities/order_status.dart';
import 'package:quickmarket/domain/entities/payment_method.dart';

/// Modelo de pedido en Firestore.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.storeName,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.address,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.driverId,
    this.driverName,
    required this.availableForDrivers,
  });

  final String id;
  final String userId;
  final String storeId;
  final String storeName;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final double totalAmount;
  final String address;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? driverId;
  final String? driverName;
  final bool availableForDrivers;

  factory OrderModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final rawItems = data['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      storeId: data['storeId'] as String? ?? '',
      storeName: data['storeName'] as String? ?? '',
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItemModel.fromMap)
          .toList(),
      status: OrderStatus.fromFirestore(
        data['status'] as String? ?? OrderStatus.pending.firestoreValue,
      ),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ??
          (data['total'] as num?)?.toDouble() ??
          0,
      address: data['address'] as String? ??
          data['deliveryAddress'] as String? ??
          '',
      paymentMethod:
          PaymentMethod.fromFirestore(data['paymentMethod'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      driverId: data['driverId'] as String?,
      driverName: data['driverName'] as String?,
      availableForDrivers: data['availableForDrivers'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'userId': userId,
      'storeId': storeId,
      'storeName': storeName,
      'items': items.map((e) => e.toMap()).toList(),
      'status': status.firestoreValue,
      'totalAmount': totalAmount,
      'address': address,
      'paymentMethod': paymentMethod.firestoreValue,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'driverId': driverId,
      'driverName': driverName,
      'availableForDrivers': availableForDrivers,
    };
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      storeId: storeId,
      storeName: storeName,
      items: items.map((e) => e.toEntity()).toList(),
      status: status,
      totalAmount: totalAmount,
      address: address,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      updatedAt: updatedAt,
      driverId: driverId,
      driverName: driverName,
      availableForDrivers: availableForDrivers,
    );
  }
}
