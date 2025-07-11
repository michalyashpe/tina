#!/usr/bin/env dart

import 'dart:io';
import '../lib/config/conversation_flow_data.dart';

/// Script to validate conversation flow Dart configuration
/// Run with: dart scripts/validate_conversation_flow.dart

void main() async {
  print('🔍 Validating conversation flow configuration...\n');

  try {
    // Read Dart configuration
    print('📁 Loading conversation flow from Dart configuration...');
    final stepsData = ConversationFlowData.steps;

    // Parse and validate steps
    final steps = _parseStepsFromDart(stepsData);
    _validateSteps(steps);
    _validateFlow(steps);

    print('✅ Conversation flow configuration is valid!');
    print('📊 Summary:');
    print('   • ${steps.length} steps configured');
    print('   • Flow: ${_getFlowSummary(steps)}');
    print('   • Optional steps: ${steps.where((s) => s.isOptional).length}');
    
  } catch (e) {
    print('❌ Validation failed: $e');
    exit(1);
  }
}

void _validateStructure(dynamic yamlData) {
  if (yamlData is! Map) {
    throw ValidationException('Root must be a Map');
  }

  if (!yamlData.containsKey('conversation_flow')) {
    throw ValidationException('Missing required key: conversation_flow');
  }

  final conversationFlow = yamlData['conversation_flow'];
  if (conversationFlow is! Map) {
    throw ValidationException('conversation_flow must be a Map');
  }

  if (!conversationFlow.containsKey('steps')) {
    throw ValidationException('Missing required key: conversation_flow.steps');
  }

  if (conversationFlow['steps'] is! List) {
    throw ValidationException('conversation_flow.steps must be a List');
  }
}

List<StepData> _parseStepsFromDart(List<Map<String, dynamic>> stepsData) {
  final steps = <StepData>[];

  for (int i = 0; i < stepsData.length; i++) {
    final stepData = stepsData[i];
    steps.add(StepData.fromMap(stepData, i));
  }

  return steps;
}

List<StepData> _parseSteps(Map yamlData) {
  final stepsData = yamlData['conversation_flow']['steps'] as List;
  final steps = <StepData>[];

  for (int i = 0; i < stepsData.length; i++) {
    final stepData = stepsData[i];
    if (stepData is! Map) {
      throw ValidationException('Step $i must be a Map');
    }

    steps.add(StepData.fromMap(stepData, i));
  }

  return steps;
}

void _validateSteps(List<StepData> steps) {
  if (steps.isEmpty) {
    throw ValidationException('Must have at least one step');
  }

  // Check for duplicate IDs
  final ids = <String>[];
  for (final step in steps) {
    if (ids.contains(step.id)) {
      throw ValidationException('Duplicate step ID: ${step.id}');
    }
    ids.add(step.id);
  }

  // Check required step exists
  if (!ids.contains('welcome')) {
    throw ValidationException('Missing required step: welcome');
  }

  // Validate each step
  for (final step in steps) {
    _validateStep(step);
  }
}

void _validateStep(StepData step) {
  // Validate ID
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(step.id)) {
    throw ValidationException('Step ${step.id}: ID must contain only alphanumeric characters and underscores');
  }

  // Validate target field
  const validTargetFields = ['task', 'contactPhone', 'identifyingDetails'];
  if (!validTargetFields.contains(step.targetField)) {
    throw ValidationException('Step ${step.id}: Invalid target_field "${step.targetField}". Must be one of: $validTargetFields');
  }

  // Validate question text
  if (step.questionText.trim().length < 10) {
    throw ValidationException('Step ${step.id}: Question text too short');
  }

  // Check for Hebrew characters
  if (!RegExp(r'[\u0590-\u05FF]+').hasMatch(step.questionText)) {
    print('⚠️  Warning: Step ${step.id} question text does not contain Hebrew characters');
  }

  // Validate optional steps
  if (step.isOptional && step.skipKeywords.isEmpty) {
    throw ValidationException('Step ${step.id}: Optional steps must have skip keywords');
  }

  // Validate completion messages if present
  if (step.completionMessages.isNotEmpty) {
    if (!step.completionMessages.containsKey('with_answer')) {
      throw ValidationException('Step ${step.id}: Completion messages must include "with_answer"');
    }
    if (!step.completionMessages.containsKey('without_answer')) {
      throw ValidationException('Step ${step.id}: Completion messages must include "without_answer"');
    }
  }
}

void _validateFlow(List<StepData> steps) {
  final stepIds = steps.map((s) => s.id).toSet();

  // Validate next step references
  for (final step in steps) {
    if (step.nextStepId != null && 
        step.nextStepId != 'complete' && 
        !stepIds.contains(step.nextStepId!)) {
      throw ValidationException('Step ${step.id}: References non-existent step "${step.nextStepId}"');
    }
  }

  // Check for circular references
  _validateNoCircularReferences(steps);

  // Ensure welcome step leads somewhere
  final welcomeStep = steps.firstWhere((s) => s.id == 'welcome');
  if (welcomeStep.nextStepId == null) {
    throw ValidationException('Welcome step must have a next_step_id');
  }
}

void _validateNoCircularReferences(List<StepData> steps) {
  final stepMap = {for (final step in steps) step.id: step};

  for (final startStep in steps) {
    final visited = <String>{};
    var currentId = startStep.id;
    var maxIterations = 20;

    while (currentId != 'complete' && currentId.isNotEmpty && maxIterations > 0) {
      if (visited.contains(currentId)) {
        throw ValidationException('Circular reference detected starting from step: ${startStep.id}');
      }

      visited.add(currentId);
      final currentStep = stepMap[currentId];
      if (currentStep == null) break;

      currentId = currentStep.nextStepId ?? 'complete';
      maxIterations--;
    }

    if (maxIterations <= 0) {
      throw ValidationException('Possible infinite loop detected starting from step: ${startStep.id}');
    }
  }
}

String _getFlowSummary(List<StepData> steps) {
  final stepMap = {for (final step in steps) step.id: step};
  var currentId = 'welcome';
  final flowSteps = <String>[];

  while (currentId != 'complete' && flowSteps.length < 10) {
    flowSteps.add(currentId);
    final currentStep = stepMap[currentId];
    if (currentStep == null) break;
    currentId = currentStep.nextStepId ?? 'complete';
  }

  return flowSteps.join(' → ') + (currentId == 'complete' ? ' → complete' : '');
}

class StepData {
  final String id;
  final String questionText;
  final String? hintText;
  final String targetField;
  final bool isOptional;
  final List<String> skipKeywords;
  final String? nextStepId;
  final Map<String, String> completionMessages;

  StepData({
    required this.id,
    required this.questionText,
    this.hintText,
    required this.targetField,
    this.isOptional = false,
    this.skipKeywords = const [],
    this.nextStepId,
    this.completionMessages = const {},
  });

  factory StepData.fromMap(Map stepData, int index) {
    final id = stepData['id'];
    if (id is! String || id.isEmpty) {
      throw ValidationException('Step $index: Missing or empty "id" field');
    }

    final questionText = stepData['question_text'];
    if (questionText is! String || questionText.isEmpty) {
      throw ValidationException('Step $id: Missing or empty "question_text" field');
    }

    final targetField = stepData['target_field'];
    if (targetField is! String || targetField.isEmpty) {
      throw ValidationException('Step $id: Missing or empty "target_field" field');
    }

    final hintText = stepData['hint_text'] as String?;
    final isOptional = stepData['is_optional'] as bool? ?? false;
    final skipKeywords = (stepData['skip_keywords'] as List?)?.cast<String>() ?? <String>[];
    final nextStepId = stepData['next_step_id'] as String?;

    Map<String, String> completionMessages = {};
    if (stepData['completion_messages'] is Map) {
      final messages = stepData['completion_messages'] as Map;
      completionMessages = messages.map((k, v) => MapEntry(k.toString(), v.toString()));
    }

    return StepData(
      id: id,
      questionText: questionText,
      hintText: hintText,
      targetField: targetField,
      isOptional: isOptional,
      skipKeywords: skipKeywords,
      nextStepId: nextStepId,
      completionMessages: completionMessages,
    );
  }
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
} 