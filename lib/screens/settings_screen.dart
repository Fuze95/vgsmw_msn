import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Theme Settings
          Card(
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark/light theme'),
                  value: themeProvider.isDarkMode,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // App Info
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('App Version'),
                  trailing: Text('1.0.0'),
                ),
                const Divider(),
                ListTile(
                  title: const Text('About'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'MySimpleNote',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '©2024 V.G.S.M. Wijerathna (K2421736)',
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'A simple note-taking app with features like labels, '
                              'image attachments, and dark mode support.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Database Management
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Export Data'),
                  subtitle: const Text('Backup your notes'),
                  trailing: const Icon(Icons.upload),
                  onTap: () {
                    // Implement export functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export feature coming soon...'),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Import Data'),
                  subtitle: const Text('Restore your notes from backup'),
                  trailing: const Icon(Icons.download),
                  onTap: () {
                    // Implement import functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Import feature coming soon...'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}