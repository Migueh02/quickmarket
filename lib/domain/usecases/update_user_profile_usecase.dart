import 'package:quickmarket/domain/repositories/auth_repository.dart';

/// Caso de uso: actualizar nombre, teléfono y ciudad del perfil.
class UpdateUserProfileUseCase {
  UpdateUserProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String uid,
    String? displayName,
    String? phone,
    String? city,
  }) {
    return _repository.updateProfile(
      uid: uid,
      displayName: displayName,
      phone: phone,
      city: city,
    );
  }
}
