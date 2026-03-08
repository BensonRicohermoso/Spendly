import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (auth.user != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(auth.user!.email),
              subtitle: const Text('Account'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Privacy Policy'),
            onTap: () {
              // TODO: Navigate to privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Terms of Service'),
            onTap: () {
              // TODO: Navigate to terms of service
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text('Sign Out'),
            onTap: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            subtitle: const Text('This action cannot be undone'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account?'),
                  content: const Text(
                    'This will permanently delete your account and all data. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final deleted = await auth.deleteAccount();
                if (deleted && context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
