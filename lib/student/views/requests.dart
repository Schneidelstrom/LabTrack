// lib/views/request_view.dart
import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/request.dart';
import 'package:labtrack/student/models/request_item.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';
/// The UI for displaying a list of the user's pending requests.
/// This view is responsible for rendering the list and delegating user actions,
/// like canceling a request, to the [RequestController].
class RequestView extends StatefulWidget {
  const RequestView({super.key});
  @override
  State<RequestView> createState() => _RequestViewState();
}
class _RequestViewState extends State<RequestView> {
// The controller manages the data and business logic for this screen.
  final RequestController _controller = RequestController();
  late Future<void> _requestsFuture;

  @override
  void initState() {
    super.initState();
// Asynchronously load the pending requests when the view is initialized.
    _requestsFuture = _controller.loadRequests();
  }

  /// Handles the cancellation of a request and refreshes the UI.
  void _cancelRequest(RequestItem request) {
    _controller.cancelRequest(context, request);
// Refresh the view to reflect the change (in a real app, this would
// likely remove the item from the list).
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: const CommonAppBar(title: 'Requests'),
      body: FutureBuilder<void>(
        future: _requestsFuture,
        builder: (context, snapshot) {
// Show a loading indicator while data is being fetched.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show an error message if fetching fails.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If there are no pending requests, display a message.
          if (_controller.requests.isEmpty) {
            return const Center(
              child: Text(
                'You have no pending requests.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Once data is loaded, build the list of request cards.
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _controller.requests.length,
            itemBuilder: (context, index) {
              final request = _controller.requests[index];
              return _PendingRequestCard(
                request: request,
                onCancel: () => _cancelRequest(request),
              );
            },
          );
        },
      ),
    );
  }
}

// --- Private UI Widget ---
/// A card widget to display the details of a single pending request.
/// This is a stateless presentation widget.
class _PendingRequestCard extends StatelessWidget {
  final RequestItem request;
  final VoidCallback onCancel;
  const _PendingRequestCard({required this.request, required this.onCancel});
  @override
  Widget build(BuildContext context) {
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
                  request.courseCode,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF0D47A1)),
                ),
// Status Badge
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pending',
                    style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${request.itemCount} items • Requested on ${request.requestDate}',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Request'),
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}