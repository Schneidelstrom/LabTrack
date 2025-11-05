import 'package:flutter/material.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentBorrowedItemIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _borrowedItems = const [
    {
      'itemName': 'Microscope',
      'daysLeft': 9,
      'icon': Icons.biotech_rounded
    },
    {
      'itemName': 'Beaker Set',
      'daysLeft': 12,
      'icon': Icons.science_rounded
    },
    {
      'itemName': 'pH Meter',
      'daysLeft': 15,
      'icon': Icons.thermostat_rounded
    },
  ];

  void _navigateBorrowedItems(bool isNext) {
    setState(() {
      if (isNext) {
        _currentBorrowedItemIndex =
            (_currentBorrowedItemIndex + 1) % _borrowedItems.length;
      } else {
        int newIndex = _currentBorrowedItemIndex - 1;
        if (newIndex < 0) {
          _currentBorrowedItemIndex = _borrowedItems.length - 1;
        } else {
          _currentBorrowedItemIndex = newIndex;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final currentItem = _borrowedItems[_currentBorrowedItemIndex];

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
              ),
              child: const Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart, color: Color(0xFF0D47A1)),
              title: const Text('New Borrow Request'),
              onTap: () => print("Tapped on New Borrow Request")
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF0D47A1)),
              title: const Text('My History & Transactions'),
              onTap: () => print("Tapped on My History & Transactions")
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () => print("Tapped on My Profile")
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Application Settings'),
              onTap: () => print("Tapped on My Profile")
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.grey),
              title: const Text('Logout'),
              onTap: () => _showLogoutConfirmationDialog(context),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Dashboard'),
        titleTextStyle: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        shadowColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          iconSize: 30,
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            onSelected: (String result){
              switch (result) {
                case 'Profile':
                /* TODO: Navigate to Profile Screen */
                  break;
                case 'Settings':
                /* TODO: Navigate to Settings Screen */
                  break;
                case 'Logout':
                  _showLogoutConfirmationDialog(context);
                  break;
              }
            },
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome, Student!',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => print("Pressed on Penalties")
                    /* TODO: Navigate to Penalties Screen */
                  ,
                  icon: Icon(
                    Icons.warning_amber_rounded,
                    size: 24.0,
                    color: colorScheme.error,
                  ),
                  label: Text(
                    '2 Penalties',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  iconSize: 90.0,
                  onPressed: () => _navigateBorrowedItems(false),
                ),
                Expanded(
                  child: _buildCurrentlyBorrowedCard(
                    context: context,
                    itemName: currentItem['itemName']!,
                    daysLeft: currentItem['daysLeft'] as int,
                    itemIcon: currentItem['icon'] as IconData,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  iconSize: 90.0,
                  onPressed: () => _navigateBorrowedItems(true),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildSummaryCard(
                  context: context,
                  title: 'Waitlist',
                  items: const [
                    {'name': 'Volumetric Flask', 'status': '#2'},
                    {'name': 'Graduated Cylinder', 'status': 'PICK-UP'},
                  ],
                ),
                _buildSummaryCard(
                  context: context,
                  title: 'Recently Returned',
                  items: const [
                    {'name': 'Beaker', 'status': '5x'},
                    {'name': 'pH Meter', 'status': '1x'},
                  ],
                ),
                _buildSummaryCard(
                  context: context,
                  title: 'Pending Borrow',
                  items: const [
                    {'name': 'Petri Dish', 'status': '5x'},
                    {'name': 'Thermometer', 'status': '2x'},
                  ],
                ),
                _buildSummaryCard(
                  context: context,
                  title: 'Reported',
                  items: const [
                    {'name': 'Bunsen Burner', 'status': '1x'},
                    {'name': 'Thermometer', 'status': '2x'},
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => print("Pressed on Borrow")
                      /* TODO: Navigate to Borrow Screen */
                    ,
                    icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF0D47A1)),
                    label: const Text('Borrow', style: TextStyle(color: Color(0xFF0D47A1))),

                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => print("Pressed on Report")
                      /* TODO: Navigate to Report Screen */
                    ,
                    icon: const Icon(Icons.report_problem_outlined),
                    label: const Text('Report'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, color: Color(0xFF0D47A1)),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined, color: Color(0xFF0D47A1)),
            label: 'Transactions',
          )
        ],
      ),
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

  Widget _buildCurrentlyBorrowedCard({
    required BuildContext context,
    required String itemName,
    required int daysLeft,
    required IconData itemIcon,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      shadowColor: Theme.of(context).shadowColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              itemIcon,
              size: 60,
              color: const Color(0xFF0D47A1),
            ),
            const SizedBox(height: 16),
            Text(
              itemName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$daysLeft days left',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              '${_currentBorrowedItemIndex + 1} of ${_borrowedItems.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required List<Map<String, String>> items,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      shadowColor: Theme.of(context).shadowColor,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          onTap: () {
            print('Tapped on the $title summary card!');
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: items.isEmpty ? Center(
                    child: Text(
                      'Nothing to show',
                      style: textTheme.bodySmall,
                    ),
                  ):ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['name']!, style: textTheme.bodyMedium),
                            Text(
                              item['status']!,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(
                                  item['status']!,
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, BuildContext context) {
    if (status.toUpperCase() == 'PICK-UP') {
      return Colors.amber.shade700;
    } else if (status.contains('#')) {
      return Theme.of(context).colorScheme.error;
    }
    return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
  }
}