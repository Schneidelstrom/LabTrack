import 'package:flutter/material.dart';

/// Standardized AppBar for use across the application for consistent look and feel for the title, actions, and style
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final VoidCallback? onPenaltyPressed;

  const CommonAppBar({
    super.key,
    required this.title,
    this.leading,
    this.onPenaltyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue.shade900,
      title: Text(title),
      titleTextStyle: const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      shadowColor: Colors.black,
      leading: leading,
      actions: [
        _buildProfilePopupMenuButton(context),
      ],
    );
  }

  /// The preferred size for AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Builds profile popup menu button
  Widget _buildProfilePopupMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person_outline),
      onSelected: (value) {
        // This should call a controller method
        if (value == 'Logout') Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'Profile', child: Text('Profile')),
        const PopupMenuItem<String>(value: 'Settings', child: Text('Settings')),
        const PopupMenuItem<String>(value: 'Logout', child: Text('Logout')),
      ],
    );
  }
}