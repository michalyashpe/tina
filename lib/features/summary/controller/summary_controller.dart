import 'package:flutter/foundation.dart';
import '../../../core/services/conversation_service.dart';
import '../../../core/utils/time_utils.dart';

/// Controller for summary screen
class SummaryController extends ChangeNotifier {
  final ConversationService _conversationService = ConversationService();
  
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<dynamic> _conversation = ValueNotifier(null);
  final ValueNotifier<List> _transcript = ValueNotifier([]);

  ValueListenable<bool> get isLoading => _isLoading;
  ValueListenable<dynamic> get conversation => _conversation;
  ValueListenable<List> get transcript => _transcript;

  /// Load conversation summary
  Future<void> loadSummary(String conversationId) async {
    _isLoading.value = true;
    
    try {
      await _conversationService.loadConversations();
      final conversation = _conversationService.getConversationById(conversationId);
      
      _conversation.value = conversation;
      
      // Mock transcript data
      _transcript.value = [
        {'sender': 'tina', 'content': 'שלום! איך אני יכולה לעזור?', 'time': DateTime.now().subtract(const Duration(minutes: 30))},
        {'sender': 'user', 'content': 'אני רוצה לבטל פוליסת ביטוח', 'time': DateTime.now().subtract(const Duration(minutes: 29))},
        {'sender': 'tina', 'content': 'אני מעבירה אותך לנציג', 'time': DateTime.now().subtract(const Duration(minutes: 28))},
        {'sender': 'agent', 'content': 'שלום, איך אני יכול לעזור?', 'time': DateTime.now().subtract(const Duration(minutes: 27))},
      ];
      
    } catch (e) {
      debugPrint('Error loading summary: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  String formatDateTime(DateTime dateTime) {
    return TimeUtils.formatDateTime(dateTime);
  }

  String formatDuration(Duration duration) {
    return TimeUtils.formatDuration(duration);
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _conversation.dispose();
    _transcript.dispose();
    super.dispose();
  }
} 