import 'package:flutter/material.dart';

/// App theme configuration
class AppTheme {
  static const Color primaryColor = Color(0xFF6B73FF);
  static const Color secondaryColor = Color(0xFF9DD5FF);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color surfaceColor = Color(0xFFF8F9FA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      
      // RTL Configuration
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        // Ensure proper RTL icon positioning
        actionsIconTheme: IconThemeData(color: Colors.black87),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

/// Custom app icons and status indicators
class AppIcons {
  static const IconData tina = Icons.assistant;
  static const IconData conversation = Icons.chat_bubble_outline;
  static const IconData history = Icons.history;
  static const IconData settings = Icons.settings_outlined;
  static const IconData microphone = Icons.mic;
  static const IconData microphoneOff = Icons.mic_off;
  static const IconData phone = Icons.phone;
  static const IconData phoneEnd = Icons.call_end;
}

/// Status indicator widgets
class StatusIndicator extends StatelessWidget {
  final ConversationStatus status;
  final double size;

  const StatusIndicator({
    super.key,
    required this.status,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ConversationStatus.active:
        return Icon(
          Icons.radio_button_checked,
          color: AppTheme.successColor,
          size: size,
        );
      case ConversationStatus.completed:
        return Icon(
          Icons.check_circle,
          color: AppTheme.successColor,
          size: size,
        );
      case ConversationStatus.cancelled:
        return Icon(
          Icons.cancel,
          color: AppTheme.warningColor,
          size: size,
        );
      case ConversationStatus.error:
        return Icon(
          Icons.error,
          color: AppTheme.errorColor,
          size: size,
        );
    }
  }
}

enum ConversationStatus {
  active,
  completed,
  cancelled,
  error,
} 