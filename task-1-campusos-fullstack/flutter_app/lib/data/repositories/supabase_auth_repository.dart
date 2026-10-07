import 'dart:async';


import '../../core/network/supabase_client_manager.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Supabase implementation of AuthRepository with resilient mock fallback.
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClientManager _clientManager;
  final StreamController<UserEntity?> _authController =
      StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  SupabaseAuthRepository({SupabaseClientManager? clientManager})
    : _clientManager = clientManager ?? SupabaseClientManager.instance {
    _initListener();
  }

  void _initListener() {
    final client = _clientManager.client;
    if (client != null) {
      client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          final user = session.user;
          _currentUser = UserModel(
            id: user.id,
            campusId:
                user.userMetadata?['campus_id'] as String? ??
                'campus-alpha-001',
            email: user.email ?? '',
            name: user.userMetadata?['name'] as String? ?? 'Campus User',
            role: UserRole.fromString(user.userMetadata?['role'] as String?),
          );
        } else {
          _currentUser = null;
        }
        _authController.add(_currentUser);
      });
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _authController.stream;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<UserEntity> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final client = _clientManager.client;
    if (client != null) {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw Exception('User authentication failed: No user returned');
      }
      _currentUser = UserModel(
        id: user.id,
        campusId:
            user.userMetadata?['campus_id'] as String? ?? 'campus-alpha-001',
        email: user.email ?? email,
        name: user.userMetadata?['name'] as String? ?? 'Campus User',
        role: UserRole.fromString(user.userMetadata?['role'] as String?),
      );
      _authController.add(_currentUser);
      return _currentUser!;
    } else {
      // Mock / Offline Auth for testing or when credentials are not supplied
      await Future.delayed(const Duration(milliseconds: 300));
      final role = email.contains('admin') ? UserRole.admin : UserRole.student;
      _currentUser = UserModel(
        id: 'mock-user-123',
        campusId: 'campus-alpha-001',
        email: email,
        name: email.contains('admin') ? 'Campus Admin' : 'John Student',
        role: role,
      );
      _authController.add(_currentUser);
      return _currentUser!;
    }
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String name,
    required String campusId,
    UserRole role = UserRole.student,
  }) async {
    final client = _clientManager.client;
    if (client != null) {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'campus_id': campusId, 'role': role.name},
      );
      final user = response.user;
      if (user == null) {
        throw Exception('User sign-up failed');
      }
      _currentUser = UserModel(
        id: user.id,
        campusId: campusId,
        email: user.email ?? email,
        name: name,
        role: role,
      );
      _authController.add(_currentUser);
      return _currentUser!;
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      _currentUser = UserModel(
        id: 'mock-new-user',
        campusId: campusId,
        email: email,
        name: name,
        role: role,
      );
      _authController.add(_currentUser);
      return _currentUser!;
    }
  }

  @override
  Future<void> signOut() async {
    final client = _clientManager.client;
    if (client != null) {
      await client.auth.signOut();
    }
    _currentUser = null;
    _authController.add(null);
  }
}
