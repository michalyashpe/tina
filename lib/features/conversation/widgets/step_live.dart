import 'package:flutter/material.dart';
import '../controller/conversation_flow_controller.dart';
import '../model/conversation_models.dart';
import '../components/tina_message_bubble.dart';
import '../components/tina_typing_indicator.dart';
import '../components/agent_message_bubble.dart';
import '../components/user_message_bubble.dart';
import '../../../core/mock_data/conversation_mock_data.dart';
import '../../../core/scripts/conversation_scripts.dart';

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
              return ValueListenableBuilder<bool>(
                valueListenable: widget.controller.isTyping,
                builder: (context, isTyping, child) {
                  print('🎪 Step Live: ValueListenableBuilder rebuild - isTyping: $isTyping'); // Debug log
                  final itemCount = transcript.length + (isTyping ? 1 : 0);
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      // Show typing indicator as the last item if typing
                      if (isTyping && index == transcript.length) {
                        print('🎭 Step Live: Rendering typing indicator'); // Debug log
                        return const TinaTypingIndicator();
                      }
                      
                      final line = transcript[index];
                      return _buildMessageBubble(line);
                    },
                  );
                },
              );
            },
          ),
        ),
        
        // Test and End buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Debug button to test typing indicator
              // if (false) ElevatedButton(
              //   onPressed: () {
              //     print('🧪 Manual test: Showing typing indicator');
              //     widget.controller.showTypingIndicator();
              //     Future.delayed(const Duration(seconds: 3), () {
              //       print('🧪 Manual test: Hiding typing indicator');
              //       widget.controller.hideTypingIndicator();
              //     });
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blue,
              //     foregroundColor: Colors.white,
              //     padding: const EdgeInsets.symmetric(vertical: 12),
              //   ),
              //   child: const Text('🧪 Test Typing Indicator'),
              // ),
              // const SizedBox(height: 8),
              ElevatedButton(
                onPressed: widget.controller.endConversation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(ConversationScripts.liveEndButton),
              ),
            ],
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
            ConversationScripts.liveStatusActive,
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
    // Use centralized mock conversation simulation
    final simulationSteps = ConversationMockData.getMockConversationSimulation();
    
    for (final step in simulationSteps) {
      Future.delayed(step.delay, () {
        // Show typing indicator before Tina's messages
        if (step.sender == MessageSender.tina) {
          print('📱 Live: Showing typing for Tina message: ${step.message}'); // Debug log
          widget.controller.showTypingIndicator();
          _scrollToBottom();
          
          // Show message after typing delay
          Future.delayed(const Duration(milliseconds: 1500), () {
            print('📱 Live: Hiding typing and showing message'); // Debug log
            widget.controller.hideTypingIndicator();
            
            final transcriptLine = TranscriptLine.fromTina(step.message);
            widget.controller.addTranscriptLine(transcriptLine);
            _scrollToBottom();
          });
        } else {
          // For non-Tina messages, show immediately
          final transcriptLine = switch (step.sender) {
            MessageSender.tina => TranscriptLine.fromTina(step.message),
            MessageSender.user => TranscriptLine.fromUser(step.message),
            MessageSender.agent => TranscriptLine.fromAgent(step.message),
          };
          
          widget.controller.addTranscriptLine(transcriptLine);
          _scrollToBottom();
        }
      });
    }
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