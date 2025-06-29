import 'package:flutter/foundation.dart';
import '../../../core/services/conversation_service.dart';
import '../../conversation/model/conversation_models.dart';

/// Controller for home screen data and operations
class HomeController extends ChangeNotifier {
  final ConversationService _conversationService = ConversationService();
  
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<Conversation?> _activeConversation = ValueNotifier(null);
  final ValueNotifier<List<Conversation>> _unfinishedConversations = ValueNotifier([]);
  final ValueNotifier<List<Conversation>> _completedConversations = ValueNotifier([]);

  // Getters
  ValueListenable<bool> get isLoading => _isLoading;
  ValueListenable<Conversation?> get activeConversation => _activeConversation;
  ValueListenable<List<Conversation>> get unfinishedConversations => _unfinishedConversations;
  ValueListenable<List<Conversation>> get completedConversations => _completedConversations;

  /// Load all data for home screen
  Future<void> loadData() async {
    _isLoading.value = true;
    
    try {
      await _conversationService.loadConversations();
      _updateConversationLists();
    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh conversation data
  Future<void> refresh() async {
    await loadData();
  }

  /// Delete conversation
  Future<bool> deleteConversation(String id) async {
    final success = await _conversationService.deleteConversation(id);
    if (success) {
      _updateConversationLists();
    }
    return success;
  }

  /// Get conversation statistics
  Map<String, int> getStats() {
    return _conversationService.getConversationStats();
  }

  void _updateConversationLists() {
    final conversations = _conversationService.conversations;
    final activeConversations = _conversationService.activeConversations;
    final unfinishedConversations = _conversationService.unfinishedConversations;
    final completedConversations = _conversationService.completedConversations;

    _activeConversation.value = activeConversations.isNotEmpty ? activeConversations.first : null;
    _unfinishedConversations.value = unfinishedConversations;
    _completedConversations.value = completedConversations;
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _activeConversation.dispose();
    _unfinishedConversations.dispose();
    _completedConversations.dispose();
    super.dispose();
  }
} 