/// Enum for conversation steps
enum ConversationStep {
  /// Opening conversation - setting task and parameters
  open,
  
  /// Live conversation - real-time transcript, status, calls
  live,
  
  /// End conversation - final status, brief feedback
  end,
}

extension ConversationStepExtension on ConversationStep {
  String get displayName {
    switch (this) {
      case ConversationStep.open:
        return 'פתיחת שיחה';
      case ConversationStep.live:
        return 'שיחה חיה';
      case ConversationStep.end:
        return 'סיום שיחה';
    }
  }

  String get description {
    switch (this) {
      case ConversationStep.open:
        return 'הגדרת משימה ופרמטרים ראשוניים';
      case ConversationStep.live:
        return 'תמלול בזמן אמת, מעקב סטטוס וקריאות';
      case ConversationStep.end:
        return 'סטטוס סופי ומשוב על השיחה';
    }
  }
} 