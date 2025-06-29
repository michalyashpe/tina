import 'package:flutter/material.dart';
import '../controller/conversation_flow_controller.dart';

/// Opening conversation step - setting task and parameters
class StepOpen extends StatefulWidget {
  final ConversationFlowController controller;

  const StepOpen({
    super.key,
    required this.controller,
  });

  @override
  State<StepOpen> createState() => _StepOpenState();
}

class _StepOpenState extends State<StepOpen> {
  final _taskController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _taskController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Header
            Text(
              'התחלת שיחה עם טינה',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            Text(
              'אנא הזן את המשימה שברצונך לבצע',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Task field
            TextFormField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'תיאור המשימה *',
                hintText: 'לדוגמה: אני רוצה לבטל פוליסת ביטוח',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'אנא הזן תיאור משימה';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Additional information
            TextFormField(
              controller: _additionalInfoController,
              decoration: const InputDecoration(
                labelText: 'מידע נוסף (אופציונלי)',
                hintText: 'פרטים נוספים שיכולים לעזור',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            
            const Spacer(),
            
            // Start conversation button
            ElevatedButton(
              onPressed: _startConversation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'התחל שיחה',
                style: TextStyle(fontSize: 18),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _startConversation() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.controller.startConversation(
        task: _taskController.text.trim(),
        additionalInfo: _additionalInfoController.text.trim().isEmpty 
            ? null 
            : _additionalInfoController.text.trim(),
      );
    }
  }
} 