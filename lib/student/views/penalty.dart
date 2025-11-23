import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/penalty.dart';
import 'package:labtrack/student/models/penalty_item.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';

/// For displaying a list of student penalties.
class PenaltyView extends StatefulWidget {
  const PenaltyView({super.key});

  @override
  State<PenaltyView> createState() => _PenaltyViewState();
}

class _PenaltyViewState extends State<PenaltyView> {
  final PenaltyController _controller = PenaltyController();
  late Future<void> _penaltiesFuture;

  @override
  void initState() {
    super.initState();
    _penaltiesFuture = _controller.loadPenalties();
  }

  void _payForPenalty(Penalty penalty) async {
    await _controller.handlePayNow(context, penalty);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: const CommonAppBar(title: 'Penalties'),
      body: FutureBuilder<void>(
        future: _penaltiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (_controller.penalties.isEmpty) {
            return const Center(
              child: Text(
                'You have no penalties.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _controller.penalties.length,
            itemBuilder: (context, index) {
              final penalty = _controller.penalties[index];
              return _PenaltyCard(
                item: penalty,
                  onPayNow: () => _payForPenalty(penalty),
              );
            },
          );
        },
      ),
    );
  }
}

/// Dard widget to display the details of a single penalty
class _PenaltyCard extends StatelessWidget {
  final Penalty item;
  final VoidCallback onPayNow;
  const _PenaltyCard({required this.item, required this.onPayNow});

  /// Determine display style (text and colors) based on the penalty status
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
    final textTheme = Theme.of(context).textTheme;
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
                Text(
                    item.reason,
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
            Text(
                'Item: ${item.itemName}',
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey)
            ),
            const SizedBox(height: 4),
            Text(
                'Date Incurred: ${item.dateIncurred}',
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey)
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₱${item.amount.toStringAsFixed(2)}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: item.status == PenaltyStatus.unresolved ? Colors.red.shade700 : Colors.black,
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
                  const Icon(
                      Icons.check_circle,
                      color: Colors.green, size: 28
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}