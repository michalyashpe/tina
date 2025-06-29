import 'package:flutter/material.dart';
import '../controller/conversation_flow_controller.dart';
import '../model/conversation_models.dart';
import '../components/tina_message_bubble.dart';
import '../components/agent_message_bubble.dart';
import '../components/user_message_bubble.dart';

/// Live conversation - transcript, status, calls
class StepLive extends StatefulWidget {
  final ConversationFlowController controller;

  const StepLive({
    super.key,
    required this.controller,
  });

  @override
  State<StepLive> createState() => _StepLiveState();
}

class _StepLiveState extends State<StepLive> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _simulateConversation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status bar
        _buildStatusBar(),
        
        // Conversation transcript
        Expanded(
          child: ValueListenableBuilder<List<TranscriptLine>>(
            valueListenable: widget.controller.transcript,
            builder: (context, transcript, child) {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: transcript.length,
                itemBuilder: (context, index) {
                  final line = transcript[index];
                  return _buildMessageBubble(line);
                },
              );
            },
          ),
        ),
        
        // End conversation button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: widget.controller.endConversation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('סיים שיחה'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.radio_button_checked,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            'שיחה פעילה',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<Conversation?>(
            valueListenable: widget.controller.conversation,
            builder: (context, conversation, child) {
              if (conversation == null) return const SizedBox();
              final duration = DateTime.now().difference(conversation.startTime);
              return Text(
                '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.grey),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(TranscriptLine line) {
    switch (line.sender) {
      case MessageSender.tina:
        return TinaMessageBubble(transcriptLine: line);
      case MessageSender.agent:
        return AgentMessageBubble(transcriptLine: line);
      case MessageSender.user:
        return UserMessageBubble(transcriptLine: line);
    }
  }

  void _simulateConversation() {
    // Example conversation simulation
    Future.delayed(const Duration(seconds: 1), () {
      widget.controller.addTranscriptLine(
        TranscriptLine.fromTina('שלום! אני טינה, עוזרת הדיגיטלית. איך אוכל לעזור לך היום?'),
      );
      _scrollToBottom();
    });

    Future.delayed(const Duration(seconds: 3), () {
      widget.controller.addTranscriptLine(
        TranscriptLine.fromUser('שלום טינה, אני רוצה לבטל פוליסת ביטוח'),
      );
      _scrollToBottom();
    });

    Future.delayed(const Duration(seconds: 5), () {
      widget.controller.addTranscriptLine(
        TranscriptLine.fromTina('בהחלט אוכל לעזור לך. אני מעבירה אותך לנציג שירות מתמחה'),
      );
      _scrollToBottom();
    });

    Future.delayed(const Duration(seconds: 7), () {
      widget.controller.addTranscriptLine(
        TranscriptLine.fromAgent('שלום, אני דניאל מצוות שירות הלקוחות. איך אוכל לעזור?'),
      );
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
} 