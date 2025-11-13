import 'package:flutter/material.dart';
import 'package:labtrack/student/reusables.dart';

enum WaitlistStatus { inQueue, readyForPickup }

class _WaitlistItem {
  final String name;
  final String courseCode;
  final String statusMessage;
  final WaitlistStatus status;

  const _WaitlistItem({
    required this.name,
    required this.courseCode,
    required this.statusMessage,
    required this.status,
  });
}

class StudentWaitlist extends StatefulWidget {
  const StudentWaitlist({super.key});

  @override
  State<StudentWaitlist> createState() => _StudentWaitlistState();
}

class _StudentWaitlistState extends State<StudentWaitlist> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<_WaitlistItem> _waitlistItems = const [
    _WaitlistItem(
      name: 'Digital Scale',
      courseCode: 'BIO-1',
      statusMessage: 'Position: #2',
      status: WaitlistStatus.inQueue,
    ),
    _WaitlistItem(
      name: 'Graduated Cylinder',
      courseCode: 'ENVI-1',
      statusMessage: 'Ready for Pickup',
      status: WaitlistStatus.readyForPickup,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildAppDrawer(context, selectedIndex: 0),
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Waitlist'),
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
      body: _waitlistItems.isEmpty
          ? const Center(
        child: Text(
          'You have no items on your waitlist.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _waitlistItems.length,
        itemBuilder: (context, index) {
          return _WaitlistCard(item: _waitlistItems[index]);
        },
      ),
    );
  }
}

class _WaitlistCard extends StatelessWidget {
  final _WaitlistItem item;
  const _WaitlistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isReady = item.status == WaitlistStatus.readyForPickup;
    final Color statusColor = isReady ? Colors.green.shade700 : Colors.orange.shade800;
    final IconData statusIcon = isReady ? Icons.check_circle : Icons.hourglass_top;
    const String pickupTime = 'Pick up within 24 hours';
    const String pickupDate = '12 November 2025 (Wednesday) at 5:00 PM';

    return Card(
      elevation: 3,
      shadowColor: Colors.black,
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.courseCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue.shade900,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: isReady
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pickup Deadline:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time_filled, color: Colors.red.shade800, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        pickupTime,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.blue.shade800, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        pickupDate,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                ],
              )
                  : const SizedBox(),
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text("Cancel Reservation"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cancel Reservation for ${item.name}')),
                  );
                },
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