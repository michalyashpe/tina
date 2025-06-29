import 'package:flutter/foundation.dart';
import '../../../core/services/auth_service.dart';

/// Controller for settings screen
class SettingsController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  final ValueNotifier<bool> _pushNotifications = ValueNotifier(true);
  final ValueNotifier<bool> _emailNotifications = ValueNotifier(false);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  ValueListenable<bool> get pushNotifications => _pushNotifications;
  ValueListenable<bool> get emailNotifications => _emailNotifications;
  ValueListenable<bool> get isLoading => _isLoading;

  /// Load settings from storage
  Future<void> loadSettings() async {
    _isLoading.value = true;
    
    try {
      // Mock loading settings from storage
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app, load from SharedPreferences or similar
      _pushNotifications.value = true;
      _emailNotifications.value = false;
      
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Set push notifications preference
  Future<void> setPushNotifications(bool enabled) async {
    _pushNotifications.value = enabled;
    await _saveSettings();
  }

  /// Set email notifications preference
  Future<void> setEmailNotifications(bool enabled) async {
    _emailNotifications.value = enabled;
    await _saveSettings();
  }

  /// Sign out user
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      // Mock saving to storage
      await Future.delayed(const Duration(milliseconds: 200));
      
      // In a real app, save to SharedPreferences or similar
      debugPrint('Settings saved: push=${_pushNotifications.value}, email=${_emailNotifications.value}');
      
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  @override
  void dispose() {
    _pushNotifications.dispose();
    _emailNotifications.dispose();
    _isLoading.dispose();
    super.dispose();
  }
} 