import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/domain/entities/cart_item.dart';
import 'package:quickmarket/domain/entities/product_entity.dart';
import 'package:quickmarket/domain/entities/store_category.dart';
import 'package:quickmarket/domain/entities/store_entity.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier(this._box) : super(const []) {
    _restore();
  }

  final Box<dynamic> _box;
  static const String _key = 'items';

  void _restore() {
    final raw = _box.get(_key);
    if (raw is! List) {
      state = const [];
      return;
    }
    final items = <CartItem>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final map = Map<String, dynamic>.from(e);
      items.add(
        CartItem(
          product: ProductEntity(
            id: map['productId'] as String? ?? '',
            storeId: map['storeId'] as String? ?? '',
            name: map['name'] as String? ?? '',
            description: map['description'] as String? ?? '',
            price: (map['price'] as num?)?.toDouble() ?? 0,
            imageUrl: map['imageUrl'] as String? ?? '',
            stock: (map['stock'] as num?)?.toInt() ?? 0,
            subcategory: map['subcategory'] as String? ?? 'General',
          ),
          store: StoreEntity(
            id: map['storeId'] as String? ?? '',
            name: map['storeName'] as String? ?? 'Tienda',
            description: map['storeDescription'] as String? ?? '',
            imageUrl: map['storeImageUrl'] as String? ?? '',
            rating: (map['storeRating'] as num?)?.toDouble() ?? 0,
            deliveryTime: (map['storeDeliveryTime'] as num?)?.toInt() ?? 30,
            category: StoreCategory.fromFirestore(
              map['storeCategory'] as String?,
            ),
            city: map['storeCity'] as String? ?? '',
          ),
          quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        ),
      );
    }
    state = items;
  }

  Future<void> _persist() async {
    final list = state
        .map(
          (item) => <String, dynamic>{
            'productId': item.product.id,
            'storeId': item.store.id,
            'name': item.product.name,
            'description': item.product.description,
            'price': item.product.price,
            'imageUrl': item.product.imageUrl,
            'stock': item.product.stock,
            'subcategory': item.product.subcategory,
            'quantity': item.quantity,
            'storeName': item.store.name,
            'storeDescription': item.store.description,
            'storeImageUrl': item.store.imageUrl,
            'storeRating': item.store.rating,
            'storeDeliveryTime': item.store.deliveryTime,
            'storeCategory': item.store.category.firestoreValue,
            'storeCity': item.store.city,
          },
        )
        .toList();
    await _box.put(_key, list);
  }

  /// Solo se permite una tienda activa a la vez.
  void add({
    required ProductEntity product,
    required StoreEntity store,
    int quantity = 1,
  }) async {
    if (quantity < 1) {
      throw const ValidationFailure('Cantidad inválida');
    }
    if (state.isNotEmpty && state.first.store.id != store.id) {
      throw const ValidationFailure(
        'Ya tienes productos de otra tienda. Vacía el carrito para continuar.',
      );
    }
    final idx = state.indexWhere((l) => l.product.id == product.id);
    if (idx >= 0) {
      final current = state[idx];
      final nextQty = current.quantity + quantity;
      if (nextQty > product.stock) {
        throw ValidationFailure('Stock máximo: ${product.stock}');
      }
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == idx) current.copyWith(quantity: nextQty) else state[i],
      ];
    } else {
      if (quantity > product.stock) {
        throw ValidationFailure('Stock máximo: ${product.stock}');
      }
      state = [...state, CartItem(product: product, store: store, quantity: quantity)];
    }
    unawaited(_persist());
  }

  void remove(String productId) {
    state = state.where((l) => l.product.id != productId).toList();
    unawaited(_persist());
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity < 1) {
      remove(productId);
      return;
    }
    state = [
      for (final line in state)
        if (line.product.id == productId)
          line.copyWith(
            quantity: quantity.clamp(1, line.product.stock),
          )
        else
          line,
    ];
    unawaited(_persist());
  }

  void clear() {
    state = const [];
    unawaited(_box.put(_key, <Map<String, dynamic>>[]));
  }

  // Alias compatibilidad
  void addItem({
    required ProductEntity product,
    required StoreEntity store,
    int quantity = 1,
  }) => add(product: product, store: store, quantity: quantity);

  void removeLine(String productId) => remove(productId);

  double get subtotal =>
      state.fold<double>(0, (sum, line) => sum + line.lineTotal);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(Hive.box<dynamic>('quickmarket_cart_box')),
);
