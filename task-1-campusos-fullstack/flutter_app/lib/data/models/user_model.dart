import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.campusId,
    required super.email,
    required super.name,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      campusId: json['campus_id'] as String? ?? 'campus-alpha-001',
      email: json['email'] as String? ?? '',
      name:
          json['name'] as String? ??
          (json['email'] as String? ?? '').split('@').first,
      role: UserRole.fromString(json['role'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campus_id': campusId,
      'email': email,
      'name': name,
      'role': role.name,
    };
  }
}
