import 'package:flutter/foundation.dart';
import '../../../core/services/conversation_service.dart';

/// Controller for history screen
class HistoryController extends ChangeNotifier {
  final ConversationService _conversationService = ConversationService();
  
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<List> _conversations = ValueNotifier([]);

  ValueListenable<bool> get isLoading => _isLoading;
  ValueListenable<List> get conversations => _conversations;

  /// Load conversation history
  Future<void> loadHistory() async {
    _isLoading.value = true;
    
    try {
      await _conversationService.loadConversations();
      _conversations.value = _conversationService.conversations;
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh history data
  Future<void> refresh() async {
    await loadHistory();
  }

  /// Delete conversation
  Future<bool> deleteConversation(String id) async {
    final success = await _conversationService.deleteConversation(id);
    if (success) {
      await loadHistory();
    }
    return success;
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _conversations.dispose();
    super.dispose();
  }
} 