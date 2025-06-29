import 'package:flutter/material.dart';
import 'controller/history_controller.dart';
import 'widgets/history_item_card.dart';

/// History screen showing all past conversations
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late HistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HistoryController();
    _controller.loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('היסטוריית שיחות'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.refresh,
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<List>(
            valueListenable: _controller.conversations,
            builder: (context, conversations, child) {
              if (conversations.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'אין היסטוריית שיחות',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'שיחות שהושלמו יופיעו כאן',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _controller.refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return HistoryItemCard(
                      conversation: conversation,
                      onTap: () => _viewConversation(conversation),
                      onDelete: () => _deleteConversation(conversation),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _viewConversation(conversation) {
    Navigator.pushNamed(
      context,
      '/summary',
      arguments: {'conversationId': conversation.id},
    );
  }

  void _deleteConversation(conversation) {
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
              await _controller.deleteConversation(conversation.id);
              if (mounted) {
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