import 'package:quickmarket/domain/entities/order_entity.dart';
import 'package:quickmarket/domain/entities/order_item_entity.dart';
import 'package:quickmarket/domain/entities/order_status.dart';
import 'package:quickmarket/domain/entities/payment_method.dart';

/// Gestión de pedidos del cliente y actualización de estado.
abstract class OrderRepository {
  Stream<List<OrderEntity>> watchOrdersForUser(String userId);
  Stream<OrderEntity?> watchOrder(String orderId);
  Future<String> createOrder({
    required String userId,
    required String storeId,
    required String storeName,
    required List<OrderItemEntity> items,
    required String deliveryAddress,
    required PaymentMethod paymentMethod,
  });
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    bool? availableForDrivers,
  });
}
