import 'package:flutter/material.dart';
import '../controller/conversation_flow_controller.dart';
import '../model/conversation_models.dart';
import '../components/tina_message_bubble.dart';
import '../components/tina_typing_indicator.dart';
import '../components/user_message_bubble.dart';
import '../components/tina_avatar.dart';
import '../../../core/scripts/conversation_scripts.dart';

/// Opening conversation step - chat-based setup with Tina
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
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize setup on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        widget.controller.initializeSetup();
        _isInitialized = true;
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF6B73FF),
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          const TinaAvatar(
            size: 35,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'טינה',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: widget.controller.isTyping,
                builder: (context, isTyping, child) {
                  return Text(
                    isTyping ? '💬 כותבת...' : 'מוכנה לעזור',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ValueListenableBuilder<List<TranscriptLine>>(
      valueListenable: widget.controller.setupMessages,
      builder: (context, messages, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.controller.isTyping,
          builder: (context, isTyping, child) {
            print('🎪 Step Open: ValueListenableBuilder rebuild - isTyping: $isTyping'); // Debug log
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            final itemCount = messages.length + (isTyping ? 1 : 0);

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                // Show typing indicator as the last item if typing
                if (isTyping && index == messages.length) {
                  print('🎭 Step Open: Rendering typing indicator'); // Debug log
                  return const TinaTypingIndicator();
                }
                
                final message = messages[index];
                
                if (message.sender == MessageSender.tina) {
                  return TinaMessageBubble(transcriptLine: message);
                } else {
                  return UserMessageBubble(transcriptLine: message);
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return ValueListenableBuilder<SetupStep>(
      valueListenable: widget.controller.setupStep,
      builder: (context, setupStep, child) {
        if (setupStep == SetupStep.welcome || setupStep == SetupStep.complete) {
          return const SizedBox.shrink();
        }

        return _buildTextInput(setupStep);
      },
    );
  }

  Widget _buildTextInput(SetupStep setupStep) {
    String hintText = _getHintForStep(setupStep);
    bool showSkipButton = setupStep == SetupStep.details;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          if (showSkipButton)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => _sendMessage(message: 'דלג'),
                    icon: const Icon(Icons.skip_next, size: 18),
                    label: const Text(ConversationScripts.skipStep),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6B73FF), Color(0xFF9DD5FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getHintForStep(SetupStep step) {
    return ConversationScripts.getSetupHint(step);
  }

  void _sendMessage({String? message}) {
    final messageText = message ?? _messageController.text.trim();
    if (messageText.isNotEmpty) {
      widget.controller.handleSetupResponse(messageText);
      _messageController.clear();
    }
  }
} 