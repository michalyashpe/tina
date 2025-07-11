/// Conversation Flow Data Configuration
/// This file defines the entire conversation flow for Tina.
/// You can easily modify questions, add new steps, or change the order here.

class ConversationFlowData {
  static const List<Map<String, dynamic>> steps = [
    {
      'id': 'welcome',
      'question_text': '''היי אני פה בשבילך! 
מה המשימה שתרצי שאבצע עבורך היום?''',
      'hint_text': 'תיאור המשימה...',
      'target_field': 'task',
      'is_optional': false,
      'skip_keywords': <String>[],
      'next_step_id': 'contact',
    },
    {
      'id': 'contact',
      'question_text': 'סבבה. עם מי את רוצה שאדבר?',
      'hint_text': 'מספר טלפון או שם איש קשר...',
      'target_field': 'contactPhone',
      'is_optional': false,
      'skip_keywords': <String>[],
      'next_step_id': 'details',
    },
    {
      'id': 'details',
      'question_text': '''יש פרטים שיכולים לעזור לי בשיחה?
למשל ת״ז, מספר לקוח או פוליסה?

(אפשר לכתוב 'דלג' אם אין)''',
      'hint_text': 'פרטים מזהים (אופציונלי)...',
      'target_field': 'identifyingDetails',
      'is_optional': true,
      'skip_keywords': ['דלג', 'אין', 'לא'],
      'next_step_id': 'complete',
      'completion_messages': {
        'with_answer': '''מעולה! הפרטים יעזרו לי בשיחה.

אני מתחילה את השיחה עכשיו...''',
        'without_answer': '''בסדר, נמשיך בלי פרטים נוספים.

אני מתחילה את השיחה עכשיו...''',
      },
    },
  ];
} 