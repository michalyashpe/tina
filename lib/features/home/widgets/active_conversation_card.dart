import 'package:flutter/material.dart';
import '../../conversation/model/conversation_models.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/models/conversation_status.dart';

/// Card displaying active conversation details
class ActiveConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;

  const ActiveConversationCard({
    super.key,
    required this.conversation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Icon(
                    conversation.status.icon,
                    color: conversation.status.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'שיחה פעילה',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: conversation.status.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    TimeUtils.formatTime(conversation.startTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Task description
              Text(
                conversation.task,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Duration and action
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'משך: ${TimeUtils.formatDuration(DateTime.now().difference(conversation.startTime))}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('המשך'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 