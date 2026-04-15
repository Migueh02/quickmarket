import 'package:quickmarket/domain/entities/product_entity.dart';
import 'package:quickmarket/domain/entities/store_entity.dart';

/// Ítem del carrito persistido localmente.
class CartItem {
  const CartItem({
    required this.product,
    required this.store,
    required this.quantity,
  });

  final ProductEntity product;
  final StoreEntity store;
  final int quantity;

  double get lineTotal => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      store: store,
      quantity: quantity ?? this.quantity,
    );
  }
}
