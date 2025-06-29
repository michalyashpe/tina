import 'package:flutter/material.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/home/home_screen.dart';
import '../features/conversation/conversation_screen.dart';
import '../features/history/history_screen.dart';
import '../features/summary/summary_screen.dart';
import '../features/settings/settings_screen.dart';

/// Navigation route definitions
class AppRouter {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String conversation = '/conversation';
  static const String history = '/history';
  static const String summary = '/summary';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute( RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case conversation:
        return MaterialPageRoute(
          builder: (_) => const ConversationScreen(),
          settings: settings,
        );
      case history:
        return MaterialPageRoute(
          builder: (_) => const HistoryScreen(),
          settings: settings,
        );
      case summary:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SummaryScreen(
            conversationId: args?['conversationId'] as String? ?? '',
          ),
          settings: settings,
        );
      case 'settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }
} 