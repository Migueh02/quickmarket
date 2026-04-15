/// Fallos de dominio / aplicación (mapeables a mensajes UI).
sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Error genérico de servidor o Firestore.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Credenciales inválidas o sesión expirada.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Recurso no encontrado.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Validación de negocio (carrito vacío, rol incorrecto, etc.).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
