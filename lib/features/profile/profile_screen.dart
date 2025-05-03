import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/profile_provider.dart';
import '../../core/services/api_inspector.dart';
import '../../core/config/app_config.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, provider),
                const SizedBox(height: 24),
                _buildSettingSection(
                  'Account Settings',
                  [
                    SettingItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () => _showEditProfileDialog(context, provider),
                    ),
                    SettingItem(
                      icon: Icons.email_outlined,
                      title: 'Change Email',
                      onTap: () => _showChangeEmailDialog(context, provider),
                    ),
                    SettingItem(
                      icon: Icons.password_outlined,
                      title: 'Change Password',
                      onTap: () => _showDialog(context, 'Change Password', 'This feature will be available soon.'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSettingSection(
                  'App Preferences',
                  [
                    SettingItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      trailing: Switch(
                        value: provider.isDarkMode,
                        onChanged: (value) => provider.toggleDarkMode(),
                      ),
                      onTap: () => provider.toggleDarkMode(),
                    ),
                    SettingItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () => _showDialog(context, 'Notifications', 'Notification settings will be available soon.'),
                    ),
                    SettingItem(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      onTap: () => _showDialog(context, 'Language', 'Language settings will be available soon.'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSettingSection(
                  'Data Management',
                  [
                    SettingItem(
                      icon: Icons.backup_outlined,
                      title: 'Backup Data',
                      onTap: () => _showDialog(context, 'Backup Data', 'This feature will be available soon.'),
                    ),
                    SettingItem(
                      icon: Icons.restore_outlined,
                      title: 'Restore Data',
                      onTap: () => _showDialog(context, 'Restore Data', 'This feature will be available soon.'),
                    ),
                    SettingItem(
                      icon: Icons.delete_outline,
                      title: 'Delete All Data',
                      onTap: () => _showDeleteDataConfirmation(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSettingSection(
                  'Support & Feedback',
                  [
                    SettingItem(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      onTap: () => _showDialog(context, 'Help Center', 'Help documentation will be available soon.'),
                    ),
                    SettingItem(
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      onTap: () => _showDialog(context, 'Send Feedback', 'Feedback submission will be available soon.'),
                    ),
                    SettingItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _showDialog(context, 'Privacy Policy', 'Privacy policy will be available soon.'),
                    ),
                  ],
                ),
                // Only show the development section in debug/profile builds
                if (AppConfig.enableDebugTools) ...[
                  const SizedBox(height: 16),
                  _buildSettingSection(
                    'Development',
                    [
                      SettingItem(
                        icon: Icons.api_outlined,
                        title: 'API Inspector',
                        subtitle: 'View API call details',
                        onTap: () => ApiInspector().showInspector(),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                _buildLogoutButton(context, provider),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Receipt AI Scanner v1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileProvider provider) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(provider.avatar),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showEditProfileDialog(context, provider),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection(String title, List<SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Card(
          elevation: 0,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                trailing: item.trailing,
                onTap: item.onTap,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, ProfileProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (shouldLogout == true && context.mounted) {
            await provider.logout();
            // In a real app, this would navigate to login screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out successfully!')),
            );
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileProvider provider) {
    final nameController = TextEditingController(text: provider.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.updateProfile(name: nameController.text.trim());
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context, ProfileProvider provider) {
    final emailController = TextEditingController(text: provider.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'New Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.updateProfile(email: emailController.text.trim());
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email updated successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This will permanently delete all your receipts and history. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data deleted successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class SettingItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  SettingItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });
}
