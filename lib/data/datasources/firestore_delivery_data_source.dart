import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickmarket/core/constants/firestore_paths.dart';
import 'package:quickmarket/data/datasources/firestore_notifications_data_source.dart';
import 'package:quickmarket/data/models/order_model.dart';
import 'package:quickmarket/domain/entities/notification_kind.dart';
import 'package:quickmarket/domain/entities/order_status.dart';

/// Consultas y actualizaciones orientadas al repartidor.
class FirestoreDeliveryDataSource {
  FirestoreDeliveryDataSource({
    required FirebaseFirestore firestore,
    required FirestoreNotificationsDataSource notifications,
  })  : _firestore = firestore,
        _notifications = notifications;

  final FirebaseFirestore _firestore;
  final FirestoreNotificationsDataSource _notifications;

  /// Pedidos listos para asignación y aún sin repartidor.
  Stream<List<OrderModel>> watchActiveDeliveries(String driverId) {
    return _firestore
        .collection(FirestorePaths.orders)
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(OrderModel.fromFirestore).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return list
              .where(
                (o) =>
                    o.status != OrderStatus.delivered &&
                    o.status != OrderStatus.cancelled,
              )
              .toList();
        });
  }

  Stream<List<OrderModel>> watchAssignableOrders() {
    return _firestore
        .collection(FirestorePaths.orders)
        .where('status', isEqualTo: OrderStatus.readyForPickup.firestoreValue)
        .where('availableForDrivers', isEqualTo: true)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map(OrderModel.fromFirestore)
              .where(
                (o) => o.driverId == null || o.driverId!.isEmpty,
              )
              .toList();
        });
  }

  Future<void> assignDriver({
    required String orderId,
    required String driverId,
    required String driverName,
  }) async {
    final ref = _firestore.doc(FirestorePaths.orderDoc(orderId));
    await ref.set(
      {
        'driverId': driverId,
        'driverName': driverName,
        'status': OrderStatus.assigned.firestoreValue,
        'availableForDrivers': false,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    final snap = await ref.get();
    if (snap.exists) {
      final order = OrderModel.fromFirestore(snap);
      await _safePushNotification(
        userId: order.userId,
        title: 'Repartidor asignado',
        body: '$driverName tomó tu pedido.',
        orderId: orderId,
        kind: NotificationKind.driverAssigned,
      );
      await _safePushNotification(
        userId: driverId,
        title: 'Pedido tomado',
        body: 'Tomaste el pedido de ${order.storeName}.',
        orderId: orderId,
        kind: NotificationKind.driverAssigned,
      );
    }
  }

  Future<void> updateDeliveryStatus({
    required String orderId,
    required OrderStatus nextStatus,
  }) async {
    final ref = _firestore.doc(FirestorePaths.orderDoc(orderId));
    await ref.set(
      {
        'status': nextStatus.firestoreValue,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    final snap = await ref.get();
    if (!snap.exists) return;
    final order = OrderModel.fromFirestore(snap);
    switch (nextStatus) {
      case OrderStatus.pickedUp:
        await _safePushNotification(
          userId: order.userId,
          title: 'Pedido recogido',
          body:
              'El repartidor recogió tu pedido de ${order.storeName}. Pronto sale a entrega.',
          orderId: orderId,
          kind: NotificationKind.pickedUp,
        );
        break;
      case OrderStatus.delivering:
      case OrderStatus.onTheWay:
        await _safePushNotification(
          userId: order.userId,
          title: 'En camino',
          body: 'Tu pedido va hacia tu dirección.',
          orderId: orderId,
          kind: NotificationKind.onTheWay,
        );
        break;
      case OrderStatus.delivered:
        await _safePushNotification(
          userId: order.userId,
          title: 'Entregado',
          body: 'Tu pedido fue entregado. ¡Gracias por tu compra!',
          orderId: orderId,
          kind: NotificationKind.delivered,
        );
        if (order.driverId != null && order.driverId!.isNotEmpty) {
          await _safePushNotification(
            userId: order.driverId!,
            title: 'Entrega finalizada',
            body: 'Completaste la entrega de ${order.storeName}.',
            orderId: orderId,
            kind: NotificationKind.delivered,
          );
        }
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
