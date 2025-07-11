import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import '../model/conversation_flow_config.dart';

/// Exception thrown when there's an error in conversation flow configuration
class ConversationFlowException implements Exception {
  final String message;
  const ConversationFlowException(this.message);
  
  @override
  String toString() => 'ConversationFlowException: $message';
}

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
      final yamlMap = loadYaml(yamlString);
      if (yamlMap is! Map) {
        throw ConversationFlowException('YAML root must be a Map, got ${yamlMap.runtimeType}');
      }
      
      final conversationFlow = yamlMap['conversation_flow'];
      if (conversationFlow is! Map) {
        throw ConversationFlowException('conversation_flow must be a Map, got ${conversationFlow.runtimeType}');
      }
      
      final stepsData = conversationFlow['steps'];
      if (stepsData is! List) {
        throw ConversationFlowException('steps must be a List, got ${stepsData.runtimeType}');
      }

      // Convert to ConversationStepConfig objects
      _cachedSteps = stepsData.map((stepData) => _parseStepConfig(stepData)).toList();
      
      // Validate the loaded configuration
      _validateConfiguration(_cachedSteps!);
      
      print('📄 Loaded ${_cachedSteps!.length} conversation steps from YAML');
      return _cachedSteps!;
      
    } catch (e) {
      if (e is ConversationFlowException) {
        rethrow;
      }
      throw ConversationFlowException('Failed to load conversation flow: $e');
    }
  }

  /// Parse individual step configuration from YAML
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

  /// Parse completion message function from YAML
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

  /// Reload configuration from YAML (clears cache and loads again)
  Future<List<ConversationStepConfig>> reloadConfiguration() async {
    clearCache();
    return loadConversationFlow();
  }
} 