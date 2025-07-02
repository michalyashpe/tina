import 'package:flutter/foundation.dart';
import '../model/conversation_step.dart';
import '../model/conversation_models.dart';
import '../../../core/scripts/conversation_scripts.dart';

/// Manages conversation state and flow between steps
class ConversationFlowController {
  final ValueNotifier<ConversationStep> _currentStep = 
      ValueNotifier(ConversationStep.open);
  final ValueNotifier<Conversation?> _conversation = ValueNotifier(null);
  final ValueNotifier<List<TranscriptLine>> _transcript = 
      ValueNotifier(<TranscriptLine>[]);
  final ValueNotifier<SetupStep> _setupStep = ValueNotifier(SetupStep.welcome);
  final ValueNotifier<List<TranscriptLine>> _setupMessages = 
      ValueNotifier(<TranscriptLine>[]);

  // Getters
  ValueListenable<ConversationStep> get currentStep => _currentStep;
  ValueListenable<Conversation?> get conversation => _conversation;
  ValueListenable<List<TranscriptLine>> get transcript => _transcript;
  ValueListenable<SetupStep> get setupStep => _setupStep;
  ValueListenable<List<TranscriptLine>> get setupMessages => _setupMessages;

  /// Initialize setup with welcome message
  void initializeSetup() {
    _setupMessages.value = [
      TranscriptLine.fromTina(ConversationScripts.setupWelcome),
    ];
    _setupStep.value = SetupStep.task;
  }

  /// Handle user response during setup
  void handleSetupResponse(String response) {
    // Add user message
    _addSetupMessage(TranscriptLine.fromUser(response));

    switch (_setupStep.value) {
      case SetupStep.task:
        _handleTaskResponse(response);
        break;
      case SetupStep.contact:
        _handleContactResponse(response);
        break;
      case SetupStep.details:
        _handleDetailsResponse(response);
        break;
      default:
        break;
    }
  }

  void _handleTaskResponse(String task) {
    _conversation.value = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      task: task,
      startTime: DateTime.now(),
    );

    _addSetupMessage(TranscriptLine.fromTina(ConversationScripts.setupContact));
    _setupStep.value = SetupStep.contact;
  }

  void _handleContactResponse(String contact) {
    _conversation.value = _conversation.value?.copyWith(contactPhone: contact);
    
    _addSetupMessage(TranscriptLine.fromTina(ConversationScripts.setupDetails));
    _setupStep.value = SetupStep.details;
  }

  void _handleDetailsResponse(String details) {
    String? cleanedDetails;
    final skipKeywords = ConversationScripts.getSkipKeywords();
    
    if (details.isNotEmpty && 
        !skipKeywords.any((keyword) => details.toLowerCase().contains(keyword))) {
      cleanedDetails = details;
    }

    _conversation.value = _conversation.value?.copyWith(
      identifyingDetails: cleanedDetails
    );
    
    String responseMessage = ConversationScripts.getSetupCompletionMessage(
      hasDetails: cleanedDetails != null
    );
    
    _addSetupMessage(TranscriptLine.fromTina(responseMessage));
    _setupStep.value = SetupStep.complete;
    
    // Transition to live step after a brief delay
    Future.delayed(const Duration(seconds: 2), () {
      _currentStep.value = ConversationStep.live;
    });
  }

  void _addSetupMessage(TranscriptLine message) {
    final currentMessages = List<TranscriptLine>.from(_setupMessages.value);
    currentMessages.add(message);
    _setupMessages.value = currentMessages;
  }

  /// Start a new conversation (legacy method for backward compatibility)
  void startConversation({required String task, String? additionalInfo}) {
    _conversation.value = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      task: task,
      additionalInfo: additionalInfo,
      startTime: DateTime.now(),
    );
    _currentStep.value = ConversationStep.live;
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
    _setupStep.value = SetupStep.welcome;
    _currentStep.value = ConversationStep.open;
  }

  void dispose() {
    _currentStep.dispose();
    _conversation.dispose();
    _transcript.dispose();
    _setupStep.dispose();
    _setupMessages.dispose();
  }
} 