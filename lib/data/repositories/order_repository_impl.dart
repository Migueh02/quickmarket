import 'package:quickmarket/data/datasources/firestore_orders_data_source.dart';
import 'package:quickmarket/domain/entities/order_entity.dart';
import 'package:quickmarket/domain/entities/order_item_entity.dart';
import 'package:quickmarket/domain/entities/order_status.dart';
import 'package:quickmarket/domain/entities/payment_method.dart';
import 'package:quickmarket/domain/repositories/order_repository.dart';

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository(this._remote);

  final FirestoreOrdersDataSource _remote;

  @override
  Stream<List<OrderEntity>> watchOrdersForUser(String userId) {
    return _remote.watchOrdersForUser(userId).map(
          (list) => list.map((e) => e.toEntity()).toList(),
        );
  }

  @override
  Stream<OrderEntity?> watchOrder(String orderId) {
    return _remote.watchOrder(orderId).map(
          (m) => m?.toEntity(),
        );
  }

  @override
  Future<String> createOrder({
    required String userId,
    required String storeId,
    required String storeName,
    required List<OrderItemEntity> items,
    required String deliveryAddress,
    required PaymentMethod paymentMethod,
  }) {
    return _remote.createOrder(
      userId: userId,
      storeId: storeId,
      storeName: storeName,
      items: items,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    bool? availableForDrivers,
  }) {
    return _remote.updateOrderStatus(
      orderId: orderId,
      status: status,
      availableForDrivers: availableForDrivers,
    );
  }
}
