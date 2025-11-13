import 'package:flutter/material.dart';
import 'package:labtrack/student/reusables.dart';

enum ReportStatus { underReview, resolved }

class _ReportedItem {
  final String itemName;
  final String reportDate;
  final ReportStatus status;

  const _ReportedItem({
    required this.itemName,
    required this.reportDate,
    required this.status,
  });
}

class StudentReported extends StatefulWidget {
  const StudentReported({super.key});

  @override
  State<StudentReported> createState() => _StudentReportedState();
}

class _StudentReportedState extends State<StudentReported> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_ReportedItem> _reportedItems = const [
    _ReportedItem(
      itemName: 'Bunsen Burner',
      reportDate: '22-10-2025',
      status: ReportStatus.underReview,
    ),
    _ReportedItem(
      itemName: 'Microscope Lens',
      reportDate: '15-10-2025',
      status: ReportStatus.resolved,
    ),
    _ReportedItem(
      itemName: 'Beaker (500ml)',
      reportDate: '01-10-2025',
      status: ReportStatus.resolved,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildAppDrawer(context, selectedIndex: 0),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Reports'),
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
      body: _reportedItems.isEmpty
          ? const Center(
        child: Text(
          'You have not submitted any reports.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _reportedItems.length,
        itemBuilder: (context, index) {
          return _ReportCard(item: _reportedItems[index]);
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final _ReportedItem item;
  const _ReportCard({required this.item});

  Map<String, dynamic> _getStatusStyle(BuildContext context) {
    switch (item.status) {
      case ReportStatus.resolved:
        return {
          'text': 'Resolved',
          'color': Colors.green.shade800,
          'background': Colors.green.shade50,
        };
      case ReportStatus.underReview:
      default:
        return {
          'text': 'Under Review',
          'color': Colors.orange.shade800,
          'background': Colors.orange.shade50,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = _getStatusStyle(context);

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing details for ${item.itemName} report')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reported on ${item.reportDate}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusStyle['background'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusStyle['text'],
                  style: TextStyle(
                    color: statusStyle['color'],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}