/// Línea de pedido (snapshot de producto al momento de compra).
class OrderItemEntity {
  const OrderItemEntity({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;
}
