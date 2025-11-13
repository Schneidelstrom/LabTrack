import 'package:flutter/material.dart';
import 'package:labtrack/student/screens/borrow.dart';
import 'package:labtrack/student/screens/report.dart';
import 'package:labtrack/student/reusables.dart';
import 'package:labtrack/student/screens/waitlist.dart';
import 'package:labtrack/student/screens/return.dart';
import 'package:labtrack/student/screens/request.dart';
import 'package:labtrack/student/screens/reported.dart';

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
      'courseCode': 'BIO-101',
      'itemCount': 10,
      'daysLeft': -1,
    },
    {
      'courseCode': 'CHEM-103',
      'itemCount': 13,
      'daysLeft': 0,
    },
    {
      'courseCode': 'ECO-97',
      'itemCount': 7,
      'daysLeft': 15,
    },
  ];

  late final bool _hasPenalty;

  @override
  void initState() {
    super.initState();
    _hasPenalty = _borrowedItems.any((item) => item['daysLeft']! < 0);
  }

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
    final currentItem = _borrowedItems[_currentBorrowedItemIndex];
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildAppDrawer(context, selectedIndex: 0),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Dashboard'),
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
        actions: [
          buildProfilePopupMenuButton(context),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (_hasPenalty)
                  TextButton.icon(
                    onPressed: () => print("Pressed on Penalties")
                    /* TODO: Navigate to Penalties Screen */
                    ,
                    icon: Icon(
                      Icons.warning_amber_rounded,
                      size: 24.0,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    label: Text(
                      'Penalty',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context).colorScheme.error,
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
                    courseCode: currentItem['courseCode']!,
                    itemCount: currentItem['itemCount'],
                    daysLeft: currentItem['daysLeft'] as int,
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
                    {'name': 'BIO-1', 'status': '#2'},
                    {'name': 'ENVI-1', 'status': 'PICK-UP'},
                  ],
                ),
                _buildSummaryCard(
                  context: context,
                  title: 'Returns',
                  items: const [
                    {'name': 'BIO-2', 'status': 'COMPLETE'},
                    {'name': 'PHYSICS-94', 'status': 'PARTIAL'},
                  ],
                ),
                _buildSummaryCard(
                  context: context,
                  title: 'Requests',
                  items: const [
                    {'name': 'PHYSICS-105', 'status': '13x'},
                    {'name': 'ECO-34', 'status': '16x'},
                  ],
                ),
                _buildSummaryCard(
                  context: context,
                  title: 'Reports',
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
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentBorrow()));
                    },
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
                    onPressed: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentReport()))
                    },
                    icon: const Icon(Icons.report_problem_outlined),
                    label: const Text('Report'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(int daysLeft, {required bool isBackground}) {
    if (daysLeft < 0) return isBackground ? Colors.red.shade50 : Colors.red.shade600;
    else if (daysLeft == 0) return isBackground ? Colors.orange.shade50 : Colors.orange.shade600;
    return isBackground ? Colors.white : Colors.transparent;
  }

  Widget _buildCurrentlyBorrowedCard({required BuildContext context, required String courseCode, required int itemCount, required int daysLeft}) {
    final Color borderColor = _getCardColor(daysLeft, isBackground: false);
    final Color backgroundColor = _getCardColor(daysLeft, isBackground: true);
    final double borderWidth = (daysLeft <= 0) ? 2.0 : 0.0;
    final Color daysLeftTextColor = (daysLeft < 0) ? Colors.red.shade600 : (daysLeft == 0 ? Colors.orange.shade600 : Colors.blue.shade900);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      shadowColor: Theme.of(context).shadowColor,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          onTap: () {
            print('Borrowed Item Card for $courseCode clicked!');
            /* TODO: Navigate to the details screen for this item */
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Text(
                  courseCode,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: daysLeftTextColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$daysLeft days left',
                      style: Theme.of(context).textTheme.bodyMedium
                    ),
                    Text(
                      '$itemCount items',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${_currentBorrowedItemIndex + 1} of ${_borrowedItems.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
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
            if (title == 'Waitlist') Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentWaitlist()));
            else if (title == 'Returns') Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentReturn()));
            else if (title == 'Requests') Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentRequest()));
            else if (title == 'Reports') Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentReported()));
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
      return Colors.green.shade700;
    } else if (status.contains('#')) {
      return Colors.orange.shade800;
    }
    return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
  }
}