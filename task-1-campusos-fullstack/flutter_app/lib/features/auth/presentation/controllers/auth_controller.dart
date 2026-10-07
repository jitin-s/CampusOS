import 'package:flutter/foundation.dart';

import 'package:campusos/domain/entities/user_entity.dart';
import 'package:campusos/domain/repositories/auth_repository.dart';

/// Presentation state management controller for authentication.
/// UI widgets interact strictly with this controller or Use Cases.
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController({required AuthRepository authRepository})
    : _authRepository = authRepository { // ignore: prefer_initializing_formals
    _currentUser = _authRepository.currentUser;
    _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signInWithPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authRepository.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}
