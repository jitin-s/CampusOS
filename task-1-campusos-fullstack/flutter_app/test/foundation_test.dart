import 'package:flutter_test/flutter_test.dart';
import 'package:campusos/core/config/app_config.dart';
import 'package:campusos/data/repositories/supabase_auth_repository.dart';
import 'package:campusos/data/repositories/supabase_issue_repository.dart';
import 'package:campusos/data/repositories/supabase_lost_found_repository.dart';
import 'package:campusos/data/repositories/supabase_notice_repository.dart';
import 'package:campusos/data/repositories/supabase_queue_repository.dart';
import 'package:campusos/data/services/campus_intelligence_client.dart';
import 'package:campusos/domain/entities/issue_entity.dart';
import 'package:campusos/domain/entities/lost_found_entity.dart';
import 'package:campusos/domain/entities/notice_entity.dart';
import 'package:campusos/domain/entities/user_entity.dart';
import 'package:campusos/data/repositories/mock_campus_room_repository.dart';
import 'package:campusos/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:campusos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:campusos/features/campus_fix/presentation/controllers/campus_fix_controller.dart';
import 'package:campusos/features/lost_found/presentation/controllers/lost_found_controller.dart';
import 'package:campusos/features/notices/presentation/controllers/notice_controller.dart';
import 'package:campusos/features/queue/presentation/controllers/queue_controller.dart';
import 'package:campusos/features/rooms/presentation/controllers/campus_room_controller.dart';

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

  group('Admin Workflows & Intelligence Tests (Phase 2)', () {
    test(
      'Task-2 Intelligence Client produces explainable matches and priorities',
      () {
        final client = CampusIntelligenceClient();

        final now = DateTime.now();
        final lost = LostFoundItemEntity(
          id: 'l1',
          campusId: 'campus-alpha-001',
          userId: 'u1',
          itemType: ItemType.lost,
          category: 'Electronics',
          itemName: 'Casio Scientific Calculator FX-991EX',
          brand: 'Casio',
          color: 'Black',
          location: 'Central Library',
          occurredAt: now,
          description: 'Lost in library',
          status: ItemStatus.open,
          createdAt: now,
        );

        final found = LostFoundItemEntity(
          id: 'f1',
          campusId: 'campus-alpha-001',
          userId: 'u2',
          itemType: ItemType.found,
          category: 'Electronics',
          itemName: 'Casio Calculator',
          brand: 'Casio',
          color: 'Black',
          location: 'Central Library Floor 2',
          occurredAt: now,
          description: 'Found on desk',
          status: ItemStatus.open,
          createdAt: now,
        );

        final match = client.calculateMatch(lost, found);
        expect(match.score, greaterThanOrEqualTo(85));
        expect(match.isStrongMatch, isTrue);
        expect(match.matchedAttributes.length, greaterThanOrEqualTo(4));

        // Automated Classification
        final classification = client.classifyIssue(
          'Broken projector',
          'Lamp flickering red',
          'Room 204',
        );
        expect(classification.category, equals('Equipment'));
        expect(classification.department, equals('IT Support'));

        // Explainable Priority
        final priority = client.calculatePriority(
          'Equipment',
          IssueSeverity.critical,
          'Library Main Hall',
        );
        expect(priority.level, equals('CRITICAL'));
        expect(priority.score, greaterThanOrEqualTo(70));
      },
    );

    test(
      'Admin Dashboard workflow: load telemetry, dispatch, and approve claim',
      () async {
        final issueRepo = SupabaseIssueRepository();
        final lfRepo = SupabaseLostFoundRepository();
        final queueRepo = SupabaseQueueRepository();
        final noticeRepo = SupabaseNoticeRepository();
        final intelligence = CampusIntelligenceClient();

        final adminController = AdminDashboardController(
          issueRepository: issueRepo,
          lostFoundRepository: lfRepo,
          queueRepository: queueRepo,
          noticeRepository: noticeRepo,
          intelligenceService: intelligence,
        );

        await adminController.loadDashboardData('campus-alpha-001');

        expect(adminController.issues, isNotEmpty);
        expect(adminController.analytics, isNotNull);
        expect(
          adminController.analytics?.campusReliabilityScore,
          greaterThan(50),
        );
        expect(adminController.analytics?.problemClusters, isNotEmpty);

        // Dispatch & Assign Issue
        await adminController.assignIssue(
          issueId: 'issue-1042',
          departmentId: 'IT Infrastructure',
          assignedTo: 'Vikram Engineer',
        );
        final assigned = adminController.issues.firstWhere(
          (i) => i.id == 'issue-1042',
        );
        expect(assigned.assignedTo, equals('Vikram Engineer'));
        expect(assigned.status, equals(IssueStatus.assigned));

        // Update Issue Status to In Progress
        await adminController.updateIssueStatus(
          issueId: 'issue-1042',
          newStatus: IssueStatus.inProgress,
        );
        final inProg = adminController.issues.firstWhere(
          (i) => i.id == 'issue-1042',
        );
        expect(inProg.status, equals(IssueStatus.inProgress));

        // Approve Claim
        await adminController.approveClaim('lf-002');
        final approvedItem = adminController.lostFoundItems.firstWhere(
          (i) => i.id == 'lf-002',
        );
        expect(approvedItem.status, equals(ItemStatus.recovered));

        // Broadcast Notice
        await adminController.publishNotice(
          NoticeEntity(
            id: '',
            campusId: 'campus-alpha-001',
            authorId: 'admin-001',
            title: 'Campus Wi-Fi Maintenance',
            category: 'General',
            body: 'Scheduled maintenance at midnight.',
            priority: 'Normal',
            publishedAt: DateTime.now(),
            isActive: true,
          ),
        );
        expect(
          adminController.notices.any(
            (n) => n.title == 'Campus Wi-Fi Maintenance',
          ),
          isTrue,
        );
      },
    );
  });

  group('Empty Rooms Vacancy Feature Tests', () {
    test(
      'CampusRoomController loads rooms and filters empty rooms correctly',
      () async {
        final repo = MockCampusRoomRepository();
        final controller = CampusRoomController(repository: repo);

        await controller.loadRooms('campus-alpha-001');

        expect(controller.rooms, isNotEmpty);
        expect(controller.buildings, contains('Academic Block A'));
        expect(controller.buildings, contains('Academic Block B'));
        expect(controller.buildings, contains('Central Library'));

        // Check room structure
        final room204 = controller.rooms.firstWhere(
          (r) => r.roomNumber == '204',
        );
        expect(room204.building, equals('Academic Block B'));
        expect(room204.capacity, equals(80));
        expect(room204.isCurrentlyEmpty, isTrue);

        // Filter by building
        await controller.filterBuilding('campus-alpha-001', 'Academic Block A');
        expect(
          controller.rooms.every((r) => r.building == 'Academic Block A'),
          isTrue,
        );

        // Filter by empty only
        await controller.toggleOnlyEmpty('campus-alpha-001', true);
        expect(
          controller.rooms.every((r) => r.isCurrentlyEmpty),
          isTrue,
        );

        // Timetable schedule checks
        expect(room204.todaySchedule, isNotEmpty);
        expect(room204.todaySchedule.any((slot) => slot.isOccupied), isTrue);
        expect(room204.todaySchedule.any((slot) => !slot.isOccupied), isTrue);
      },
    );
  });
}
