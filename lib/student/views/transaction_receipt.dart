import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/transaction_receipt.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';
import 'package:labtrack/student/models/cart_item.dart';

/// For viewing a paged list of transaction receipts
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
  late final PageController _pageController;
  late final TransactionViewerController _controller;
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
    // PopScope intercepts the back navigation to return the current index
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
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final transaction = widget.transactions[index];
            return _buildReceiptPage(context, transaction);
          },
        ),
      ),
    );
  }

  /// Builds the content for a transaction receipt page
  Widget _buildReceiptPage(BuildContext context, BorrowTransaction transaction) {
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
                'Transaction ID: ${transaction.borrowId}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Divider(height: 20, thickness: 1),
              _buildReceiptRow(context, 'Course:', '${transaction.courseCode} - ${transaction.courseName}'),
              _buildReceiptRow(context, 'Date Borrowed:', transaction.dateBorrowed),
              _buildReceiptRow(context, 'Deadline:', transaction.deadlineDate),
              _buildReceiptRow(context, 'Borrower:', transaction.borrowerUpMail),
              const SizedBox(height: 10),
              // Status banner
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: daysLeftColor,
                  borderRadius: BorderRadius.circular(8),
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
              Text('Group Members:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: transaction.groupMembers.map((member) => Text('• $member', style: Theme.of(context).textTheme.bodyLarge)).toList(),
                ),
              ),
              const Divider(height: 30, thickness: 1.5),
              // Borrowed Items Table
              Text(
                'Items Borrowed (${transaction.borrowedItems.length}):',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildItemsTable(transaction.borrowedItems),
            ],
          ),
        ),
      ),
    );
  }

  // Build table for borrowed items
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
            _buildReceiptCell('Item Name', isHeader: true, alignment: TextAlign.left),
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildReceiptCell(String text, {bool isHeader = false, required TextAlign alignment}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text,
        textAlign: alignment,
        style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,),
      ),
    );
  }
}