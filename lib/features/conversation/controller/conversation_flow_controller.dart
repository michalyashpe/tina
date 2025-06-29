import 'package:flutter/foundation.dart';
import '../model/conversation_step.dart';
import '../model/conversation_models.dart';

/// Manages conversation state and flow between steps
class ConversationFlowController {
  final ValueNotifier<ConversationStep> _currentStep = 
      ValueNotifier(ConversationStep.open);
  final ValueNotifier<Conversation?> _conversation = ValueNotifier(null);
  final ValueNotifier<List<TranscriptLine>> _transcript = 
      ValueNotifier(<TranscriptLine>[]);

  // Getters
  ValueListenable<ConversationStep> get currentStep => _currentStep;
  ValueListenable<Conversation?> get conversation => _conversation;
  ValueListenable<List<TranscriptLine>> get transcript => _transcript;

  /// Start a new conversation
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
    _currentStep.value = ConversationStep.open;
  }

  void dispose() {
    _currentStep.dispose();
    _conversation.dispose();
    _transcript.dispose();
  }
} 