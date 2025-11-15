// lib/widgets/app_bar.dart
import 'package:flutter/material.dart';

/// A standardized AppBar for use across the application.
/// It provides a consistent look and feel for the title, actions, and style.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final bool showPenaltyButton;
  final VoidCallback? onPenaltyPressed;

  const CommonAppBar({
    super.key,
    required this.title,
    this.leading,
    this.showPenaltyButton = false,
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
        if (showPenaltyButton)
          TextButton.icon(
            onPressed: onPenaltyPressed,
            icon: Icon(Icons.warning_amber_rounded, color: Colors.yellow.shade700),
            label: Text('Penalty', style: TextStyle(color: Colors.yellow.shade700, fontWeight: FontWeight.bold)),
          ),
        _buildProfilePopupMenuButton(context),
      ],
    );
  }

  /// The preferred size for the AppBar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Builds the profile popup menu button.
  /// Logic is kept here as it's specific to this AppBar's design.
  Widget _buildProfilePopupMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person_outline),
      onSelected: (value) {
        if (value == 'Logout') {
// In a real app, this would call a controller method.
// For now, it navigates directly.
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'Profile', child: Text('Profile')),
        const PopupMenuItem<String>(value: 'Settings', child: Text('Settings')),
        const PopupMenuItem<String>(value: 'Logout', child: Text('Logout')),
      ],
    );
  }
}