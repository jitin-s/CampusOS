import '../entities/user_entity.dart';

/// Contract for Authentication operations (Dependency Inversion).
abstract class AuthRepository {
  /// Stream of user session changes
  Stream<UserEntity?> get authStateChanges;

  /// Currently authenticated user
  UserEntity? get currentUser;

  /// Sign in with email and password
  Future<UserEntity> signInWithPassword({
    required String email,
    required String password,
  });

  /// Sign up with email, password, and campus context
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String name,
    required String campusId,
    UserRole role = UserRole.student,
  });

  /// Sign out current user
  Future<void> signOut();
}
