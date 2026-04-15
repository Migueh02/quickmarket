import 'package:quickmarket/domain/entities/order_status.dart';
import 'package:quickmarket/domain/repositories/delivery_repository.dart';

/// Caso de uso: avanzar estado logístico del pedido (repartidor).
class AdvanceDeliveryStatusUseCase {
  AdvanceDeliveryStatusUseCase(this._repository);

  final DeliveryRepository _repository;

  Future<void> call({
    required String orderId,
    required OrderStatus nextStatus,
  }) {
    return _repository.advanceDeliveryStatus(
      orderId: orderId,
      nextStatus: nextStatus,
    );
  }
}
