import 'package:flutter/material.dart';
import 'controller/conversation_flow_controller.dart';
import 'model/conversation_step.dart';
import 'widgets/step_open.dart';
import 'widgets/step_live.dart';
import 'widgets/step_end.dart';

/// Main screen that contains all conversation steps
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late ConversationFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConversationFlowController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('שיחה עם טינה'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder<ConversationStep>(
        valueListenable: _controller.currentStep,
        builder: (context, step, child) {
          return _buildStepWidget(step);
        },
      ),
    );
  }

  Widget _buildStepWidget(ConversationStep step) {
    switch (step) {
      case ConversationStep.open:
        return StepOpen(controller: _controller);
      case ConversationStep.live:
        return StepLive(controller: _controller);
      case ConversationStep.end:
        return StepEnd(controller: _controller);
    }
  }
} 