import 'package:quickmarket/data/datasources/firestore_delivery_data_source.dart';
import 'package:quickmarket/domain/entities/order_entity.dart';
import 'package:quickmarket/domain/entities/order_status.dart';
import 'package:quickmarket/domain/repositories/delivery_repository.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl(this._remote);

  final FirestoreDeliveryDataSource _remote;

  @override
  Stream<List<OrderEntity>> watchActiveDeliveries(String driverId) {
    return _remote.watchActiveDeliveries(driverId).map(
          (list) => list.map((e) => e.toEntity()).toList(),
        );
  }

  @override
  Stream<List<OrderEntity>> watchAssignableOrders() {
    return _remote.watchAssignableOrders().map(
          (list) => list.map((e) => e.toEntity()).toList(),
        );
  }

  @override
  Future<void> assignDriverToOrder({
    required String orderId,
    required String driverId,
    required String driverName,
  }) {
    return _remote.assignDriver(
      orderId: orderId,
      driverId: driverId,
      driverName: driverName,
    );
  }

  @override
  Future<void> advanceDeliveryStatus({
    required String orderId,
    required OrderStatus nextStatus,
  }) {
    return _remote.updateDeliveryStatus(
      orderId: orderId,
      nextStatus: nextStatus,
    );
  }
}
