import 'package:flutter/material.dart';
import '../controller/home_controller.dart';
import '../../conversation/model/conversation_models.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/models/conversation_status.dart';

/// List of unfinished conversations
class UnfinishedConversationsList extends StatelessWidget {
  final HomeController controller;

  const UnfinishedConversationsList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Conversation>>(
      valueListenable: controller.unfinishedConversations,
      builder: (context, conversations, child) {
        if (conversations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'כל השיחות הושלמו!',
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
                  conversation.status.icon,
                  color: conversation.status.color,
                ),
                title: Text(
                  conversation.task,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${conversation.status.displayName} • ${TimeUtils.getRelativeTime(conversation.startTime)}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, value, conversation),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'continue',
                      child: ListTile(
                        leading: Icon(Icons.play_arrow),
                        title: Text('המשך'),
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
                onTap: () => _continueConversation(context, conversation),
              ),
            );
          },
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action, Conversation conversation) {
    switch (action) {
      case 'continue':
        _continueConversation(context, conversation);
        break;
      case 'delete':
        _deleteConversation(context, conversation);
        break;
    }
  }

  void _continueConversation(BuildContext context, Conversation conversation) {
    Navigator.pushNamed(context, '/conversation');
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