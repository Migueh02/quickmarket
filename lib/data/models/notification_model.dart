import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickmarket/domain/entities/notification_entity.dart';
import 'package:quickmarket/domain/entities/notification_kind.dart';

/// Notificación persistida bajo `users/{uid}/notifications`.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    this.orderId,
    this.kind = NotificationKind.generic,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String? orderId;
  final NotificationKind kind;

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String userId,
  }) {
    final data = doc.data() ?? {};
    return NotificationModel(
      id: doc.id,
      userId: userId,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      read: data['read'] as bool? ?? false,
      orderId: data['orderId'] as String?,
      kind: NotificationKind.fromFirestore(data['kind'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
      'read': read,
      'kind': kind.firestoreValue,
      if (orderId != null) 'orderId': orderId,
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read,
      orderId: orderId,
      kind: kind,
    );
  }
}
