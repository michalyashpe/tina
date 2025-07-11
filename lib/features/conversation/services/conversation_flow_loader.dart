import '../model/conversation_flow_config.dart';
import '../../../config/conversation_flow_data.dart';

/// Exception thrown when there's an error in conversation flow configuration
class ConversationFlowException implements Exception {
  final String message;
  const ConversationFlowException(this.message);
  
  @override
  String toString() => 'ConversationFlowException: $message';
}

/// Service for loading conversation flow configuration from Dart data
class ConversationFlowLoader {
  static ConversationFlowLoader? _instance;
  List<ConversationStepConfig>? _cachedSteps;

  ConversationFlowLoader._();

  static ConversationFlowLoader get instance {
    _instance ??= ConversationFlowLoader._();
    return _instance!;
  }

  /// Load conversation flow from Dart configuration
  Future<List<ConversationStepConfig>> loadConversationFlow() async {
    // Return cached steps if already loaded
    if (_cachedSteps != null) {
      print('📋 Returning cached conversation flow steps');
      return _cachedSteps!;
    }

    try {
      // Load steps from Dart configuration
      print('📁 Loading conversation flow from Dart configuration...');
      final stepsData = ConversationFlowData.steps;
      print('📄 Loaded ${stepsData.length} conversation steps from Dart');
      
      // Debug: Print first question to verify content
      if (stepsData.isNotEmpty) {
        final firstStep = stepsData.first;
        final questionText = firstStep['question_text'] as String? ?? '';
        final lines = questionText.split('\n');
        print('📝 First question preview: ${lines.isNotEmpty ? lines.first : 'N/A'}');
      }

      // Convert to ConversationStepConfig objects
      _cachedSteps = stepsData.map((stepData) => _parseStepConfig(stepData)).toList();
      
      // Validate the loaded configuration
      _validateConfiguration(_cachedSteps!);
      
      print('📄 Loaded ${_cachedSteps!.length} conversation steps from Dart configuration');
      return _cachedSteps!;
      
    } catch (e) {
      if (e is ConversationFlowException) {
        rethrow;
      }
      throw ConversationFlowException('Failed to load conversation flow from Dart configuration: $e');
    }
  }

  /// Parse individual step configuration from Dart data
  ConversationStepConfig _parseStepConfig(dynamic stepData) {
    if (stepData is! Map) {
      throw ConversationFlowException('Step data must be a Map, got ${stepData.runtimeType}');
    }
    
    final step = stepData;
    
    // Validate required fields
    final id = step['id'];
    if (id is! String || id.isEmpty) {
      throw ConversationFlowException('Step must have a non-empty string id');
    }
    
    final questionText = step['question_text'];
    if (questionText is! String || questionText.isEmpty) {
      throw ConversationFlowException('Step $id must have non-empty question_text');
    }
    
    final targetField = step['target_field'];
    if (targetField is! String || targetField.isEmpty) {
      throw ConversationFlowException('Step $id must have non-empty target_field');
    }
    
    // Validate target field values
    const validTargetFields = ['task', 'contactPhone', 'identifyingDetails'];
    if (!validTargetFields.contains(targetField)) {
      throw ConversationFlowException('Step $id has invalid target_field: $targetField. Must be one of: $validTargetFields');
    }
    
    // Validate optional fields
    final hintText = step['hint_text'];
    if (hintText != null && hintText is! String) {
      throw ConversationFlowException('Step $id hint_text must be a string if provided');
    }
    
    final isOptional = step['is_optional'];
    if (isOptional != null && isOptional is! bool) {
      throw ConversationFlowException('Step $id is_optional must be a boolean if provided');
    }
    
    final skipKeywords = step['skip_keywords'];
    if (skipKeywords != null && skipKeywords is! List) {
      throw ConversationFlowException('Step $id skip_keywords must be a list if provided');
    }
    
    final nextStepId = step['next_step_id'];
    if (nextStepId != null && nextStepId is! String) {
      throw ConversationFlowException('Step $id next_step_id must be a string if provided');
    }
    
    return ConversationStepConfig(
      id: id,
      questionText: questionText,
      hintText: hintText,
      targetField: targetField,
      isOptional: isOptional ?? false,
      skipKeywords: skipKeywords?.cast<String>() ?? const [],
      nextStepId: nextStepId,
      completionMessage: _parseCompletionMessage(step['completion_messages']),
    );
  }

  /// Parse completion message function from Dart data
  String Function(bool)? _parseCompletionMessage(dynamic completionMessages) {
    if (completionMessages == null) return null;
    
    final messages = completionMessages as Map;
    final withAnswer = messages['with_answer'] as String?;
    final withoutAnswer = messages['without_answer'] as String?;
    
    if (withAnswer == null || withoutAnswer == null) return null;
    
    return (bool hasAnswer) => hasAnswer ? withAnswer : withoutAnswer;
  }

  /// Validate the loaded configuration for logical consistency
  void _validateConfiguration(List<ConversationStepConfig> steps) {
    if (steps.isEmpty) {
      throw ConversationFlowException('Configuration must contain at least one step');
    }
    
    // Check for required steps
    final stepIds = steps.map((s) => s.id).toSet();
    if (!stepIds.contains('welcome')) {
      throw ConversationFlowException('Configuration must contain a welcome step');
    }
    
    // Check for duplicate IDs
    final duplicateIds = <String>[];
    final seenIds = <String>{};
    for (final step in steps) {
      if (seenIds.contains(step.id)) {
        duplicateIds.add(step.id);
      }
      seenIds.add(step.id);
    }
    if (duplicateIds.isNotEmpty) {
      throw ConversationFlowException('Duplicate step IDs found: $duplicateIds');
    }
    
    // Validate flow consistency
    for (final step in steps) {
      if (step.nextStepId != null && 
          step.nextStepId != 'complete' && 
          !stepIds.contains(step.nextStepId!)) {
        throw ConversationFlowException('Step ${step.id} references non-existent step: ${step.nextStepId}');
      }
    }
    
    // Check for circular references
    _validateNoCircularReferences(steps);
    
    // Validate optional steps have skip keywords
    for (final step in steps) {
      if (step.isOptional && step.skipKeywords.isEmpty) {
        throw ConversationFlowException('Optional step ${step.id} must have skip keywords');
      }
    }
  }
  
  /// Validate there are no circular references in the flow
  void _validateNoCircularReferences(List<ConversationStepConfig> steps) {
    final stepMap = {for (final step in steps) step.id: step};
    
    for (final startStep in steps) {
      final visited = <String>{};
      var currentId = startStep.id;
      
      while (currentId != 'complete' && currentId.isNotEmpty) {
        if (visited.contains(currentId)) {
          throw ConversationFlowException('Circular reference detected starting from step: ${startStep.id}');
        }
        
        visited.add(currentId);
        final currentStep = stepMap[currentId];
        if (currentStep == null) break;
        
        currentId = currentStep.nextStepId ?? 'complete';
      }
    }
  }

  /// Clear cache - useful for testing or reloading configuration
  void clearCache() {
    _cachedSteps = null;
  }

  /// Reload configuration from Dart data (clears cache and loads again)
  Future<List<ConversationStepConfig>> reloadConfiguration() async {
    clearCache();
    return loadConversationFlow();
  }

  /// Force reload configuration (for development - bypasses all caches)
  Future<List<ConversationStepConfig>> forceReloadConfiguration() async {
    clearCache();
    
    // With Dart configuration, force reload just clears cache
    // since Dart files reload automatically with hot reload
    print('🔄 Force reloading Dart configuration...');
    return loadConversationFlow();
  }
} 