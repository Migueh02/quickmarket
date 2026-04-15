import 'package:quickmarket/domain/repositories/auth_repository.dart';

/// Caso de uso: cerrar sesión local y remota.
class SignOutUseCase {
  SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
