import '../../../core/models/conversation_status.dart';

/// Models for conversation - Conversation, TranscriptLine, etc.

class Conversation {
  final String id;
  final String task;
  final String? additionalInfo;
  final DateTime startTime;
  final DateTime? endTime;
  final ConversationStatus status;

  const Conversation({
    required this.id,
    required this.task,
    this.additionalInfo,
    required this.startTime,
    this.endTime,
    this.status = ConversationStatus.active,
  });

  Conversation copyWith({
    String? id,
    String? task,
    String? additionalInfo,
    DateTime? startTime,
    DateTime? endTime,
    ConversationStatus? status,
  }) {
    return Conversation(
      id: id ?? this.id,
      task: task ?? this.task,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }
}



class TranscriptLine {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageType type;

  const TranscriptLine({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.type = MessageType.text,
  });

  factory TranscriptLine.fromTina(String content) {
    return TranscriptLine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: MessageSender.tina,
      timestamp: DateTime.now(),
    );
  }

  factory TranscriptLine.fromAgent(String content) {
    return TranscriptLine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: MessageSender.agent,
      timestamp: DateTime.now(),
    );
  }

  factory TranscriptLine.fromUser(String content) {
    return TranscriptLine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
  }
}

enum MessageSender {
  tina,
  agent,
  user,
}

enum MessageType {
  text,
  audio,
  status,
  system,
}

extension MessageSenderExtension on MessageSender {
  String get displayName {
    switch (this) {
      case MessageSender.tina:
        return 'טינה';
      case MessageSender.agent:
        return 'נציג שירות';
      case MessageSender.user:
        return 'משתמש';
    }
  }
} 