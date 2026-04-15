import 'package:quickmarket/domain/repositories/delivery_repository.dart';

/// Caso de uso: asignar repartidor a un pedido disponible.
class AssignDriverUseCase {
  AssignDriverUseCase(this._repository);

  final DeliveryRepository _repository;

  Future<void> call({
    required String orderId,
    required String driverId,
    required String driverName,
  }) {
    return _repository.assignDriverToOrder(
      orderId: orderId,
      driverId: driverId,
      driverName: driverName,
    );
  }
}
