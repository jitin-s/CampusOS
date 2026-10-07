import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/network/supabase_client_manager.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/supabase_auth_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase if credentials are provided, or fall back to offline/mock
  await SupabaseClientManager.instance.initialize();

  // Establish dependency injection boundaries
  final AuthRepository authRepository = SupabaseAuthRepository();
  final AuthController authController = AuthController(
    authRepository: authRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: authController),
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
