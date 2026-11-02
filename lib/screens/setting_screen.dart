
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.person, size: 45),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Expense Tracker',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 25),
          const ListTile(
            leading: Icon(Icons.currency_rupee),
            title: Text('Currency'),
            subtitle: Text('Indian Rupee (₹)'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About App'),
            subtitle: Text('Personal Expense Tracker'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Developed with Flutter'),
          ),
        ],
      ),
    );
  }
}
