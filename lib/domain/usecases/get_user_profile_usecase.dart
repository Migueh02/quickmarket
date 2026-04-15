import 'package:quickmarket/domain/entities/user_entity.dart';
import 'package:quickmarket/domain/repositories/auth_repository.dart';

/// Caso de uso: obtener perfil remoto por UID.
class GetUserProfileUseCase {
  GetUserProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity?> call(String uid) => _repository.fetchProfile(uid);
}
