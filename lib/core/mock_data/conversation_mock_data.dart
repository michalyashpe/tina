import '../../features/conversation/model/conversation_models.dart';
import '../models/conversation_status.dart' as core;

/// Centralized mock data for conversations and transcripts
class ConversationMockData {
  /// Mock conversations for conversation service
  static List<Conversation> getMockConversations() {
    return [
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
        status: core.ConversationStatus.cancelled,
      ),
    ];
  }

  /// Mock transcript data for summary screen
  static List<Map<String, dynamic>> getMockTranscript() {
    return [
      {
        'sender': 'tina',
        'content': 'שלום! איך אני יכולה לעזור?',
        'time': DateTime.now().subtract(const Duration(minutes: 30))
      },
      {
        'sender': 'user',
        'content': 'אני רוצה לבטל פוליסת ביטוח',
        'time': DateTime.now().subtract(const Duration(minutes: 29))
      },
      {
        'sender': 'tina',
        'content': 'אני מעבירה אותך לנציג',
        'time': DateTime.now().subtract(const Duration(minutes: 28))
      },
      {
        'sender': 'agent',
        'content': 'שלום, איך אני יכול לעזור?',
        'time': DateTime.now().subtract(const Duration(minutes: 27))
      },
    ];
  }

  /// Mock conversation simulation messages for live chat
  static List<ConversationSimulationStep> getMockConversationSimulation() {
    return [
      ConversationSimulationStep(
        delay: const Duration(seconds: 1),
        message: 'שלום! אני טינה, עוזרת הדיגיטלית. איך אוכל לעזור לך היום?',
        sender: MessageSender.tina,
      ),
      ConversationSimulationStep(
        delay: const Duration(seconds: 3),
        message: 'שלום טינה, אני רוצה לבטל פוליסת ביטוח',
        sender: MessageSender.user,
      ),
      ConversationSimulationStep(
        delay: const Duration(seconds: 5),
        message: 'בהחלט אוכל לעזור לך. אני מעבירה אותך לנציג שירות מתמחה',
        sender: MessageSender.tina,
      ),
      ConversationSimulationStep(
        delay: const Duration(seconds: 7),
        message: 'שלום, אני דניאל מצוות שירות הלקוחות. איך אוכל לעזור?',
        sender: MessageSender.agent,
      ),
    ];
  }
}

/// Helper class for conversation simulation steps
class ConversationSimulationStep {
  final Duration delay;
  final String message;
  final MessageSender sender;

  const ConversationSimulationStep({
    required this.delay,
    required this.message,
    required this.sender,
  });
} 