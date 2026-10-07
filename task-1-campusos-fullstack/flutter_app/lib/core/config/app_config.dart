/// Application environment and configuration values.
/// Credentials are read safely via compile-time environment definitions (--dart-define)
/// or default to mock/offline fallback values so no secrets are committed.
class AppConfig {
  AppConfig._();

  /// Target campus context for multi-tenant isolation
  static const String defaultCampusId = String.fromEnvironment(
    'CAMPUS_ID',
    defaultValue: 'campus-alpha-001',
  );

  /// Supabase Project URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase Public Anonymous Key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Whether Supabase configuration is provided
  static bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Environment Name
  static const String appName = 'CampusOS';
  static const String appVersion = '1.0.0';
}
