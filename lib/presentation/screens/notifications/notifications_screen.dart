import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmarket/core/constants/app_strings.dart';
import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/core/utils/relative_time_format.dart';
import 'package:quickmarket/domain/entities/notification_entity.dart';
import 'package:quickmarket/domain/entities/notification_kind.dart';
import 'package:quickmarket/presentation/providers/di_providers.dart';
import 'package:quickmarket/presentation/providers/notification_stream_providers.dart';

/// Bandeja de notificaciones in-app con iconos por tipo y tiempo relativo.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotes = ref.watch(myNotificationsStreamProvider);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notificationsTitle),
        actions: [
          asyncNotes.maybeWhen(
            data: (items) {
              final unread = items.where((n) => !n.read).length;
              if (unread == 0 || uid == null) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(markAllNotificationsReadUseCaseProvider)
                        .call(userId: uid);
                  } on Failure catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message)),
                      );
                    }
                  }
                },
                child: const Text('Marcar leídas'),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: asyncNotes.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 72,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sin avisos todavía',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cuando hagas un pedido o cambie su estado, '
                      'verás el aviso aquí al instante.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final n = items[i];
              return _NotificationTile(notification: n);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final NotificationEntity notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final scheme = Theme.of(context).colorScheme;
    final style = _presentationFor(notification.kind, scheme);
    final unread = !notification.read;

    return Material(
      color: unread
          ? scheme.primaryContainer.withValues(alpha: 0.35)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (uid == null) return;
          try {
            await ref.read(markNotificationReadUseCaseProvider).call(
                  userId: uid,
                  notificationId: notification.id,
                );
            if (notification.orderId != null && context.mounted) {
              context.push('/orders/${notification.orderId}');
            }
          } on Failure catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message)),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: style.avatarBg,
                foregroundColor: style.avatarFg,
                child: Icon(style.icon, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight:
                                      unread ? FontWeight.w700 : FontWeight.w600,
                                ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4, left: 6),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatRelativeTimeEs(notification.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
              if (notification.orderId != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: scheme.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationVisual {
  const _NotificationVisual({
    required this.icon,
    required this.avatarBg,
    required this.avatarFg,
  });

  final IconData icon;
  final Color avatarBg;
  final Color avatarFg;
}

_NotificationVisual _presentationFor(
  NotificationKind kind,
  ColorScheme scheme,
) {
  switch (kind) {
    case NotificationKind.orderPlaced:
      return _NotificationVisual(
        icon: Icons.receipt_long_rounded,
        avatarBg: scheme.primaryContainer,
        avatarFg: scheme.onPrimaryContainer,
      );
    case NotificationKind.orderConfirmed:
      return _NotificationVisual(
        icon: Icons.task_alt_rounded,
        avatarBg: scheme.secondaryContainer,
        avatarFg: scheme.onSecondaryContainer,
      );
    case NotificationKind.orderPreparing:
      return _NotificationVisual(
        icon: Icons.restaurant_rounded,
        avatarBg: scheme.tertiaryContainer,
        avatarFg: scheme.onTertiaryContainer,
      );
    case NotificationKind.orderReady:
      return _NotificationVisual(
        icon: Icons.inventory_2_outlined,
        avatarBg: scheme.primaryContainer,
        avatarFg: scheme.onPrimaryContainer,
      );
    case NotificationKind.driverAssigned:
      return _NotificationVisual(
        icon: Icons.delivery_dining_rounded,
        avatarBg: scheme.secondaryContainer,
        avatarFg: scheme.onSecondaryContainer,
      );
    case NotificationKind.pickedUp:
      return _NotificationVisual(
        icon: Icons.shopping_bag_outlined,
        avatarBg: scheme.surfaceContainerHigh,
        avatarFg: scheme.onSurfaceVariant,
      );
    case NotificationKind.onTheWay:
      return _NotificationVisual(
        icon: Icons.moped_rounded,
        avatarBg: scheme.primaryContainer,
        avatarFg: scheme.onPrimaryContainer,
      );
    case NotificationKind.delivered:
      return _NotificationVisual(
        icon: Icons.done_all_rounded,
        avatarBg: scheme.tertiaryContainer,
        avatarFg: scheme.onTertiaryContainer,
      );
    case NotificationKind.cancelled:
      return _NotificationVisual(
        icon: Icons.cancel_outlined,
        avatarBg: scheme.errorContainer,
        avatarFg: scheme.onErrorContainer,
      );
    case NotificationKind.generic:
      return _NotificationVisual(
        icon: Icons.notifications_rounded,
        avatarBg: scheme.surfaceContainerHigh,
        avatarFg: scheme.onSurfaceVariant,
      );
  }
}
