import 'package:quickmarket/domain/repositories/notification_repository.dart';

/// Marca todas las notificaciones pendientes como leídas.
class MarkAllNotificationsReadUseCase {
  MarkAllNotificationsReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<void> call({required String userId}) {
    return _repository.markAllUnreadAsRead(userId);
  }
}
