import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/domain/entities/order_item_entity.dart';
import 'package:quickmarket/domain/entities/payment_method.dart';
import 'package:quickmarket/domain/repositories/order_repository.dart';

/// Caso de uso: crear pedido a partir del carrito.
class PlaceOrderUseCase {
  PlaceOrderUseCase(this._repository);

  final OrderRepository _repository;

  Future<String> call({
    required String userId,
    required String storeId,
    required String storeName,
    required List<OrderItemEntity> items,
    required String deliveryAddress,
    required PaymentMethod paymentMethod,
  }) async {
    if (items.isEmpty) {
      throw const ValidationFailure('El carrito está vacío.');
    }
    if (deliveryAddress.trim().isEmpty) {
      throw const ValidationFailure('Indica una dirección de entrega.');
    }
    return _repository.createOrder(
      userId: userId,
      storeId: storeId,
      storeName: storeName,
      items: items,
      deliveryAddress: deliveryAddress.trim(),
      paymentMethod: paymentMethod,
    );
  }
}
