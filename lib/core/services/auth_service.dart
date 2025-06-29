import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Authentication service for user management
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock successful authentication
      _currentUser = User(
        id: '1',
        name: 'משתמש דוגמה',
        email: email,
        phoneNumber: '050-1234567',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('שגיאה בהתחברות: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up with user details
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock successful registration
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('שגיאה ברישום: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('שגיאה בהתנתקות: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('שגיאה בעדכון פרופיל: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user session is valid
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      // Simulate checking stored session
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo, assume user is logged in
      if (_currentUser == null) {
        _currentUser = User(
          id: '1',
          name: 'משתמש דוגמה',
          email: 'user@example.com',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          lastLoginAt: DateTime.now(),
        );
      }
      
      notifyListeners();
    } catch (e) {
      _setError('שגיאה בבדיקת סטטוס: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 