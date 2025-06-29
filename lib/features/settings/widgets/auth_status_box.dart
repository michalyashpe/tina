import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

/// Widget displaying current authentication status
class AuthStatusBox extends StatelessWidget {
  const AuthStatusBox({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService(),
      builder: (context, child) {
        final authService = AuthService();
        final user = authService.currentUser;

        if (user == null) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'לא מחובר',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'יש להתחבר כדי לשמור שיחות',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to login
                    },
                    child: const Text('התחבר'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // User avatar
                CircleAvatar(
                  backgroundColor: Colors.green.shade200,
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        textDirection: TextDirection.ltr, // Email is typically LTR
                      ),
                    ],
                  ),
                ),
                
                // Status indicator
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 