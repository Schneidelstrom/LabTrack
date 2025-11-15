// lib/views/transaction_viewer_view.dart
import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/transaction_receipt.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';
import 'package:labtrack/student/models/cart_item.dart';
/// The UI for viewing a paged list of transaction receipts.
/// This view allows the user to swipe between different transactions.
/// It works with a [TransactionViewerController] to handle data logic.
class TransactionViewerView extends StatefulWidget {
  final List<BorrowTransaction> transactions;
  final int initialIndex;
  const TransactionViewerView({
    super.key,
    required this.transactions,
    required this.initialIndex,
  });
  @override
  State<TransactionViewerView> createState() => _TransactionViewerViewState();
}
class _TransactionViewerViewState extends State<TransactionViewerView> {
// The PageController manages the swipeable pages.
  late final PageController _pageController;
// The controller handles business logic like date calculations.
  late final TransactionViewerController _controller;
// The currently visible page index is local UI state.
  late int _currentIndex;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _controller = TransactionViewerController();
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
// PopScope intercepts the back navigation to return the current index.
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _controller.handlePop(context, _currentIndex);
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
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: widget.transactions.length,
// When the user swipes to a new page, update the local state.
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final transaction = widget.transactions[index];
// The receipt page is built using the transaction data.
            return _buildReceiptPage(context, transaction);
          },
        ),
      ),
    );
  }
  /// Builds the content for a single transaction receipt page.
  Widget _buildReceiptPage(
      BuildContext context, BorrowTransaction transaction) {
// All data-dependent logic is delegated to the controller.
    final daysLeft = _controller.calculateDaysLeft(transaction.deadlineDate);
    final daysLeftText = _controller.getDaysLeftText(daysLeft);
    final daysLeftColor = _controller.getDaysLeftColor(daysLeft);
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
                style: Theme
                    .of(context)
                    .textTheme
                    .titleSmall,
              ),
              const Divider(height: 20, thickness: 1),
              _buildReceiptRow(context, 'Course:',
                  '${transaction.courseCode} - ${transaction.courseName}'),
              _buildReceiptRow(
                  context, 'Date Borrowed:', transaction.dateBorrowed),
              _buildReceiptRow(context, 'Deadline:', transaction.deadlineDate),
              _buildReceiptRow(context, 'Borrower:', transaction.borrowerName),
              const SizedBox(height: 10),
              // Status banner (e.g., 'OVERDUE')
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: daysLeftColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  daysLeftText,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(height: 30, thickness: 1.5),
              // Group Members List
              Text('Group Members:',
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: transaction.groupMembers
                      .map((member) =>
                      Text('• $member',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge))
                      .toList(),
                ),
              ),
              const Divider(height: 30, thickness: 1.5),
              // Borrowed Items Table
              Text(
                'Items Borrowed (${transaction.borrowedItems.length}):',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildItemsTable(transaction.borrowedItems),
            ],
          ),
        ),
      ),
    );
  }
  // Builds the table for borrowed items.
  Widget _buildItemsTable(List<CartItem> items) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            _buildReceiptCell('Item Name',
                isHeader: true, alignment: TextAlign.left),
            _buildReceiptCell('Qty', isHeader: true, alignment: TextAlign.center),
          ],
        ),
        ...items.map((item) {
          return TableRow(
            children: [
              _buildReceiptCell(item.name, alignment: TextAlign.left),
              _buildReceiptCell('${item.quantity}x', alignment: TextAlign.center),
            ],
          );
        }).toList(),
      ],
    );
  }
// --- Helper widgets for UI structure ---
  Widget _buildReceiptRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildReceiptCell(String text,
      {bool isHeader = false, required TextAlign alignment}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text,
        textAlign: alignment,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}