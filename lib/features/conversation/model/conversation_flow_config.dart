import 'conversation_models.dart';

/// Configuration for a single conversation step
class ConversationStepConfig {
  final String id;
  final String questionText;
  final String? hintText;
  final String targetField;
  final bool isOptional;
  final List<String> skipKeywords;
  final String? Function(String answer)? validator;
  final String Function(bool hasAnswer)? completionMessage;
  final String? nextStepId;
  final String? Function(String answer)? nextStepResolver;

  ConversationStepConfig({
    required this.id,
    required this.questionText,
    this.hintText,
    required this.targetField,
    this.isOptional = false,
    this.skipKeywords = const [],
    this.validator,
    this.completionMessage,
    this.nextStepId,
    this.nextStepResolver,
  });

  /// Check if the answer should be skipped based on keywords
  bool shouldSkip(String answer) {
    if (!isOptional) return false;
    return skipKeywords.any((keyword) => 
      answer.toLowerCase().contains(keyword.toLowerCase()));
  }

  /// Get the next step ID based on the answer
  String? getNextStepId(String answer) {
    return nextStepResolver?.call(answer) ?? nextStepId;
  }

  /// Validate the answer
  String? validateAnswer(String answer) {
    return validator?.call(answer);
  }

  /// Get completion message based on whether answer was provided
  String? getCompletionMessage(bool hasAnswer) {
    return completionMessage?.call(hasAnswer);
  }
}

/// Service class that holds the conversation flow configuration
class ConversationFlowConfig {
  static final List<ConversationStepConfig> steps = [
    ConversationStepConfig(
      id: 'welcome',
      questionText: "היי! אני פה לעזור לך עם שיחה.\nמה המשימה שתרצי שאבצע עבורך היום?",
      hintText: 'תיאור המשימה...',
      targetField: 'task',
      nextStepId: 'contact',
    ),
    ConversationStepConfig(
      id: 'contact',
      questionText: "סבבה. עם מי את רוצה שאדבר?",
      hintText: 'מספר טלפון או שם איש קשר...',
      targetField: 'contactPhone',
      nextStepId: 'details',
    ),
    ConversationStepConfig(
      id: 'details',
      questionText: "יש פרטים שיכולים לעזור לי בשיחה?\n"
          "למשל ת״ז, מספר לקוח או פוליסה?\n\n"
          "(אפשר לכתוב 'דלג' אם אין)",
      hintText: 'פרטים מזהים (אופציונלי)...',
      targetField: 'identifyingDetails',
      isOptional: true,
      skipKeywords: const ['דלג', 'אין', 'לא'],
      nextStepId: 'complete',
      completionMessage: (hasAnswer) => hasAnswer
          ? "מעולה! הפרטים יעזרו לי בשיחה.\n\n"
            "אני מתחילה את השיחה עכשיו..."
          : "בסדר, נמשיך בלי פרטים נוספים.\n\n"
            "אני מתחילה את השיחה עכשיו...",
    ),
  ];

  /// Get step configuration by ID
  static ConversationStepConfig? getStepById(String id) {
    return steps.where((step) => step.id == id).firstOrNull;
  }

  /// Get the first step (welcome)
  static ConversationStepConfig get firstStep => steps.first;

  /// Get step index by ID
  static int getStepIndex(String id) {
    return steps.indexWhere((step) => step.id == id);
  }

  /// Get next step configuration
  static ConversationStepConfig? getNextStep(String currentId, String answer) {
    final currentStep = getStepById(currentId);
    if (currentStep == null) return null;

    final nextId = currentStep.getNextStepId(answer);
    if (nextId == null) return null;

    return getStepById(nextId);
  }

  /// Check if step is the last step
  static bool isLastStep(String id) {
    return id == 'complete' || getStepIndex(id) == steps.length - 1;
  }
} 