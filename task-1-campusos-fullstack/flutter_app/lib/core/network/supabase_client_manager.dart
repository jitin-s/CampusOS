import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Central client manager for Supabase.
/// Decouples direct instantiation from business logic.
class SupabaseClientManager {
  SupabaseClientManager._();
  static final SupabaseClientManager instance = SupabaseClientManager._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes Supabase if credentials are provided in AppConfig.
  /// Falls back to graceful offline/mock mode if no credentials exist.
  Future<void> initialize() async {
    if (!AppConfig.hasSupabaseCredentials) {
      if (kDebugMode) {
        print(
          '[SupabaseClientManager] Running in offline/mock mode (no credentials provided)',
        );
      }
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey, // ignore: deprecated_member_use
      );
      _isInitialized = true;
      if (kDebugMode) {
        print('[SupabaseClientManager] Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SupabaseClientManager] Supabase initialization failed: $e');
      }
      _isInitialized = false;
    }
  }

  /// Direct client accessor (used exclusively within Data Layer implementations)
  SupabaseClient? get client {
    if (!_isInitialized) return null;
    return Supabase.instance.client;
  }
}
