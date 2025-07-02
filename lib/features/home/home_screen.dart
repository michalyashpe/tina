import 'package:flutter/material.dart';
import 'controller/home_controller.dart';
import 'widgets/active_conversation_card.dart';
import 'widgets/unfinished_conversations_list.dart';
import 'widgets/completed_conversations_list.dart';
import '../../app/router.dart';
import '../../core/utils/time_utils.dart';

/// Home screen with conversation overview
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late HomeController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _tabController = TabController(length: 2, vsync: this);
    _controller.loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TimeUtils.getGreeting()),
              const Text(
                'איך אפשר לעזור לך היום?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
            ),
          ],
        ),
        body: ValueListenableBuilder<bool>(
          valueListenable: _controller.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upper half - Active conversation and new call button
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5 - kToolbarHeight - MediaQuery.of(context).padding.top - 32,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Active conversation card
                        ValueListenableBuilder(
                          valueListenable: _controller.activeConversation,
                          builder: (context, activeConversation, child) {
                            if (activeConversation != null) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: ActiveConversationCard(
                                  conversation: activeConversation,
                                  onTap: () => Navigator.pushNamed(context, AppRouter.conversation),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),

                        // New conversation section with Tina image
                        if (_controller.activeConversation.value == null) 
                          Column(
                            children: [
                              // Tina calling image - focused on face and hands
                              Container(
                                width: 150,
                                height: 150,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                  borderRadius: BorderRadius.circular(75),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(75),
                                  child: Image.asset(
                                    'assets/images/tina/calling you.png',
                                    fit: BoxFit.cover,
                                    alignment: const Alignment(0, -0.8), // Focus on upper part (face/hands)
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // New conversation button - centered with call icon
                              Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: ElevatedButton.icon(
                                    onPressed: () => Navigator.pushNamed(context, AppRouter.conversation),
                                    icon: const Icon(Icons.call),
                                    label: const Text('התחל שיחה חדשה'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Lower half - Conversations tabs
                  Expanded(
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'לא הושלמו'),
                            Tab(text: 'הושלמו'),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              UnfinishedConversationsList(controller: _controller),
                              CompletedConversationsList(controller: _controller),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 