import 'package:flutter/material.dart';
import 'package:labtrack/student/reusables.dart';

class StudentTransactions extends StatefulWidget {
  const StudentTransactions({super.key});

  State<StudentTransactions> createState() => _StudentTransactionsState();
}

class _StudentTransactionsState extends State<StudentTransactions> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildAppDrawer(context, selectedIndex: 0),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Transaction History'),
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _TransactionCard(
            courseCode: 'CHEM-89',
            status: 'COMPLETE',
            date: '09-08-2025',
            type: 'Return',
          ),
          SizedBox(height: 16),
          _TransactionCard(
            courseCode: 'CHEM-87',
            status: '13x',
            date: '09-01-2025',
            type: 'Borrow',
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String courseCode;
  final String status;
  final String date;
  final String type;

  const _TransactionCard({
    required this.courseCode,
    required this.status,
    required this.date,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$status   $date',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Text(
              type,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}