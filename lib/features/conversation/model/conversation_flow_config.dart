import '../services/conversation_flow_loader.dart';

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
  static List<ConversationStepConfig>? _steps;

  /// Get conversation steps (loads from Dart data if not already loaded)
  static Future<List<ConversationStepConfig>> getSteps() async {
    _steps ??= await ConversationFlowLoader.instance.loadConversationFlow();
    return _steps!;
  }

  /// Reload steps from Dart data
  static Future<List<ConversationStepConfig>> reloadSteps() async {
    _steps = await ConversationFlowLoader.instance.reloadConfiguration();
    return _steps!;
  }

  /// Get step configuration by ID
  static Future<ConversationStepConfig?> getStepById(String id) async {
    final steps = await getSteps();
    return steps.where((step) => step.id == id).firstOrNull;
  }

  /// Get the first step (welcome)
  static Future<ConversationStepConfig> getFirstStep() async {
    final steps = await getSteps();
    return steps.first;
  }

  /// Get step index by ID
  static Future<int> getStepIndex(String id) async {
    final steps = await getSteps();
    return steps.indexWhere((step) => step.id == id);
  }

  /// Get next step configuration
  static Future<ConversationStepConfig?> getNextStep(String currentId, String answer) async {
    final currentStep = await getStepById(currentId);
    if (currentStep == null) return null;

    final nextId = currentStep.getNextStepId(answer);
    if (nextId == null) return null;

    return getStepById(nextId);
  }

  /// Check if step is the last step
  static Future<bool> isLastStep(String id) async {
    final steps = await getSteps();
    return id == 'complete' || steps.indexWhere((step) => step.id == id) == steps.length - 1;
  }
} 