import 'package:flutter/material.dart';
import '../../../core/utils/time_utils.dart';

/// Widget for displaying conversation transcript
class TranscriptPreview extends StatelessWidget {
  final List transcript;

  const TranscriptPreview({
    super.key,
    required this.transcript,
  });

  @override
  Widget build(BuildContext context) {
    if (transcript.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'אין תמלול זמין לשיחה זו',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: transcript
              .map((item) => _buildTranscriptItem(context, item))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTranscriptItem(BuildContext context, Map<String, dynamic> item) {
    final sender = item['sender'] as String;
    final content = item['content'] as String;
    final time = item['time'] as DateTime;

    Color senderColor;
    String senderName;
    IconData senderIcon;

    switch (sender) {
      case 'tina':
        senderColor = Colors.blue;
        senderName = 'טינה';
        senderIcon = Icons.assistant;
        break;
      case 'agent':
        senderColor = Colors.green;
        senderName = 'נציג';
        senderIcon = Icons.person;
        break;
      case 'user':
        senderColor = Colors.grey;
        senderName = 'משתמש';
        senderIcon = Icons.person_outline;
        break;
      default:
        senderColor = Colors.grey;
        senderName = 'לא ידוע';
        senderIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: senderColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              senderIcon,
              size: 16,
              color: senderColor,
            ),
          ),

          const SizedBox(width: 12),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender name and time
                Row(
                  children: [
                    Text(
                      senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: senderColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      TimeUtils.formatTime(time),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Message content
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 