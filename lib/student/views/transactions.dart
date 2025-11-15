// lib/views/transactions_view.dart
import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/transactions.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';
/// The UI for displaying a history of all transactions (borrows and returns).
/// This view fetches data via the [TransactionsController] and renders it in a list.
class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});
  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}
class _TransactionsViewState extends State<TransactionsView> {
// The controller is responsible for fetching and holding the transaction data.
  final TransactionsController _controller = TransactionsController();
  late Future<void> _transactionsFuture;

  @override
  void initState() {
    super.initState();
// Asynchronously load the transaction history.
    _transactionsFuture = _controller.loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: const CommonAppBar(title: 'Transaction History'),
      body: FutureBuilder<void>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
// Show a loading indicator while data is being fetched.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show an error message if fetching fails.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If there is no transaction history, display a message.
          if (_controller.transactions.isEmpty) {
            return const Center(
              child: Text(
                'No transaction history found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Once data is loaded, build the list of transaction cards.
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _controller.transactions.length,
            itemBuilder: (context, index) {
              final transaction = _controller.transactions[index];
              return _TransactionCard(
                // The controller provides a unified transaction object for display.
                transaction: transaction,
              );
            },
          );
        },
      ),
    );
  }
}

// --- Private UI Widget ---
/// A card widget to display a summary of a single transaction.
/// This widget is stateless and purely for presentation.
class _TransactionCard extends StatelessWidget {
// It takes a DisplayTransaction, a class defined in the controller for UI purposes.
  final DisplayTransaction transaction;
  const _TransactionCard({required this.transaction});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.courseCode,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  '${transaction.status} ${transaction.date}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            Text(
              transaction.type,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}