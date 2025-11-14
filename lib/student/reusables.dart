import 'package:flutter/material.dart';

Drawer buildAppDrawer(BuildContext context, {required int selectedIndex}) {
  const Color primaryBlue = Color(0xFF0D47A1);
  const Color placeholderGrey = Color(0xFF9E9E9E);

  Widget buildUnderDevelopmentItem({
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Opacity(
        opacity: 0.6,
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: placeholderGrey,
              size: 24,
            ),
            const SizedBox(width: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: placeholderGrey,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Feature Under Development',
                  style: TextStyle(
                    color: placeholderGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            color: primaryBlue,
          ),
          child: Text(
            'Menu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildUnderDevelopmentItem(
          icon: Icons.info,
          title: 'About',
        ),
      ],
    ),
  );
}

PopupMenuButton<String> buildProfilePopupMenuButton(BuildContext context) {
  void handleSelection(String result) {
    switch (result) {
      case 'Profile':
        print("Under Development");
        break;
      case 'Settings':
        print("Under Development");
        break;
      case 'Logout':
        _showLogoutConfirmationDialog(context);
        break;
    }
  }

  return PopupMenuButton<String>(
    icon: const Icon(Icons.person_outline),
    offset: const Offset(0, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 8,
    onSelected: handleSelection,
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      const PopupMenuItem<String>(
        value: 'Profile',
        child: Text('Profile'),
      ),
      const PopupMenuItem<String>(
        value: 'Settings',
        child: Text('Settings'),
      ),
      const PopupMenuItem<String>(
        value: 'Logout',
        child: Text('Logout'),
      ),
    ],
  );
}

void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Are you sure you\nwant to log out?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 6),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login', (Route<dynamic> route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}