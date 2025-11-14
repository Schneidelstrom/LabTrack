// lib/student/screens/dashboard.dart

import 'package:flutter/material.dart';
import 'package:labtrack/student/screens/borrow.dart';
import 'package:labtrack/student/screens/report.dart';
import 'package:labtrack/student/reusables.dart';
import 'package:labtrack/student/screens/waitlist.dart';
import 'package:labtrack/student/screens/return.dart';
import 'package:labtrack/student/screens/request.dart';
import 'package:labtrack/student/screens/reported.dart';
import 'package:labtrack/student/screens/penalty.dart';
import 'package:labtrack/student/screens/borrowed.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentBorrowedItemIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<BorrowTransaction> _borrowedItems = const [
    const BorrowTransaction(
      transactionId: 'TXN-00123',
      courseCode: 'BIO-101',
      courseName: 'General Biology',
      borrowerName: 'John Doe',
      dateBorrowed: '2025-11-10',
      deadlineDate: '2025-11-12',
      groupMembers: ['John Doe', 'Jane Smith', 'Peter Jones'],
      borrowedItems: const [
        const {'name': 'Microscope', 'quantity': 5},
        const {'name': 'Slide Set', 'quantity': 5},
      ],
    ),
    const BorrowTransaction(
      transactionId: 'TXN-00124',
      courseCode: 'CHEM-103',
      courseName: 'Organic Chemistry',
      borrowerName: 'Alice Johnson',
      dateBorrowed: '2025-11-01',
      deadlineDate: '2025-11-15',
      groupMembers: const ['Alice Johnson', 'Bob Brown'],
      borrowedItems: const [
        const {'name': 'Test Tube Rack', 'quantity': 1},
        const {'name': 'Safety Goggles', 'quantity': 12},
      ],
    ),
    const BorrowTransaction(
      transactionId: 'TXN-00125',
      courseCode: 'ECO-97',
      courseName: 'Physics Lab',
      borrowerName: 'Emma Wilson',
      dateBorrowed: '2025-11-10',
      deadlineDate: '2025-11-28',
      groupMembers: const ['Emma Wilson', 'Mamma Mia', 'Dadda', 'asdfwfasgfighasjdf', 'afqwefafsdf'],
      borrowedItems: const [
        const {'name': 'Digital Multimeter', 'quantity': 7},
      ],
    ),
  ];

  late final bool _hasPenalty;

  int _calculateDaysLeft(String deadlineDate) {
    final now = DateTime.now();
    final deadline = DateTime.parse(deadlineDate);
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  @override
  void initState() {
    super.initState();
    _hasPenalty = _borrowedItems.any((item) => _calculateDaysLeft(item.deadlineDate) < 0);
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
    final currentTransaction = _borrowedItems[_currentBorrowedItemIndex];
    final int daysLeft = _calculateDaysLeft(currentTransaction.deadlineDate);

    final int itemCount = currentTransaction.borrowedItems.length;

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
                    onPressed: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentPenalty()))
                    },
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
                    transaction: currentTransaction,
                    itemCount: itemCount,
                    daysLeft: daysLeft,
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
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentBorrow()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(color: Colors.black, width: 2.0)
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      foregroundColor: Colors.black,
                      elevation: 5,
                    ),
                    child: const Text(
                      'Borrow',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentReport()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(color: Colors.black, width: 2.0)
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      foregroundColor: Colors.black,
                      elevation: 5,
                    ),
                    child: const Text(
                      'Report',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      ),
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

  Widget _buildCurrentlyBorrowedCard({required BuildContext context, required BorrowTransaction transaction, required int itemCount, required int daysLeft}) {
    final Color borderColor = _getCardColor(daysLeft, isBackground: false);
    final Color backgroundColor = _getCardColor(daysLeft, isBackground: true);
    final Color effectiveBorderColor = (daysLeft > 0) ? Colors.blue.shade800 : borderColor;
    final Color daysLeftTextColor = (daysLeft < 0) ? Colors.red.shade600 : (daysLeft == 0 ? Colors.orange.shade600 : Colors.blue.shade900);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: effectiveBorderColor,
          width: 2.0,
        ),
      ),
      shadowColor: Theme.of(context).shadowColor,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          // =================== KEY CHANGE ===================
          // 1. Make the onTap function async
          onTap: () async {
            // 2. Use await to wait for the Navigator.push to complete
            final newIndex = await Navigator.push(
              context,
              MaterialPageRoute(
                // 3. Use the new StudentTransactionViewer
                builder: (context) => StudentTransactionViewer(transactions: _borrowedItems, initialIndex: _currentBorrowedItemIndex),
              ),
            );

            // 6. When the screen is popped, it returns the newIndex
            //    Check if it's not null and is an integer
            if (newIndex != null && newIndex is int) {
              // 7. If the index is different, update the state to sync the dashboard
              if (newIndex != _currentBorrowedItemIndex) {
                setState(() {
                  _currentBorrowedItemIndex = newIndex;
                });
              }
            }
          },
          // ================= END KEY CHANGE =================
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Text(
                  transaction.courseCode,
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
                      '$itemCount${itemCount == 1 ? ' item' : ' items'}',
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
    final upperStatus = status.toUpperCase();

    if (upperStatus == 'PICK-UP' || upperStatus == 'COMPLETE') {
      return Colors.green.shade700;
    } else if (upperStatus == 'PARTIAL') {
      return Colors.orange.shade800;
    } else if (upperStatus.contains('#')) {
      return Colors.red.shade800;
    }
    return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
  }
}