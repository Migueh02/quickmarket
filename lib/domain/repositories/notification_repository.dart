import 'package:quickmarket/domain/entities/notification_entity.dart';

/// Notificaciones persistidas (Firestore). Ampliable a FCM.
abstract class NotificationRepository {
  Stream<List<NotificationEntity>> watchUserNotifications(String userId);
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  });
  Future<void> markAllUnreadAsRead(String userId);
}
