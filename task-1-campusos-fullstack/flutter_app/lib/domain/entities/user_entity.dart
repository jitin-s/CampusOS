/// User roles according to docs/02_SRD.md Section FR-001
enum UserRole {
  student,
  faculty,
  staff,
  admin;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'faculty':
        return UserRole.faculty;
      case 'staff':
        return UserRole.staff;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}

/// Core User entity with multi-tenant campus_id support
class UserEntity {
  final String id;
  final String campusId;
  final String email;
  final String name;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.campusId,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isStudent => role == UserRole.student;
  bool get isStaff => role == UserRole.staff;
}
