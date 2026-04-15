import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmarket/domain/entities/notification_entity.dart';
import 'package:quickmarket/presentation/providers/di_providers.dart';

/// Notificaciones del usuario autenticado.
final myNotificationsStreamProvider =
    StreamProvider<List<NotificationEntity>>((ref) {
  final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(notificationRepositoryProvider).watchUserNotifications(uid);
});

/// Cantidad de notificaciones sin leer (para badge en la app bar).
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final async = ref.watch(myNotificationsStreamProvider);
  return async.when(
    data: (list) => list.where((n) => !n.read).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
