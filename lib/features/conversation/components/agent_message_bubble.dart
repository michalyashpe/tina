import 'package:flutter/material.dart';
import '../model/conversation_models.dart';

/// Agent's message bubble
class AgentMessageBubble extends StatelessWidget {
  final TranscriptLine transcriptLine;

  const AgentMessageBubble({
    super.key,
    required this.transcriptLine,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16, end: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agent's avatar
          _buildAvatar(),
          
          const SizedBox(width: 12),
          
          // Message bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context),
                _buildTimestamp(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.green.shade400,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(
          color: Colors.green.shade200,
          width: 1,
        ),
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(4),
          topEnd: Radius.circular(18),
          bottomStart: Radius.circular(18),
          bottomEnd: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Text(
        transcriptLine.content,
        style: TextStyle(
          color: Colors.green.shade800,
          fontSize: 16,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 4, end: 8),
      child: Row(
        children: [
          Icon(
            Icons.support_agent,
            size: 12,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 4),
          Text(
            'נציג • ${_formatTime(transcriptLine.timestamp)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 