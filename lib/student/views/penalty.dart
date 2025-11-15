import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/penalty.dart';
import 'package:labtrack/student/models/penalty_item.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';
/// The UI for displaying a list of student penalties.
/// This view is responsible for rendering the list of penalties and delegating
/// user actions to the [PenaltyController].
class PenaltyView extends StatefulWidget {
  const PenaltyView({super.key});
  @override
  State<PenaltyView> createState() => _PenaltyViewState();
}
class _PenaltyViewState extends State<PenaltyView> {
// The controller manages the data and business logic for this screen.
  final PenaltyController _controller = PenaltyController();
  late Future<void> _penaltiesFuture;

  @override
  void initState() {
    super.initState();
// Asynchronously load the penalty data when the view is first created.
    _penaltiesFuture = _controller.loadPenalties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: const CommonAppBar(title: 'Penalties'),
      body: FutureBuilder<void>(
        future: _penaltiesFuture,
        builder: (context, snapshot) {
// Show a loading indicator while data is being fetched.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show an error message if fetching fails.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If there are no penalties, display a message.
          if (_controller.penalties.isEmpty) {
            return const Center(
              child: Text(
                'You have no penalties.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Once data is loaded, build the list of penalty cards.
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _controller.penalties.length,
            itemBuilder: (context, index) {
              final penalty = _controller.penalties[index];
              return _PenaltyCard(
                item: penalty,
                // Pass the controller's method to handle the "Pay Now" action.
                onPayNow: () => _controller.handlePayNow(context, penalty),
              );
            },
          );
        },
      ),
    );
  }
}

// --- Private UI Widget ---
/// A card widget to display the details of a single penalty.
/// This is a stateless presentation widget.
class _PenaltyCard extends StatelessWidget {
  final Penalty item;
  final VoidCallback onPayNow;

  const _PenaltyCard({required this.item, required this.onPayNow});

  /// Determines the display style (text and colors) based on the penalty status.
  /// This is purely presentation logic and belongs in the view layer.
  Map<String, dynamic> _getStatusStyle() {
    switch (item.status) {
      case PenaltyStatus.resolved:
        return {
          'text': 'Resolved',
          'color': Colors.green.shade800,
          'background': Colors.green.shade50,
        };
      case PenaltyStatus.unresolved:
      default:
        return {
          'text': 'Unresolved',
          'color': Colors.red.shade800,
          'background': Colors.red.shade50,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = _getStatusStyle();
    final textTheme = Theme
        .of(context)
        .textTheme;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.reason,
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusStyle['background'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusStyle['text'],
                    style: TextStyle(
                        color: statusStyle['color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Item: ${item.itemName}',
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Date Incurred: ${item.dateIncurred}',
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₱${item.amount.toStringAsFixed(2)}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: item.status == PenaltyStatus.unresolved
                        ? Colors.red.shade700
                        : Colors.black,
                  ),
                ),
                if (item.status == PenaltyStatus.unresolved)
                  ElevatedButton(
                    onPressed: onPayNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pay Now'),
                  )
                else
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}