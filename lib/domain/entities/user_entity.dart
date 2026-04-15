import 'package:quickmarket/domain/entities/user_role.dart';

/// Usuario autenticado con perfil extendido en Firestore.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.phone,
    this.city,
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? phone;

  /// Ciudad del cliente para filtrar tiendas cercanas (simulado).
  final String? city;

  bool get isDriver => role == UserRole.driver;
}
