import 'package:flutter_test/flutter_test.dart';
import 'package:campusos/core/config/app_config.dart';
import 'package:campusos/domain/entities/user_entity.dart';
import 'package:campusos/data/repositories/supabase_auth_repository.dart';
import 'package:campusos/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  group('CampusOS Foundation Tests', () {
    test('AppConfig has multi-tenant default campus_id', () {
      expect(AppConfig.defaultCampusId, isNotEmpty);
      expect(AppConfig.appName, equals('CampusOS'));
    });

    test('UserEntity role checks operate correctly', () {
      const studentUser = UserEntity(
        id: 'u-1',
        campusId: 'campus-alpha-001',
        email: 'student@campus.edu',
        name: 'Student Name',
        role: UserRole.student,
      );
      expect(studentUser.isStudent, isTrue);
      expect(studentUser.isAdmin, isFalse);

      const adminUser = UserEntity(
        id: 'u-2',
        campusId: 'campus-alpha-001',
        email: 'admin@campus.edu',
        name: 'Admin Name',
        role: UserRole.admin,
      );
      expect(adminUser.isAdmin, isTrue);
      expect(adminUser.isStudent, isFalse);
    });

    test('AuthController authenticates via AuthRepository contract', () async {
      final mockAuthRepo = SupabaseAuthRepository();
      final authController = AuthController(authRepository: mockAuthRepo);

      expect(authController.isAuthenticated, isFalse);

      final loginSuccess = await authController.login(
        'student@campus.edu',
        'secret123',
      );
      expect(loginSuccess, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentUser?.email, equals('student@campus.edu'));
      expect(authController.currentUser?.isStudent, isTrue);

      await authController.logout();
      expect(authController.isAuthenticated, isFalse);
    });
  });
}
