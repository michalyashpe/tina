import 'package:flutter/foundation.dart';
import '../model/conversation_step.dart';
import '../model/conversation_models.dart';
import '../model/conversation_flow_config.dart';

/// Manages conversation state and flow between steps using configuration
class ConversationFlowController {
  final ValueNotifier<ConversationStep> _currentStep = 
      ValueNotifier(ConversationStep.open);
  final ValueNotifier<Conversation?> _conversation = ValueNotifier(null);
  final ValueNotifier<List<TranscriptLine>> _transcript = 
      ValueNotifier(<TranscriptLine>[]);
  final ValueNotifier<String> _currentStepId = ValueNotifier('welcome');
  final ValueNotifier<List<TranscriptLine>> _setupMessages = 
      ValueNotifier(<TranscriptLine>[]);
  final ValueNotifier<bool> _isTyping = ValueNotifier(false);

  // Getters
  ValueListenable<ConversationStep> get currentStep => _currentStep;
  ValueListenable<Conversation?> get conversation => _conversation;
  ValueListenable<List<TranscriptLine>> get transcript => _transcript;
  ValueListenable<String> get currentStepId => _currentStepId;
  ValueListenable<List<TranscriptLine>> get setupMessages => _setupMessages;
  ValueListenable<bool> get isTyping => _isTyping;

  /// Show typing indicator
  void showTypingIndicator() {
    print('🟢 Setting typing to true');
    _isTyping.value = true;
  }

  /// Hide typing indicator
  void hideTypingIndicator() {
    print('🔴 Setting typing to false');
    _isTyping.value = false;
  }

  /// Initialize setup with welcome message
  void initializeSetup() async {
    final firstStep = await ConversationFlowConfig.getFirstStep();
    _currentStepId.value = firstStep.id;
    
    // Add a small delay to ensure UI is ready, then show typing indicator
    Future.delayed(const Duration(milliseconds: 500), () {
      _addSetupMessageWithTyping(firstStep.questionText);
    });
  }

  /// Get current step configuration
  Future<ConversationStepConfig?> getCurrentStepConfig() async {
    return await ConversationFlowConfig.getStepById(_currentStepId.value);
  }

  /// Get hint text for current step
  Future<String> getHintText() async {
    final stepConfig = await getCurrentStepConfig();
    return stepConfig?.hintText ?? 'הקלד הודעה...';
  }

  /// Check if current step should show skip button
  Future<bool> shouldShowSkipButton() async {
    final stepConfig = await getCurrentStepConfig();
    return stepConfig?.isOptional ?? false;
  }

  /// Check if setup is complete
  bool get isSetupComplete => _currentStepId.value == 'complete';

  /// Handle user response during setup
  void handleSetupResponse(String response) async {
    final stepConfig = await getCurrentStepConfig();
    if (stepConfig == null) return;

    // Add user message
    _addSetupMessage(TranscriptLine.fromUser(response));

    // Validate response
    final validationError = stepConfig.validateAnswer(response);
    if (validationError != null) {
      _addSetupMessageWithTyping(validationError);
      return;
    }

    // Update conversation data
    _updateConversationField(stepConfig.targetField, response, stepConfig);

    // Get next step
    final nextStepId = stepConfig.getNextStepId(response);
    if (nextStepId == null || nextStepId == 'complete') {
      _completeSetup(stepConfig, response);
      return;
    }

    // Move to next step
    _moveToNextStep(nextStepId, stepConfig, response);
  }

  /// Update conversation field based on step configuration
  void _updateConversationField(String fieldName, String value, ConversationStepConfig stepConfig) {
    final currentConversation = _conversation.value;
    
    // Clean the value if it should be skipped
    String? cleanedValue;
    if (!stepConfig.shouldSkip(value)) {
      cleanedValue = value;
    }

    switch (fieldName) {
      case 'task':
        _conversation.value = Conversation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          task: cleanedValue ?? '',
          startTime: DateTime.now(),
        );
        break;
      case 'contactPhone':
        _conversation.value = currentConversation?.copyWith(
          contactPhone: cleanedValue
        );
        break;
      case 'identifyingDetails':
        _conversation.value = currentConversation?.copyWith(
          identifyingDetails: cleanedValue
        );
        break;
    }
  }

  /// Move to next step
  void _moveToNextStep(String nextStepId, ConversationStepConfig currentStep, String response) async {
    final nextStep = await ConversationFlowConfig.getStepById(nextStepId);
    if (nextStep == null) return;

    _currentStepId.value = nextStepId;
    _addSetupMessageWithTyping(nextStep.questionText);
  }

  /// Complete setup phase
  void _completeSetup(ConversationStepConfig stepConfig, String response) {
    final hasAnswer = !stepConfig.shouldSkip(response);
    final completionMessage = stepConfig.getCompletionMessage(hasAnswer);
    
    if (completionMessage != null) {
      _addSetupMessageWithTyping(completionMessage);
    }
    
    _currentStepId.value = 'complete';
    
    // Transition to live step after a brief delay
    Future.delayed(const Duration(seconds: 2), () {
      _currentStep.value = ConversationStep.live;
    });
  }

  /// Add a setup message
  void _addSetupMessage(TranscriptLine message) {
    final currentMessages = List<TranscriptLine>.from(_setupMessages.value);
    currentMessages.add(message);
    _setupMessages.value = currentMessages;
  }

  /// Add a setup message from Tina with typing indicator
  void _addSetupMessageWithTyping(String message) {
    print('🔄 Showing typing indicator');
    showTypingIndicator();
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      print('✅ Hiding typing indicator and showing message');
      hideTypingIndicator();
      _addSetupMessage(TranscriptLine.fromTina(message));
    });
  }

  /// Add a line to the transcript
  void addTranscriptLine(TranscriptLine line) {
    final currentTranscript = List<TranscriptLine>.from(_transcript.value);
    currentTranscript.add(line);
    _transcript.value = currentTranscript;
  }

  /// End the conversation
  void endConversation() {
    if (_conversation.value != null) {
      _conversation.value = _conversation.value!.copyWith(
        endTime: DateTime.now(),
      );
    }
    _currentStep.value = ConversationStep.end;
  }

  /// Start new conversation (reset)
  void resetConversation() {
    _conversation.value = null;
    _transcript.value = <TranscriptLine>[];
    _setupMessages.value = <TranscriptLine>[];
    _currentStepId.value = 'welcome';
    _currentStep.value = ConversationStep.open;
  }

  void dispose() {
    _currentStep.dispose();
    _conversation.dispose();
    _transcript.dispose();
    _currentStepId.dispose();
    _setupMessages.dispose();
    _isTyping.dispose();
  }
} 