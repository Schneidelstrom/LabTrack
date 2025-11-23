import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/waitlist.dart';
import 'package:labtrack/student/models/waitlist_item.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';

/// For displaying the user's waitlisted items.
class WaitlistView extends StatefulWidget {
  const WaitlistView({super.key});

  @override
  State<WaitlistView> createState() => _WaitlistViewState();
}
class _WaitlistViewState extends State<WaitlistView> {
  final WaitlistController _controller = WaitlistController();
  late Future<void> _waitlistFuture;

  @override
  void initState() {
    super.initState();
    _waitlistFuture = _controller.loadWaitlistItems();
  }

  void _cancelReservation(WaitlistItem item) async {
    await _controller.cancelReservation(context, item);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: const CommonAppBar(title: 'Waitlist'),
      body: FutureBuilder<void>(
        future: _waitlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (_controller.waitlistItems.isEmpty) {
            return const Center(
              child: Text(
                'You have no items on your waitlist.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _controller.waitlistItems.length,
            itemBuilder: (context, index) {
              final item = _controller.waitlistItems[index];
              return _WaitlistCard(
                item: item,
                onCancel: () => _cancelReservation(item),
              );
            },
          );
        },
      ),
    );
  }
}

/// Card widget to display details of single waitlisted item
class _WaitlistCard extends StatelessWidget {
  final WaitlistItem item;
  final VoidCallback onCancel;

  const _WaitlistCard({required this.item, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final bool isReady = item.status == WaitlistStatus.readyForPickup;
    final Color statusColor = isReady ? Colors.green.shade700 : Colors.orange.shade800;
    final IconData statusIcon = isReady ? Icons.check_circle : Icons.hourglass_top;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.courseCode,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue.shade900
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  item.statusMessage,
                  style: TextStyle(
                      fontSize: 16,
                      color: statusColor,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
            // Show pickup details only if the item is ready
            if (isReady) ...[
              const Divider(height: 24),
              const Text(
                  'Pickup Deadline:',
                  style: TextStyle(color: Colors.grey)
              ),
              const SizedBox(height: 4),
              const Text('12 November 2025 at 5:00 PM',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  )
              ),
            ],
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text("Cancel Reservation"),
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}