// Import removed - no longer using SetupStep enum

/// Centralized conversation scripts for consistent messaging
/// 
/// This class organizes all conversation-related text content in one place,
/// making it easy to maintain, update, and localize scripts across the app.
class ConversationScripts {
  
  // =============================================================================
  // SETUP FLOW SCRIPTS
  // =============================================================================
  
  /// Welcome message when starting conversation setup
  // static const String setupWelcome = 
  //     "היי! אני פה לעזור לך עם שיחה.\nמה המשימה שתרצי שאבצע עבורך היום?";
  
  /// Request for contact information after task is provided
  // static const String setupContact = 
  //     "סבבה. עם מי את רוצה שאדבר?";
  
  /// Request for identifying details
  // static const String setupDetails = 
  //     "יש פרטים שיכולים לעזור לי בשיחה?\n"
  //     "למשל ת״ז, מספר לקוח או פוליסה?\n\n"
  //     "(אפשר לכתוב 'דלג' אם אין)";
  
  /// Completion message when details are provided
  static const String setupCompleteWithDetails = 
      "מעולה! הפרטים יעזרו לי בשיחה.\n\n"
      "אני מתחילה את השיחה עכשיו...";
  
  /// Completion message when no details provided
  static const String setupCompleteNoDetails = 
      "בסדר, נמשיך בלי פרטים נוספים.\n\n"
      "אני מתחילה את השיחה עכשיו...";
  
  // =============================================================================
  // LIVE CONVERSATION SCRIPTS
  // =============================================================================
  
  /// Active conversation status message
  static const String liveStatusActive = "שיחה פעילה";
  
  /// End conversation button text
  static const String liveEndButton = "סיים שיחה";
  
  // =============================================================================
  // END CONVERSATION SCRIPTS  
  // =============================================================================
  
  /// Main completion message
  static const String endConversationComplete = "השיחה הסתיימה";
  
  /// Feedback section title
  static const String endFeedbackTitle = "משוב נוסף (אופציונלי)";
  
  /// Feedback input placeholder
  static const String endFeedbackPlaceholder = "איך נוכל לשפר את השירות?";
  
  /// Submit feedback button
  static const String endSubmitFeedback = "שלח משוב";
  
  /// New conversation button
  static const String endNewConversation = "התחל שיחה חדשה";
  
  /// Feedback success message
  static const String endFeedbackSuccess = "תודה על המשוב!";
  
  // =============================================================================
  // UI HINTS AND PLACEHOLDERS
  // =============================================================================
  
  // getSetupHint method removed - now handled by configuration-driven approach
  
  /// Skip step button text
  static const String skipStep = "דלג על השלב";
  
  // =============================================================================
  // CONVERSATION LABELS AND TITLES
  // =============================================================================
  
  /// Summary screen labels
  static const String summaryTitle = "סיכום שיחה";
  static const String summaryTask = "משימה:";
  static const String summaryStartTime = "התחלה:";
  static const String summaryEndTime = "סיום:";
  static const String summaryDuration = "משך:";
  static const String summaryStatus = "סטטוס:";
  static const String summaryTranscript = "תמלול השיחה";
  
  /// Common conversation labels
  static const String taskLabel = "משימה:";
  static const String durationLabel = "משך השיחה:";
  static const String startTimeLabel = "זמן התחלה:";
  
  /// Rating section
  static const String ratingQuestion = "איך היית מדרג את השיחה?";
  
  // =============================================================================
  // ERROR AND STATUS MESSAGES
  // =============================================================================
  
  /// No transcript available message
  static const String noTranscriptAvailable = "אין תמלול זמין לשיחה זו";
  
  /// No conversation found message
  static const String conversationNotFound = "שיחה לא נמצאה";
  
  /// No conversation history message
  static const String noConversationHistory = "אין היסטוריית שיחות";
  static const String noConversationHistorySubtext = "שיחות שהושלמו יופיעו כאן";
  
  // =============================================================================
  // DIALOG AND CONFIRMATION MESSAGES
  // =============================================================================
  
  /// Delete conversation dialog
  static const String deleteConversationTitle = "מחק שיחה";
  static const String deleteConversationMessage = "האם אתה בטוח שברצונך למחוק את השיחה?";
  static const String deleteConversationConfirm = "מחק";
  static const String deleteConversationCancel = "ביטול";
  static const String deleteConversationSuccess = "השיחה נמחקה";
  
  // =============================================================================
  // ACTION BUTTONS AND MENU ITEMS
  // =============================================================================
  
  /// Home screen actions
  static const String startNewConversation = "התחל שיחה חדשה";
  
  /// Menu actions
  static const String menuContinue = "המשך";
  static const String menuDelete = "מחק";
  
  // =============================================================================
  // HELPER METHODS
  // =============================================================================
  
  /// Get setup completion message based on whether details were provided
  static String getSetupCompletionMessage({required bool hasDetails}) {
    return hasDetails 
        ? setupCompleteWithDetails 
        : setupCompleteNoDetails;
  }
  
  /// Get appropriate skip keywords for validation
  static List<String> getSkipKeywords() {
    return ['דלג', 'אין', 'לא'];
  }
} 