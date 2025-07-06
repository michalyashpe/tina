import 'package:flutter/material.dart';
import '../model/conversation_models.dart';

/// User's message bubble
class UserMessageBubble extends StatelessWidget {
  final TranscriptLine transcriptLine;

  const UserMessageBubble({
    super.key,
    required this.transcriptLine,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16, end: 60),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),

          // Message bubble
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context),
                _buildTimestamp(context),
              ],
            )),
          
          
          // User's avatar
        ],
    ));
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
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
        color: Colors.grey.shade100,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(18),
          topEnd: Radius.circular(4),
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
          color: Colors.grey.shade800,
          fontSize: 16,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 4, end: 8),
      child: Text(
        _formatTime(transcriptLine.timestamp),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 