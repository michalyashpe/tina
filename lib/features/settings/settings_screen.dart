import 'package:flutter/material.dart';
import 'controller/settings_controller.dart';
import 'widgets/auth_status_box.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _controller.loadSettings();
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
        title: const Text('הגדרות'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Authentication status
            const AuthStatusBox(),

            const SizedBox(height: 20),

            // Settings sections
            _buildSettingsSection(
              title: 'פרופיל',
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('עריכת פרופיל'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _editProfile,
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('שינוי סיסמה'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _changePassword,
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSettingsSection(
              title: 'התראות',
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: _controller.pushNotifications,
                  builder: (context, enabled, child) {
                    return SwitchListTile(
                      secondary: const Icon(Icons.notifications),
                      title: const Text('התראות דחיפה'),
                      subtitle: const Text('התראות על שיחות חדשות'),
                      value: enabled,
                      onChanged: _controller.setPushNotifications,
                    );
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _controller.emailNotifications,
                  builder: (context, enabled, child) {
                    return SwitchListTile(
                      secondary: const Icon(Icons.email),
                      title: const Text('התראות אימייל'),
                      subtitle: const Text('סיכומי שיחות באימייל'),
                      value: enabled,
                      onChanged: _controller.setEmailNotifications,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSettingsSection(
              title: 'כללי',
              children: [
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('עזרה ותמיכה'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showHelp,
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('אודות האפליקציה'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showAbout,
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('מדיניות פרטיות'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showPrivacyPolicy,
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSettingsSection(
              title: 'חשבון',
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'התנתק',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _signOut,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('עריכת פרופיל - בקרוב')),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('שינוי סיסמה - בקרוב')),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('עזרה ותמיכה - בקרוב')),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'טינה',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 טינה - עוזרת דיגיטלית',
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('מדיניות פרטיות - בקרוב')),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('התנתק'),
        content: const Text('האם אתה בטוח שברצונך להתנתק?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _controller.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/onboarding');
              }
            },
            child: const Text('התנתק', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 