// lib/views/reported_items_view.dart
import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/reported.dart';
import 'package:labtrack/student/models/report_item.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';
/// The UI for displaying a list of items the user has reported.
/// This view is responsible for rendering the list and delegating user actions
/// to the [ReportedItemsController].
class ReportedItemsView extends StatefulWidget {
  const ReportedItemsView({super.key});
  @override
  State<ReportedItemsView> createState() => _ReportedItemsViewState();
}
class _ReportedItemsViewState extends State<ReportedItemsView> {
// The controller manages the data and business logic for this screen.
  final ReportedItemsController _controller = ReportedItemsController();
  late Future<void> _reportsFuture;

  @override
  void initState() {
    super.initState();
// Asynchronously load the reported items data when the view is initialized.
    _reportsFuture = _controller.loadReportedItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: const CommonAppBar(title: 'Reports'),
      body: FutureBuilder<void>(
        future: _reportsFuture,
        builder: (context, snapshot) {
// Show a loading indicator while data is being fetched.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show an error message if fetching fails.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If there are no reports, display a message.
          if (_controller.reportedItems.isEmpty) {
            return const Center(
              child: Text(
                'You have not submitted any reports.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Once data is loaded, build the list of report cards.
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _controller.reportedItems.length,
            itemBuilder: (context, index) {
              final report = _controller.reportedItems[index];
              return _ReportCard(
                item: report,
                // Pass the controller's method to handle tapping on a report.
                onTap: () =>
                    _controller.viewReportDetails(context, report),
              );
            },
          );
        },
      ),
    );
  }
}

// --- Private UI Widget ---
/// A card widget to display the details of a single reported item.
/// This is a stateless presentation widget.
class _ReportCard extends StatelessWidget {
  final ReportedItem item;
  final VoidCallback onTap;

  const _ReportCard({required this.item, required this.onTap});

  /// Determines the display style based on the report status.
  /// This is presentation logic and is kept within the view file.
  Map<String, dynamic> _getStatusStyle() {
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
    final statusStyle = _getStatusStyle();
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reported on ${item.reportDate}',
                      style:
                      TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Status Badge
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