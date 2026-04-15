import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmarket/domain/entities/user_entity.dart';
import 'package:quickmarket/presentation/providers/di_providers.dart';

/// Sesión de FlutterFire (solo UID / presencia).
final authSessionProvider = StreamProvider(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// Perfil de negocio enlazado al UID autenticado.
final userProfileProvider = StreamProvider<UserEntity?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges().asyncExpand((user) {
    if (user == null) {
      return Stream<UserEntity?>.value(null);
    }
    return authRepo.watchProfile(user.uid);
  });
});
