import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/domain/entities/user_entity.dart';
import 'package:quickmarket/domain/repositories/auth_repository.dart';

/// Caso de uso: inicio de sesión con email y contraseña.
class SignInWithEmailUseCase {
  SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    try {
      return await _repository.signInWithEmail(
        email: email.trim(),
        password: password,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw AuthFailure('No se pudo iniciar sesión: $e');
    }
  }
}
