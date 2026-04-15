import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickmarket/data/datasources/auth_remote_data_source.dart';
import 'package:quickmarket/domain/entities/user_entity.dart';
import 'package:quickmarket/domain/entities/user_role.dart';
import 'package:quickmarket/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;
  UserEntity? _cache;

  @override
  Stream<User?> authStateChanges() => _remote.authStateChanges();

  @override
  Stream<UserEntity?> watchProfile(String uid) {
    return _remote.watchUserProfile(uid).map((model) {
      final entity = model?.toEntity();
      _cache = entity;
      return entity;
    });
  }

  @override
  UserEntity? get currentProfileCache => _cache;

  @override
  Future<UserEntity?> fetchProfile(String uid) async {
    final model = await _remote.fetchUserProfile(uid);
    _cache = model?.toEntity();
    return _cache;
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final model = await _remote.signInWithEmail(
      email: email,
      password: password,
    );
    _cache = model.toEntity();
    return _cache!;
  }

  @override
  Future<UserEntity> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final model = await _remote.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
    _cache = model.toEntity();
    return _cache!;
  }

  @override
  Future<void> signOut() async {
    _cache = null;
    await _remote.signOut();
  }

  @override
  Future<void> updateRole({
    required String uid,
    required UserRole role,
  }) async {
    await _remote.updateUserRole(uid: uid, role: role);
    _cache = await fetchProfile(uid);
  }

  @override
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? phone,
    String? city,
  }) async {
    await _remote.updateProfile(
      uid: uid,
      displayName: displayName,
      phone: phone,
      city: city,
    );
    _cache = await fetchProfile(uid);
  }
}
