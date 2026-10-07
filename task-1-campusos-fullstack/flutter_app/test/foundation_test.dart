import 'package:flutter_test/flutter_test.dart';
import 'package:campusos/core/config/app_config.dart';
import 'package:campusos/domain/entities/issue_entity.dart';
import 'package:campusos/domain/entities/lost_found_entity.dart';
import 'package:campusos/domain/entities/user_entity.dart';
import 'package:campusos/data/repositories/supabase_auth_repository.dart';
import 'package:campusos/data/repositories/supabase_issue_repository.dart';
import 'package:campusos/data/repositories/supabase_lost_found_repository.dart';
import 'package:campusos/data/repositories/supabase_queue_repository.dart';
import 'package:campusos/data/repositories/supabase_notice_repository.dart';
import 'package:campusos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:campusos/features/campus_fix/presentation/controllers/campus_fix_controller.dart';
import 'package:campusos/features/lost_found/presentation/controllers/lost_found_controller.dart';
import 'package:campusos/features/queue/presentation/controllers/queue_controller.dart';
import 'package:campusos/features/notices/presentation/controllers/notice_controller.dart';

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

  group('Student Workflow Tests (Phase 2)', () {
    test('CampusFix workflow: report, load, and verify', () async {
      final issueRepo = SupabaseIssueRepository();
      final controller = CampusFixController(issueRepository: issueRepo);

      await controller.loadIssues(campusId: 'campus-alpha-001');
      final initialCount = controller.issues.length;

      final created = await controller.reportIssue(
        campusId: 'campus-alpha-001',
        reporterId: 'user-001',
        category: 'Equipment',
        type: 'Projector',
        description: 'Blown bulb in room 101',
        locationId: 'Room 101',
        severity: IssueSeverity.high,
      );

      expect(created, isNotNull);
      expect(created?.category, equals('Equipment'));
      expect(created?.status, equals(IssueStatus.reported));
      expect(controller.issues.length, equals(initialCount + 1));

      // Student verification closed-loop test
      final verified = await controller.verifyResolution(created!.id);
      expect(verified, isTrue);
      final updatedIssue = controller.issues.firstWhere(
        (e) => e.id == created.id,
      );
      expect(updatedIssue.status, equals(IssueStatus.studentVerified));
    });

    test('Lost & Found workflow: report, browse, claim', () async {
      final repo = SupabaseLostFoundRepository();
      final controller = LostFoundController(repository: repo);

      await controller.loadItems(campusId: 'campus-alpha-001');
      expect(controller.items, isNotEmpty);

      final newItem = await controller.submitItem(
        LostFoundItemEntity(
          id: '',
          campusId: 'campus-alpha-001',
          userId: 'user-001',
          itemType: ItemType.lost,
          category: 'Electronics',
          itemName: 'Sony Headphones',
          location: 'Library',
          occurredAt: DateTime.now(),
          description: 'Black WH-1000XM4 with sticker',
          status: ItemStatus.open,
          createdAt: DateTime.now(),
        ),
      );

      expect(newItem, isNotNull);
      expect(newItem?.itemName, equals('Sony Headphones'));

      final claimSuccess = await controller.claimItem('lf-001');
      expect(claimSuccess, isTrue);
      final claimedItem = controller.items.firstWhere((e) => e.id == 'lf-001');
      expect(claimedItem.status, equals(ItemStatus.claimed));
    });

    test('Queue workflow: load queues, view token, join queue', () async {
      final repo = SupabaseQueueRepository();
      final controller = QueueController(repository: repo);

      await controller.loadQueues(
        campusId: 'campus-alpha-001',
        userId: 'mock-user-123',
      );
      expect(controller.queues, isNotEmpty);
      expect(controller.activeToken, isNotNull);
      expect(controller.activeToken?.tokenNumber, equals(27));

      final newToken = await controller.joinQueue(
        queueId: 'q-admissions',
        userId: 'new-user',
        campusId: 'campus-alpha-001',
      );
      expect(newToken, isNotNull);
      expect(newToken?.queueId, equals('q-admissions'));
    });

    test('Notices workflow: load notices and filter by category', () async {
      final repo = SupabaseNoticeRepository();
      final controller = NoticeController(repository: repo);

      await controller.loadNotices(campusId: 'campus-alpha-001');
      expect(controller.notices, isNotEmpty);

      controller.filterCategory('campus-alpha-001', 'Examination');
      await Future.delayed(const Duration(milliseconds: 200));
      expect(
        controller.notices.every((n) => n.category == 'Examination'),
        isTrue,
      );
    });
  });
}
