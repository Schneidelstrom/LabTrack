import 'package:flutter/material.dart';

/// Standardized Drawer widget for the application menu for consistent set of navigation options
class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildUnderDevelopmentItem(
            icon: Icons.info_outline,
            title: 'About',
          ),
          _buildUnderDevelopmentItem(
            icon: Icons.help_outline,
            title: 'Help & Feedback',
          ),
        ],
      ),
    );
  }

  Widget _buildUnderDevelopmentItem({required IconData icon, required String title,}) {
    const Color placeholderGrey = Colors.grey;

    return Opacity(
      opacity: 0.6,
      child: ListTile(
        leading: Icon(
          icon,
          color: placeholderGrey,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: placeholderGrey,
            fontSize: 16,
          ),
        ),
        subtitle: const Text(
          'Feature Under Development',
          style: TextStyle(
            color: placeholderGrey,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        onTap: null,
      ),
    );
  }
}