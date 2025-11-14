import 'package:flutter/material.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';

class StudentTransactionViewer extends StatefulWidget {
  final List<BorrowTransaction> transactions;
  final int initialIndex;

  const StudentTransactionViewer({
    super.key,
    required this.transactions,
    required this.initialIndex,
  });

  @override
  State<StudentTransactionViewer> createState() =>
      _StudentTransactionViewerState();
}

class _StudentTransactionViewerState extends State<StudentTransactionViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper function to calculate days left
  int _calculateDaysLeft(String deadlineDate) {
    final now = DateTime.now();
    final deadline = DateTime.parse(deadlineDate);
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  // Helper function for color
  Color _getDaysLeftColor(int daysLeft) {
    if (daysLeft < 0) return Colors.red.shade600;
    if (daysLeft == 0) return Colors.orange.shade600;
    return Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    // 4. Use PopScope to intercept back navigation
    return PopScope(
      canPop: false, // We will handle the pop manually
      onPopInvoked: (didPop) {
        if (didPop) return; // If pop already happened, do nothing
        // 5. Pop and return the *current index* to the dashboard
        Navigator.pop(context, _currentIndex);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          title: const Text('Transaction Receipt'),
          titleTextStyle: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          // The app bar's back button will now also trigger onPopInvoked
        ),
        // 6. The body is now a PageView.builder
        body: PageView.builder(
          controller: _pageController,
          itemCount: widget.transactions.length,
          onPageChanged: (index) {
            // 7. Update the current index when the user swipes
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            // Get the transaction for the current page
            final transaction = widget.transactions[index];
            final daysLeft = _calculateDaysLeft(transaction.deadlineDate);
            // Build the receipt UI for this page
            return _buildReceiptPage(context, transaction, daysLeft);
          },
        ),
      ),
    );
  }

  // 8. This is the original body of your StudentTransaction widget,
  //    now used as the builder for each page in the PageView.
  Widget _buildReceiptPage(
      BuildContext context, BorrowTransaction transaction, int daysLeft) {
    final daysLeftText = daysLeft < 0
        ? 'OVERDUE by ${daysLeft.abs()}${daysLeft.abs() == 1 ? ' day' : ' days'}'
        : daysLeft == 0
        ? 'DUE TODAY'
        : '$daysLeft days remaining';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction ID: ${transaction.transactionId}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Divider(height: 20, thickness: 1),
              _buildReceiptRow(context, 'Course:',
                  '${transaction.courseCode} - ${transaction.courseName}'),
              _buildReceiptRow(
                  context, 'Date Borrowed:', transaction.dateBorrowed),
              _buildReceiptRow(context, 'Deadline:', transaction.deadlineDate),
              _buildReceiptRow(context, 'Borrower:', transaction.borrowerName),
              const SizedBox(height: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: _getDaysLeftColor(daysLeft),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getDaysLeftColor(daysLeft)),
                ),
                child: Text(
                  daysLeftText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(height: 30, thickness: 1.5),
              Text(
                'Group Members:',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: transaction.groupMembers
                      .map((member) =>
                      Text('• $member',
                          style: Theme.of(context).textTheme.bodyLarge))
                      .toList(),
                ),
              ),
              const Divider(height: 30, thickness: 1.5),
              Text(
                'Items Borrowed (${transaction.borrowedItems.length}):',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: [
                      _buildReceiptCell('Item Name',
                          isHeader: true, columnAlignment: TextAlign.left),
                      _buildReceiptCell('Qty',
                          isHeader: true, columnAlignment: TextAlign.center),
                    ],
                  ),
                  ...transaction.borrowedItems.map((item) {
                    return TableRow(
                      children: [
                        _buildReceiptCell(item['name'],
                            columnAlignment: TextAlign.left),
                        _buildReceiptCell('${item['quantity']}x',
                            columnAlignment: TextAlign.center),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper functions from original widget
  Widget _buildReceiptRow(BuildContext context, String label, String value,
      {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: isHeader
                  ? Theme.of(context).textTheme.titleMedium
                  : Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: isHeader
                  ? Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900)
                  : Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCell(String text,
      {bool isHeader = false, required TextAlign columnAlignment}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text,
        textAlign: columnAlignment,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}