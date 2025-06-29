import 'package:flutter/material.dart';
import 'controller/summary_controller.dart';
import 'widgets/transcript_preview.dart';

/// Summary screen for viewing conversation details
class SummaryScreen extends StatefulWidget {
  final String conversationId;

  const SummaryScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late SummaryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SummaryController();
    _controller.loadSummary(widget.conversationId);
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
        title: const Text('סיכום שיחה'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareTranscript,
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder(
            valueListenable: _controller.conversation,
            builder: (context, conversation, child) {
              if (conversation == null) {
                return const Center(
                  child: Text('שיחה לא נמצאה'),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Conversation summary card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'פרטי השיחה',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('משימה:', conversation.task ?? ''),
                            _buildInfoRow('התחלה:', _controller.formatDateTime(conversation.startTime)),
                            if (conversation.endTime != null)
                              _buildInfoRow('סיום:', _controller.formatDateTime(conversation.endTime!)),
                            if (conversation.duration != null)
                              _buildInfoRow('משך:', _controller.formatDuration(conversation.duration!)),
                            _buildInfoRow('סטטוס:', 'הושלמה'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Transcript section
                    Text(
                      'תמלול השיחה',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    ValueListenableBuilder<List>(
                      valueListenable: _controller.transcript,
                      builder: (context, transcript, child) {
                        return TranscriptPreview(transcript: transcript);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _shareTranscript() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('שיתוף תמלול - בקרוב')),
    );
  }
} 