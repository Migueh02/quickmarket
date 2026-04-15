import 'package:quickmarket/domain/repositories/notification_repository.dart';

/// Caso de uso: marcar notificación como leída.
class MarkNotificationReadUseCase {
  MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<void> call({
    required String userId,
    required String notificationId,
  }) {
    return _repository.markAsRead(
      userId: userId,
      notificationId: notificationId,
    );
  }
}
