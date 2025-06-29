import 'package:flutter/material.dart';
import '../controller/conversation_flow_controller.dart';
import '../model/conversation_models.dart';

/// End conversation - status, brief feedback
class StepEnd extends StatefulWidget {
  final ConversationFlowController controller;

  const StepEnd({
    super.key,
    required this.controller,
  });

  @override
  State<StepEnd> createState() => _StepEndState();
}

class _StepEndState extends State<StepEnd> {
  int _rating = 0;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Conversation status
          _buildConversationSummary(),
          
          const SizedBox(height: 40),
          
          // Conversation rating
          _buildRatingSection(),
          
          const SizedBox(height: 30),
          
          // Text feedback
          _buildFeedbackSection(),
          
          const Spacer(),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildConversationSummary() {
    return ValueListenableBuilder<Conversation?>(
      valueListenable: widget.controller.conversation,
      builder: (context, conversation, child) {
        if (conversation == null) return const SizedBox();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'השיחה הסתיימה',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildSummaryRow('משימה:', conversation.task),
                
                if (conversation.duration != null)
                  _buildSummaryRow(
                    'משך השיחה:', 
                    '${conversation.duration!.inMinutes}:${(conversation.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
                  ),
                
                _buildSummaryRow(
                  'זמן התחלה:', 
                  '${conversation.startTime.hour.toString().padLeft(2, '0')}:${conversation.startTime.minute.toString().padLeft(2, '0')}'
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'איך היית מדרג את השיחה?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => setState(() => _rating = index + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'משוב נוסף (אופציונלי)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _feedbackController,
          decoration: const InputDecoration(
            hintText: 'איך נוכל לשפר את השירות?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _submitFeedback,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'שלח משוב',
            style: TextStyle(fontSize: 18),
          ),
        ),
        
        const SizedBox(height: 12),
        
        TextButton(
          onPressed: widget.controller.resetConversation,
          child: const Text('התחל שיחה חדשה'),
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }

  void _submitFeedback() {
    // Here we would send the feedback to the server
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('תודה על המשוב!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Return to home screen
    Future.delayed(const Duration(seconds: 2), () {
      widget.controller.resetConversation();
    });
  }
} 