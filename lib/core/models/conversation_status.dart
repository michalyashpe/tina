import 'package:flutter/material.dart';

/// Conversation status enumeration with display properties
enum ConversationStatus {
  active,
  completed,
  cancelled,
  error,
}

extension ConversationStatusExtension on ConversationStatus {
  String get displayName {
    switch (this) {
      case ConversationStatus.active:
        return 'פעילה';
      case ConversationStatus.completed:
        return 'הושלמה';
      case ConversationStatus.cancelled:
        return 'בוטלה';
      case ConversationStatus.error:
        return 'שגיאה';
    }
  }

  String get description {
    switch (this) {
      case ConversationStatus.active:
        return 'השיחה מתבצעת כעת';
      case ConversationStatus.completed:
        return 'השיחה הושלמה בהצלחה';
      case ConversationStatus.cancelled:
        return 'השיחה בוטלה על ידי המשתמש';
      case ConversationStatus.error:
        return 'אירעה שגיאה במהלך השיחה';
    }
  }

  Color get color {
    switch (this) {
      case ConversationStatus.active:
        return Colors.green;
      case ConversationStatus.completed:
        return Colors.blue;
      case ConversationStatus.cancelled:
        return Colors.orange;
      case ConversationStatus.error:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case ConversationStatus.active:
        return Icons.radio_button_checked;
      case ConversationStatus.completed:
        return Icons.check_circle;
      case ConversationStatus.cancelled:
        return Icons.cancel;
      case ConversationStatus.error:
        return Icons.error;
    }
  }
} 