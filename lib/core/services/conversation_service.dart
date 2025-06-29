import 'package:flutter/foundation.dart';
import '../../features/conversation/model/conversation_models.dart';
import '../models/conversation_status.dart' as core;

/// Service for managing conversation data and operations
class ConversationService extends ChangeNotifier {
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  final List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  List<Conversation> get activeConversations => 
      _conversations.where((c) => c.status == core.ConversationStatus.active).toList();
  List<Conversation> get completedConversations => 
      _conversations.where((c) => c.status == core.ConversationStatus.completed).toList();
  List<Conversation> get unfinishedConversations => 
      _conversations.where((c) => c.status != core.ConversationStatus.completed).toList();
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load conversations from storage/API
  Future<void> loadConversations() async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock conversations data
      _conversations.clear();
      _conversations.addAll([
                 Conversation(
           id: '1',
           task: 'בטל פוליסת ביטוח רכב',
           startTime: DateTime.now().subtract(const Duration(hours: 2)),
           endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
           status: core.ConversationStatus.completed,
         ),
         Conversation(
           id: '2',
           task: 'עדכון פרטים אישיים',
           startTime: DateTime.now().subtract(const Duration(days: 1)),
           endTime: DateTime.now().subtract(const Duration(days: 1, hours: -1)),
           status: core.ConversationStatus.completed,
         ),
         Conversation(
           id: '3',
           task: 'פתיחת תיק תביעה',
           startTime: DateTime.now().subtract(const Duration(minutes: 30)),
           status: core.ConversationStatus.active,
         ),
      ]);
      
      notifyListeners();
    } catch (e) {
      _setError('שגיאה בטעינת שיחות: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Save conversation
  Future<bool> saveConversation(Conversation conversation) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final existingIndex = _conversations.indexWhere((c) => c.id == conversation.id);
      if (existingIndex != -1) {
        _conversations[existingIndex] = conversation;
      } else {
        _conversations.add(conversation);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('שגיאה בשמירת שיחה: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get conversation by ID
  Conversation? getConversationById(String id) {
    try {
      return _conversations.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Delete conversation
  Future<bool> deleteConversation(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _conversations.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('שגיאה במחיקת שיחה: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update conversation status
  Future<bool> updateConversationStatus({
    required String id,
    required core.ConversationStatus status,
  }) async {
    final conversation = getConversationById(id);
    if (conversation == null) return false;

    final updatedConversation = conversation.copyWith(
      status: status,
      endTime: status == core.ConversationStatus.completed ? DateTime.now() : null,
    );

    return await saveConversation(updatedConversation);
  }

  /// Get conversation statistics
  Map<String, int> getConversationStats() {
    return {
      'total': _conversations.length,
      'active': activeConversations.length,
      'completed': completedConversations.length,
             'cancelled': _conversations.where((c) => c.status == core.ConversationStatus.cancelled).length,
       'error': _conversations.where((c) => c.status == core.ConversationStatus.error).length,
    };
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