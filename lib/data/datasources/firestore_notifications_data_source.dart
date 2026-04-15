import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickmarket/core/constants/firestore_paths.dart';
import 'package:quickmarket/data/models/notification_model.dart';
import 'package:quickmarket/domain/entities/notification_kind.dart';

/// Notificaciones por usuario (subcolección).
class FirestoreNotificationsDataSource {
  FirestoreNotificationsDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<NotificationModel>> watchUserNotifications(String userId) {
    return _firestore
        .collection(FirestorePaths.userNotificationsCol(userId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => NotificationModel.fromFirestore(
                  d,
                  userId: userId,
                ),
              )
              .toList(),
        );
  }

  Future<void> markRead({
    required String userId,
    required String notificationId,
  }) async {
    await _firestore
        .doc(
          '${FirestorePaths.userNotificationsCol(userId)}/$notificationId',
        )
        .set({'read': true}, SetOptions(merge: true));
  }

  /// Marca como leídas hasta [limit] notificaciones pendientes.
  Future<void> markAllUnreadAsRead({
    required String userId,
    int limit = 100,
  }) async {
    final col = _firestore.collection(
      FirestorePaths.userNotificationsCol(userId),
    );
    final snap = await col.where('read', isEqualTo: false).limit(limit).get();
    if (snap.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final d in snap.docs) {
      batch.set(d.reference, {'read': true}, SetOptions(merge: true));
    }
    await batch.commit();
  }

  /// Crea una notificación para el usuario destino.
  Future<void> pushNotification({
    required String userId,
    required String title,
    required String body,
    String? orderId,
    NotificationKind kind = NotificationKind.generic,
  }) async {
    final ref = _firestore
        .collection(FirestorePaths.userNotificationsCol(userId))
        .doc();
    await ref.set(
      NotificationModel(
        id: ref.id,
        userId: userId,
        title: title,
        body: body,
        createdAt: DateTime.now(),
        read: false,
        orderId: orderId,
        kind: kind,
      ).toMap(),
    );
  }
}
