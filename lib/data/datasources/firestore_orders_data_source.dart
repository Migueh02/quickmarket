import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickmarket/core/constants/firestore_paths.dart';
import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/data/datasources/firestore_notifications_data_source.dart';
import 'package:quickmarket/data/models/order_item_model.dart';
import 'package:quickmarket/data/models/order_model.dart';
import 'package:quickmarket/domain/entities/notification_kind.dart';
import 'package:quickmarket/domain/entities/order_item_entity.dart';
import 'package:quickmarket/domain/entities/order_status.dart';
import 'package:quickmarket/domain/entities/payment_method.dart';

/// Persistencia de pedidos y disparadores simples de notificaciones.
class FirestoreOrdersDataSource {
  FirestoreOrdersDataSource({
    required FirebaseFirestore firestore,
    required FirestoreNotificationsDataSource notifications,
  })  : _firestore = firestore,
        _notifications = notifications;

  final FirebaseFirestore _firestore;
  final FirestoreNotificationsDataSource _notifications;

  Stream<List<OrderModel>> watchOrdersForUser(String userId) {
    return _firestore
        .collection(FirestorePaths.orders)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(OrderModel.fromFirestore).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<OrderModel?> watchOrder(String orderId) {
    return _firestore
        .doc(FirestorePaths.orderDoc(orderId))
        .snapshots()
        .map((d) => d.exists ? OrderModel.fromFirestore(d) : null);
  }

  Future<String> createOrder({
    required String userId,
    required String storeId,
    required String storeName,
    required List<OrderItemEntity> items,
    required String deliveryAddress,
    required PaymentMethod paymentMethod,
  }) async {
    final itemModels = items.map(OrderItemModel.fromEntity).toList();
    final totalAmount = itemModels.fold<double>(
      0,
      (running, e) => running + e.unitPrice * e.quantity,
    );
    final doc = _firestore.collection(FirestorePaths.orders).doc();
    final model = OrderModel(
      id: doc.id,
      userId: userId,
      storeId: storeId,
      storeName: storeName,
      items: itemModels,
      status: OrderStatus.pending,
      totalAmount: totalAmount,
      address: deliveryAddress,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      driverId: null,
      driverName: null,
      availableForDrivers: false,
    );
    await _firestore.runTransaction((tx) async {
      for (final item in itemModels) {
        final productRef = _firestore.doc(
          '${FirestorePaths.productsCol(storeId)}/${item.productId}',
        );
        final productSnap = await tx.get(productRef);
        if (!productSnap.exists) {
          throw ValidationFailure(
            'Producto ${item.name} no disponible.',
          );
        }
        final currentStock =
            (productSnap.data()?['stock'] as num?)?.toInt() ?? 0;
        if (currentStock < item.quantity) {
          throw ValidationFailure(
            'Stock insuficiente para ${item.name}. Disponible: $currentStock',
          );
        }
        tx.update(productRef, {'stock': currentStock - item.quantity});
      }
      tx.set(doc, model.toCreateMap());
    });
    await _safePushNotification(
      userId: userId,
      title: 'Pedido recibido',
      body:
          '$storeName registró tu pedido. Te avisamos aquí en cada cambio de estado.',
      orderId: doc.id,
      kind: NotificationKind.orderPlaced,
    );
    return doc.id;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    bool? availableForDrivers,
    String? driverId,
    String? driverName,
  }) async {
    final ref = _firestore.doc(FirestorePaths.orderDoc(orderId));
    final snap = await ref.get();
    if (!snap.exists) return;
    final current = OrderModel.fromFirestore(snap);
    bool? driversFlag = availableForDrivers;
    if (status == OrderStatus.readyForPickup) {
      driversFlag = true;
    }
    final patch = <String, dynamic>{
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
      if (driversFlag != null) 'availableForDrivers': driversFlag,
      if (driverId != null) 'driverId': driverId,
      if (driverName != null) 'driverName': driverName,
    };
    await ref.set(patch, SetOptions(merge: true));

    // Aviso al cliente en cada paso relevante del pedido.
    switch (status) {
      case OrderStatus.confirmed:
        await _safePushNotification(
          userId: current.userId,
          title: 'Pedido confirmado',
          body:
              '${current.storeName} confirmó tu pedido. Pronto pasará a cocina.',
          orderId: orderId,
          kind: NotificationKind.orderConfirmed,
        );
        break;
      case OrderStatus.inPreparation:
        await _safePushNotification(
          userId: current.userId,
          title: 'En cocina',
          body: 'Tu pedido en ${current.storeName} está en preparación.',
          orderId: orderId,
          kind: NotificationKind.orderPreparing,
        );
        break;
      case OrderStatus.preparing:
        await _safePushNotification(
          userId: current.userId,
          title: 'Casi listo',
          body:
              'Siguen preparando tu pedido en ${current.storeName}. Te avisamos '
              'cuando esté listo para envío.',
          orderId: orderId,
          kind: NotificationKind.orderPreparing,
        );
        break;
      case OrderStatus.readyForPickup:
        await _safePushNotification(
          userId: current.userId,
          title: 'Listo para reparto',
          body:
              'Tu pedido está listo. Un repartidor podrá tomarlo en la app.',
          orderId: orderId,
          kind: NotificationKind.orderReady,
        );
        break;
      case OrderStatus.assigned:
        await _safePushNotification(
          userId: current.userId,
          title: 'Repartidor asignado',
          body:
              '${driverName ?? 'Un repartidor'} tomó tu pedido de ${current.storeName}.',
          orderId: orderId,
          kind: NotificationKind.driverAssigned,
        );
        break;
      case OrderStatus.delivering:
      case OrderStatus.onTheWay:
        await _safePushNotification(
          userId: current.userId,
          title: 'En camino',
          body: 'Tu pedido va en ruta hacia la dirección de entrega.',
          orderId: orderId,
          kind: NotificationKind.onTheWay,
        );
        break;
      case OrderStatus.delivered:
        await _safePushNotification(
          userId: current.userId,
          title: 'Entregado',
          body:
              'Pedido completado. ¡Gracias por usar QuickMarket!',
          orderId: orderId,
          kind: NotificationKind.delivered,
        );
        break;
      case OrderStatus.cancelled:
        await _safePushNotification(
          userId: current.userId,
          title: 'Pedido cancelado',
          body: 'Tu pedido en ${current.storeName} fue cancelado.',
          orderId: orderId,
          kind: NotificationKind.cancelled,
        );
        break;
      default:
        break;
    }
  }

  Future<void> _safePushNotification({
    required String userId,
    required String title,
    required String body,
    String? orderId,
    NotificationKind kind = NotificationKind.generic,
  }) async {
    try {
      await _notifications.pushNotification(
        userId: userId,
        title: title,
        body: body,
        orderId: orderId,
        kind: kind,
      );
    } catch (e, st) {
      developer.log('pushNotification failed', error: e, stackTrace: st);
    }
  }
}
