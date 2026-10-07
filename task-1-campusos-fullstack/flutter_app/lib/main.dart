import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/network/supabase_client_manager.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/supabase_auth_repository.dart';
import 'data/repositories/supabase_issue_repository.dart';
import 'data/repositories/supabase_lost_found_repository.dart';
import 'data/repositories/supabase_notice_repository.dart';
import 'data/repositories/supabase_queue_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/issue_repository.dart';
import 'domain/repositories/lost_found_repository.dart';
import 'domain/repositories/notice_repository.dart';
import 'domain/repositories/queue_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/campus_fix/presentation/controllers/campus_fix_controller.dart';
import 'features/lost_found/presentation/controllers/lost_found_controller.dart';
import 'features/notices/presentation/controllers/notice_controller.dart';
import 'features/queue/presentation/controllers/queue_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase if credentials are provided, or fall back to offline/mock
  await SupabaseClientManager.instance.initialize();

  // Establish dependency injection boundaries (Dependency Inversion & SOLID)
  final AuthRepository authRepository = SupabaseAuthRepository();
  final IssueRepository issueRepository = SupabaseIssueRepository();
  final LostFoundRepository lostFoundRepository = SupabaseLostFoundRepository();
  final QueueRepository queueRepository = SupabaseQueueRepository();
  final NoticeRepository noticeRepository = SupabaseNoticeRepository();

  final AuthController authController = AuthController(
    authRepository: authRepository,
  );
  final CampusFixController campusFixController = CampusFixController(
    issueRepository: issueRepository,
  );
  final LostFoundController lostFoundController = LostFoundController(
    repository: lostFoundRepository,
  );
  final QueueController queueController = QueueController(
    repository: queueRepository,
  );
  final NoticeController noticeController = NoticeController(
    repository: noticeRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<CampusFixController>.value(
          value: campusFixController,
        ),
        ChangeNotifierProvider<LostFoundController>.value(
          value: lostFoundController,
        ),
        ChangeNotifierProvider<QueueController>.value(value: queueController),
        ChangeNotifierProvider<NoticeController>.value(value: noticeController),
      ],
      child: CampusOSApp(authController: authController),
    ),
  );
}

class CampusOSApp extends StatelessWidget {
  final AuthController authController;

  const CampusOSApp({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    final router = createRouter(authController);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
