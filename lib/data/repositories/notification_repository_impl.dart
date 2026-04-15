import 'package:quickmarket/data/datasources/firestore_notifications_data_source.dart';
import 'package:quickmarket/domain/entities/notification_entity.dart';
import 'package:quickmarket/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote);

  final FirestoreNotificationsDataSource _remote;

  @override
  Stream<List<NotificationEntity>> watchUserNotifications(String userId) {
    return _remote.watchUserNotifications(userId).map(
          (list) => list.map((e) => e.toEntity()).toList(),
        );
  }

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) {
    return _remote.markRead(
      userId: userId,
      notificationId: notificationId,
    );
  }

  @override
  Future<void> markAllUnreadAsRead(String userId) {
    return _remote.markAllUnreadAsRead(userId: userId);
  }
}
