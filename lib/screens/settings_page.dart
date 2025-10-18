// Settings page with app configuration and support options

import 'package:flutter/material.dart';

/// Settings page with configuration and support options
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  /// Handle in-app purchase button tap (placeholder)
  void _handlePurchase(BuildContext context) {
    // TODO: Implement in-app purchase logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('In-app purchase will be implemented soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Support Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Support',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red.shade400,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Support Development',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Help us keep improving the app',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'If you find this app helpful, consider supporting us! Your contribution helps us continue developing new features and maintaining the app.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _handlePurchase(context),
                    icon: const Icon(Icons.payment),
                    label: const Text('Not implemented yet, but thanks for clicking'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  // const SizedBox(height: 12),
                  // Center(
                  //   child: Text(
                  //     '☕ \$2.99',
                  //     style: TextStyle(
                  //       color: Colors.grey.shade600,
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // About Section (optional for future)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // const Divider(height: 1),
                // ListTile(
                //   leading: const Icon(Icons.description_outlined),
                //   title: const Text('License'),
                //   trailing: Icon(
                //     Icons.chevron_right,
                //     color: Colors.grey.shade400,
                //   ),
                //   onTap: () {
                //     // TODO: Show license information
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(content: Text('License info coming soon')),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

