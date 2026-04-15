import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/domain/entities/user_entity.dart';
import 'package:quickmarket/domain/repositories/auth_repository.dart';

/// Caso de uso: registro con email y contraseña.
class RegisterWithEmailUseCase {
  RegisterWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      return await _repository.registerWithEmail(
        email: email.trim(),
        password: password,
        displayName: displayName.trim(),
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw AuthFailure('No se pudo registrar: $e');
    }
  }
}
