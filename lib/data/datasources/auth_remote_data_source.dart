import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickmarket/core/constants/firestore_paths.dart';
import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/data/models/user_model.dart';
import 'package:quickmarket/domain/entities/user_role.dart';

/// Acceso remoto a Firebase Auth y documento de perfil en Firestore.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _auth = firebaseAuth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  UserModel _defaultProfileFromAuthUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: (user.displayName == null || user.displayName!.trim().isEmpty)
          ? 'Usuario'
          : user.displayName!.trim(),
      role: UserRole.customer,
      phone: user.phoneNumber,
      city: 'Bogotá',
    );
  }

  Future<UserModel> _ensureProfileExists(User user) async {
    final existing = await fetchUserProfile(user.uid);
    if (existing != null) {
      return existing;
    }
    final created = _defaultProfileFromAuthUser(user);
    await _firestore.doc(FirestorePaths.userDoc(user.uid)).set(
      created.toMap(),
      SetOptions(merge: true),
    );
    return created;
  }

  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Perfil en tiempo real (rol, nombre, etc.).
  Stream<UserModel?> watchUserProfile(String uid) {
    return _firestore.doc(FirestorePaths.userDoc(uid)).snapshots().asyncMap(
      (doc) async {
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
        // Auto-reparación: cuenta Auth sin documento Firestore.
        final user = _auth.currentUser;
        if (user != null && user.uid == uid) {
          return _ensureProfileExists(user);
        }
        return null;
      },
    );
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AuthFailure('Usuario nulo tras el inicio de sesión.');
      }
      final profile = await _ensureProfileExists(user);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Error de autenticación');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AuthFailure('Usuario nulo tras el registro.');
      }
      await user.updateDisplayName(displayName);
      final model = UserModel(
        id: user.uid,
        email: email,
        displayName: displayName,
        role: UserRole.customer,
        phone: null,
        city: 'Bogotá',
      );
      await _firestore.doc(FirestorePaths.userDoc(user.uid)).set(model.toMap());
      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Error de registro');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> updateUserRole({
    required String uid,
    required UserRole role,
  }) async {
    await _firestore.doc(FirestorePaths.userDoc(uid)).set(
      {'role': role.name},
      SetOptions(merge: true),
    );
  }

  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? phone,
    String? city,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != uid) {
      throw const AuthFailure('Sesión inválida para actualizar el perfil.');
    }
    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
    }
    await _firestore.doc(FirestorePaths.userDoc(uid)).set(
      {
        if (displayName != null) 'displayName': displayName,
        if (phone != null) 'phone': phone,
        if (city != null) 'city': city,
      },
      SetOptions(merge: true),
    );
  }
}
