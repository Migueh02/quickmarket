import 'package:quickmarket/domain/entities/order_entity.dart';
import 'package:quickmarket/domain/entities/order_status.dart';

/// Asignación de repartidor y avance de entrega.
abstract class DeliveryRepository {
  /// Pedidos listos para ser tomados por un repartidor.
  Stream<List<OrderEntity>> watchAssignableOrders();

  /// Pedidos asignados al repartidor aún no entregados.
  Stream<List<OrderEntity>> watchActiveDeliveries(String driverId);

  Future<void> assignDriverToOrder({
    required String orderId,
    required String driverId,
    required String driverName,
  });

  Future<void> advanceDeliveryStatus({
    required String orderId,
    required OrderStatus nextStatus,
  });
}
