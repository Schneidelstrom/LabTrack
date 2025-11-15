import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/transactions.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';

/// For displaying a history of all transactions (borrows and returns)
class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}
class _TransactionsViewState extends State<TransactionsView> {
  final TransactionsController _controller = TransactionsController();
  late Future<void> _transactionsFuture;

  @override
  void initState() {
    super.initState();
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
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (_controller.transactions.isEmpty) {
            return const Center(
              child: Text(
                'No transaction history found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _controller.transactions.length,
            itemBuilder: (context, index) {
              final transaction = _controller.transactions[index];
              return _TransactionCard(transaction: transaction,);
            },
          );
        },
      ),
    );
  }
}

/// Card widget to display summary of a transaction
class _TransactionCard extends StatelessWidget {
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
                      fontWeight: FontWeight.bold,
                      fontSize: 22
                  ),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}