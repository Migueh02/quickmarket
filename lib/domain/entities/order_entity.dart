import 'package:quickmarket/domain/entities/order_item_entity.dart';
import 'package:quickmarket/domain/entities/order_status.dart';
import 'package:quickmarket/domain/entities/payment_method.dart';

/// Pedido realizado por un cliente hacia una tienda.
class OrderEntity {
  const OrderEntity({
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
  final List<OrderItemEntity> items;
  final OrderStatus status;
  final double totalAmount;
  final String address;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? driverId;
  final String? driverName;
  final bool availableForDrivers;
}
