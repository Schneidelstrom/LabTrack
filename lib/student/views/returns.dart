// lib/views/return_view.dart
import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/return.dart';
import 'package:labtrack/student/models/return_item.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';
/// The UI for displaying the history of returned items.
/// This view is responsible for rendering the list and delegating user actions
/// to the [ReturnController].
class ReturnView extends StatefulWidget {
  const ReturnView({super.key});
  @override
  State<ReturnView> createState() => _ReturnViewState();
}
class _ReturnViewState extends State<ReturnView> {
// The controller manages the data and business logic for this screen.
  final ReturnController _controller = ReturnController();
  late Future<void> _returnsFuture;

  @override
  void initState() {
    super.initState();
// Asynchronously load the return history when the view is initialized.
    _returnsFuture = _controller.loadReturnItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: const CommonAppBar(title: 'Returns'),
      body: FutureBuilder<void>(
        future: _returnsFuture,
        builder: (context, snapshot) {
// Show a loading indicator while data is being fetched.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show an error message if fetching fails.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If the return history is empty, display a message.
          if (_controller.returnItems.isEmpty) {
            return const Center(
              child: Text(
                'You have no return history.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Once data is loaded, build the list of return cards.
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _controller.returnItems.length,
            itemBuilder: (context, index) {
              final item = _controller.returnItems[index];
              return _ReturnedItemCard(
                item: item,
                onTap: () => _controller.viewReturnDetails(context, item),
              );
            },
          );
        },
      ),
    );
  }
}

// --- Private UI Widget ---
/// A card widget to display the details of a single returned item transaction.
/// This is a stateless presentation widget.
class _ReturnedItemCard extends StatelessWidget {
  final ReturnItem item;
  final VoidCallback onTap;

  const _ReturnedItemCard({required this.item, required this.onTap});

  /// Determines the display text and color for the status badge.
  /// This is presentation logic and belongs in the view.
  (String, Color) _getStatusDisplay(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.complete:
        return ('COMPLETE', Colors.green);
      case ReturnStatus.partial:
        return ('PARTIAL', Colors.orange);
    }
  }

  /// Formats the quantity display based on the return status.
  String _getItemsDisplay() {
    if (item.status == ReturnStatus.complete) {
      return 'Items: ${item.quantity}';
    } else {
      return 'Items: ${item.returnedQuantity}/${item.quantity}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusText, statusColor) = _getStatusDisplay(item.status);
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.courseCode,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getItemsDisplay()} • Borrowed: ${item.borrowDate}',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.returnDate,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}