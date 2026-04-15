import 'package:quickmarket/domain/entities/notification_kind.dart';

/// Notificación in-app persistida en Firestore.
class NotificationEntity {
  const NotificationEntity({
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
}
