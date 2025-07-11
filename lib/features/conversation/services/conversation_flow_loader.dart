import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import '../model/conversation_flow_config.dart';

/// Service for loading conversation flow configuration from YAML
class ConversationFlowLoader {
  static ConversationFlowLoader? _instance;
  List<ConversationStepConfig>? _cachedSteps;

  ConversationFlowLoader._();

  static ConversationFlowLoader get instance {
    _instance ??= ConversationFlowLoader._();
    return _instance!;
  }

  /// Load conversation flow from YAML file
  Future<List<ConversationStepConfig>> loadConversationFlow() async {
    // Return cached steps if already loaded
    if (_cachedSteps != null) {
      return _cachedSteps!;
    }

    try {
      // Load YAML file from assets
      final yamlString = await rootBundle.loadString('assets/config/conversation_flow.yaml');
      
      // Parse YAML
      final yamlMap = loadYaml(yamlString) as Map;
      final conversationFlow = yamlMap['conversation_flow'] as Map;
      final stepsData = conversationFlow['steps'] as List;

      // Convert to ConversationStepConfig objects
      _cachedSteps = stepsData.map((stepData) => _parseStepConfig(stepData)).toList();
      
      print('📄 Loaded ${_cachedSteps!.length} conversation steps from YAML');
      return _cachedSteps!;
      
    } catch (e) {
      print('❌ Error loading conversation flow from YAML: $e');
      
      // Return fallback configuration if YAML loading fails
      return _getFallbackConfiguration();
    }
  }

  /// Parse individual step configuration from YAML
  ConversationStepConfig _parseStepConfig(dynamic stepData) {
    final step = stepData as Map;
    
    return ConversationStepConfig(
      id: step['id'] as String,
      questionText: step['question_text'] as String,
      hintText: step['hint_text'] as String?,
      targetField: step['target_field'] as String,
      isOptional: step['is_optional'] as bool? ?? false,
      skipKeywords: (step['skip_keywords'] as List?)?.cast<String>() ?? const [],
      nextStepId: step['next_step_id'] as String?,
      completionMessage: _parseCompletionMessage(step['completion_messages']),
    );
  }

  /// Parse completion message function from YAML
  String Function(bool)? _parseCompletionMessage(dynamic completionMessages) {
    if (completionMessages == null) return null;
    
    final messages = completionMessages as Map;
    final withAnswer = messages['with_answer'] as String?;
    final withoutAnswer = messages['without_answer'] as String?;
    
    if (withAnswer == null || withoutAnswer == null) return null;
    
    return (bool hasAnswer) => hasAnswer ? withAnswer : withoutAnswer;
  }

  /// Fallback configuration in case YAML loading fails
  List<ConversationStepConfig> _getFallbackConfiguration() {
    print('⚠️ Using fallback conversation configuration');
    
    return [
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
  }

  /// Clear cache - useful for testing or reloading configuration
  void clearCache() {
    _cachedSteps = null;
  }

  /// Reload configuration from YAML (clears cache and loads again)
  Future<List<ConversationStepConfig>> reloadConfiguration() async {
    clearCache();
    return loadConversationFlow();
  }
} 