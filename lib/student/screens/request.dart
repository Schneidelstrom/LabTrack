import 'package:flutter/material.dart';
import 'package:labtrack/student/reusables.dart';

class _PendingRequest {
  final String courseCode;
  final int itemCount;
  final String requestDate;

  const _PendingRequest({
    required this.courseCode,
    required this.itemCount,
    required this.requestDate,
  });
}

class StudentRequest extends StatefulWidget {
  const StudentRequest({super.key});

  @override
  State<StudentRequest> createState() => _StudentRequestState();
}

class _StudentRequestState extends State<StudentRequest> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_PendingRequest> _pendingRequests = const [
    _PendingRequest(
      courseCode: 'PHYS-101',
      itemCount: 4,
      requestDate: '25-10-2025',
    ),
    _PendingRequest(
      courseCode: 'CHEM-205',
      itemCount: 12,
      requestDate: '24-10-2025',
    ),
    _PendingRequest(
      courseCode: 'BIO-301',
      itemCount: 7,
      requestDate: '24-10-2025',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildAppDrawer(context, selectedIndex: 0),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Requests'),
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
      body: _pendingRequests.isEmpty
          ? const Center(
        child: Text(
          'You have no pending requests.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          return _PendingRequestCard(request: _pendingRequests[index]);
        },
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  final _PendingRequest request;

  const _PendingRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.courseCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${request.itemCount} items • Requested on ${request.requestDate}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Request'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cancelled request for ${request.courseCode}')),
                  );
                },
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 12)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}