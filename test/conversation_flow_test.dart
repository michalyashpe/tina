import 'package:flutter_test/flutter_test.dart';
import 'package:tina/features/conversation/services/conversation_flow_loader.dart';
import 'package:tina/features/conversation/model/conversation_flow_config.dart';
import 'package:tina/config/conversation_flow_data.dart';

void main() {
  // Initialize the binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Conversation Flow Dart Configuration Tests', () {
    late ConversationFlowLoader loader;

    setUp(() {
      loader = ConversationFlowLoader.instance;
      loader.clearCache(); // Clear cache before each test
    });

    group('Dart Configuration Loading', () {
      test('should load Dart configuration without errors', () async {
        expect(() => ConversationFlowData.steps, returnsNormally);
      });

      test('should have valid configuration structure', () async {
        final stepsData = ConversationFlowData.steps;
        
        expect(stepsData, isA<List<Map<String, dynamic>>>());
        expect(stepsData, isNotEmpty);
        
        // Verify each step has required fields
        for (final step in stepsData) {
          expect(step, containsPair('id', isA<String>()));
          expect(step, containsPair('question_text', isA<String>()));
          expect(step, containsPair('target_field', isA<String>()));
        }
      });
    });

    group('Configuration Validation', () {
      test('should load conversation steps successfully', () async {
        final steps = await loader.loadConversationFlow();
        
        expect(steps, isNotEmpty);
        expect(steps.length, greaterThanOrEqualTo(3)); // welcome, contact, details
        
        // Verify all steps are ConversationStepConfig instances
        for (final step in steps) {
          expect(step, isA<ConversationStepConfig>());
        }
      });

      test('should have required step IDs', () async {
        final steps = await loader.loadConversationFlow();
        final stepIds = steps.map((s) => s.id).toList();
        
        // Essential steps that must exist
        expect(stepIds, contains('welcome'));
        expect(stepIds, contains('contact'));
        expect(stepIds, contains('details'));
      });

      test('should validate all steps have required fields', () async {
        final steps = await loader.loadConversationFlow();
        
        for (final step in steps) {
          // Required fields
          expect(step.id, isNotEmpty, reason: 'Step ${step.id} must have non-empty ID');
          expect(step.questionText, isNotEmpty, reason: 'Step ${step.id} must have question text');
          expect(step.targetField, isNotEmpty, reason: 'Step ${step.id} must have target field');
          
          // ID should be alphanumeric/underscore only
          expect(step.id, matches(RegExp(r'^[a-zA-Z0-9_]+$')), 
            reason: 'Step ID ${step.id} should contain only alphanumeric characters and underscores');
          
          // Target field should be valid
          expect(['task', 'contactPhone', 'identifyingDetails'], contains(step.targetField),
            reason: 'Step ${step.id} has invalid target field: ${step.targetField}');
        }
      });

      test('should validate flow consistency', () async {
        final steps = await loader.loadConversationFlow();
        final stepIds = steps.map((s) => s.id).toSet();
        
        for (final step in steps) {
          if (step.nextStepId != null && step.nextStepId != 'complete') {
            expect(stepIds, contains(step.nextStepId),
              reason: 'Step ${step.id} references non-existent next step: ${step.nextStepId}');
          }
        }
      });

      test('should have logical flow order', () async {
        final steps = await loader.loadConversationFlow();
        
        // Find welcome step
        final welcomeStep = steps.firstWhere((s) => s.id == 'welcome');
        expect(welcomeStep.nextStepId, isNotNull, reason: 'Welcome step must have next step');
        
        // Verify we can traverse the entire flow
        var currentStepId = 'welcome';
        final visitedSteps = <String>{};
        var maxIterations = 10; // Prevent infinite loops
        
        while (currentStepId != 'complete' && maxIterations > 0) {
          expect(visitedSteps, isNot(contains(currentStepId)), 
            reason: 'Flow contains circular reference at step: $currentStepId');
          
          visitedSteps.add(currentStepId);
          
          final currentStep = steps.firstWhere((s) => s.id == currentStepId);
          currentStepId = currentStep.nextStepId ?? 'complete';
          maxIterations--;
        }
        
        expect(maxIterations, greaterThan(0), reason: 'Flow seems to have infinite loop');
        expect(currentStepId, equals('complete'), reason: 'Flow should end at complete');
      });

      test('should validate optional fields correctly', () async {
        final steps = await loader.loadConversationFlow();
        
        for (final step in steps) {
          // If step is optional, it should have skip keywords
          if (step.isOptional) {
            expect(step.skipKeywords, isNotEmpty, 
              reason: 'Optional step ${step.id} should have skip keywords');
          }
          
          // Skip keywords should be meaningful
          for (final keyword in step.skipKeywords) {
            expect(keyword.trim(), isNotEmpty,
              reason: 'Step ${step.id} has empty skip keyword');
          }
        }
      });

      test('should validate completion messages', () async {
        final steps = await loader.loadConversationFlow();
        
        for (final step in steps) {
          if (step.completionMessage != null) {
            final withAnswer = step.completionMessage!(true);
            final withoutAnswer = step.completionMessage!(false);
            
            expect(withAnswer, isNotEmpty, 
              reason: 'Step ${step.id} completion message with answer is empty');
            expect(withoutAnswer, isNotEmpty,
              reason: 'Step ${step.id} completion message without answer is empty');
            expect(withAnswer, isNot(equals(withoutAnswer)),
              reason: 'Step ${step.id} should have different messages for with/without answer');
          }
        }
      });
    });

    group('Data Quality Tests', () {
      test('should have meaningful question texts', () async {
        final steps = await loader.loadConversationFlow();
        
        for (final step in steps) {
          // Questions should be substantial
          expect(step.questionText.trim().length, greaterThan(10),
            reason: 'Step ${step.id} question seems too short: "${step.questionText}"');
          
          // Should contain Hebrew characters (since it's Hebrew interface)
          expect(step.questionText, matches(RegExp(r'[\u0590-\u05FF]+')),
            reason: 'Step ${step.id} question should contain Hebrew text');
        }
      });

      test('should have appropriate hint texts', () async {
        final steps = await loader.loadConversationFlow();
        
        for (final step in steps) {
          if (step.hintText != null) {
            expect(step.hintText!.trim(), isNotEmpty,
              reason: 'Step ${step.id} has empty hint text');
            expect(step.hintText!.length, lessThan(100),
              reason: 'Step ${step.id} hint text seems too long');
          }
        }
      });

      test('should have consistent skip keywords', () async {
        final steps = await loader.loadConversationFlow();
        final expectedSkipKeywords = {'דלג', 'אין', 'לא'};
        
        for (final step in steps) {
          if (step.isOptional) {
            final stepKeywords = step.skipKeywords.toSet();
            expect(stepKeywords, containsAll(expectedSkipKeywords),
              reason: 'Optional step ${step.id} should contain standard skip keywords');
          }
        }
      });
    });

    group('Error Handling Tests', () {
      test('should handle configuration loading gracefully', () async {
        // This test verifies the configuration loading works correctly
        // With Dart configuration, we have compile-time safety
        
        final steps = await loader.loadConversationFlow();
        expect(steps, isNotEmpty);
      });

      test('should handle missing required fields', () async {
        // This would require mocking the asset bundle to return incomplete YAML
        // For now, verify current structure is complete
        final steps = await loader.loadConversationFlow();
        
        for (final step in steps) {
          expect(step.id, isNotNull);
          expect(step.questionText, isNotNull);
          expect(step.targetField, isNotNull);
        }
      });
    });

    group('Performance Tests', () {
      test('should cache loaded configuration', () async {
        final start1 = DateTime.now();
        final steps1 = await loader.loadConversationFlow();
        final duration1 = DateTime.now().difference(start1);
        
        final start2 = DateTime.now();
        final steps2 = await loader.loadConversationFlow();
        final duration2 = DateTime.now().difference(start2);
        
        // Second call should be much faster (cached)
        expect(duration2.inMicroseconds, lessThan(duration1.inMicroseconds));
        expect(steps1.length, equals(steps2.length));
      });

      test('should reload configuration when requested', () async {
        final steps1 = await loader.loadConversationFlow();
        final steps2 = await loader.reloadConfiguration();
        
        expect(steps1.length, equals(steps2.length));
        // Verify it's actually reloaded (not just cached)
        expect(identical(steps1, steps2), isFalse);
      });
    });

    group('Integration with ConversationFlowConfig', () {
      test('should integrate correctly with ConversationFlowConfig', () async {
        final steps = await ConversationFlowConfig.getSteps();
        expect(steps, isNotEmpty);
        
        final firstStep = await ConversationFlowConfig.getFirstStep();
        expect(firstStep.id, equals('welcome'));
        
        final welcomeStep = await ConversationFlowConfig.getStepById('welcome');
        expect(welcomeStep, isNotNull);
        expect(welcomeStep!.id, equals('welcome'));
      });

      test('should handle step lookups correctly', () async {
        final steps = await ConversationFlowConfig.getSteps();
        
        for (final step in steps) {
          final foundStep = await ConversationFlowConfig.getStepById(step.id);
          expect(foundStep, isNotNull);
          expect(foundStep!.id, equals(step.id));
        }
        
        // Test non-existent step
        final nonExistent = await ConversationFlowConfig.getStepById('non_existent');
        expect(nonExistent, isNull);
      });
    });
  });
} 