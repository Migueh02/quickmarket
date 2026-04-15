import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickmarket/domain/entities/user_entity.dart';
import 'package:quickmarket/domain/entities/user_role.dart';

/// Modelo de usuario persistido en Firestore.
class UserModel {
  const UserModel({
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
  final String? city;

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: _parseRole(data['role'] as String?),
      phone: data['phone'] as String?,
      city: data['city'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final cityVal = city;
    return {
      'email': email,
      'displayName': displayName,
      'role': role.name,
      if (phone != null) 'phone': phone,
      if (cityVal != null && cityVal.isNotEmpty) 'city': cityVal,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      role: role,
      phone: phone,
      city: city,
    );
  }

  static UserRole _parseRole(String? raw) {
    switch (raw) {
      case 'driver':
        return UserRole.driver;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}
