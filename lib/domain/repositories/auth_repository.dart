import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickmarket/domain/entities/user_entity.dart';
import 'package:quickmarket/domain/entities/user_role.dart';

/// Contrato de autenticación (Firebase Auth + perfil en Firestore).
abstract class AuthRepository {
  Stream<User?> authStateChanges();
  Stream<UserEntity?> watchProfile(String uid);
  UserEntity? get currentProfileCache;
  Future<UserEntity?> fetchProfile(String uid);
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserEntity> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> signOut();
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? phone,
    String? city,
  });

  /// Demo: promover cuenta a repartidor desde la app.
  Future<void> updateRole({
    required String uid,
    required UserRole role,
  });
}
