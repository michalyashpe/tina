import 'package:flutter/material.dart';
import '../controller/home_controller.dart';
import '../../conversation/model/conversation_models.dart';
import '../../../core/utils/time_utils.dart';
import '../../../app/router.dart';

/// List of completed conversations
class CompletedConversationsList extends StatelessWidget {
  final HomeController controller;

  const CompletedConversationsList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Conversation>>(
      valueListenable: controller.completedConversations,
      builder: (context, conversations, child) {
        if (conversations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'אין שיחות שהושלמו',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text(
                  conversation.task,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TimeUtils.getRelativeTime(conversation.startTime)),
                    if (conversation.duration != null)
                      Text(
                        'משך: ${TimeUtils.formatDuration(conversation.duration!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, value, conversation),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.visibility),
                        title: Text('צפה בסיכום'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('מחק', style: TextStyle(color: Colors.red)),
                        dense: true,
                      ),
                    ),
                  ],
                ),
                onTap: () => _viewSummary(context, conversation),
              ),
            );
          },
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action, Conversation conversation) {
    switch (action) {
      case 'view':
        _viewSummary(context, conversation);
        break;
      case 'delete':
        _deleteConversation(context, conversation);
        break;
    }
  }

  void _viewSummary(BuildContext context, Conversation conversation) {
    Navigator.pushNamed(
      context,
      AppRouter.summary,
      arguments: {'conversationId': conversation.id},
    );
  }

  void _deleteConversation(BuildContext context, Conversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחק שיחה'),
        content: const Text('האם אתה בטוח שברצונך למחוק את השיחה?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteConversation(conversation.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('השיחה נמחקה')),
                );
              }
            },
            child: const Text('מחק', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 