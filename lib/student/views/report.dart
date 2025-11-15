// lib/views/report_view.dart
import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/report.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';
/// The UI for reporting a damaged or lost item.
/// This view has two states:
/// 1. A list of currently borrowed items that can be reported.
/// 2. A form to submit a report for a selected item.
/// The [ReportController] manages the state and logic for this flow.
class ReportView extends StatefulWidget {
  const ReportView({super.key});
  @override
  State<ReportView> createState() => _ReportViewState();
}
class _ReportViewState extends State<ReportView> {
// The controller manages the view's state and business logic.
  final ReportController _controller = ReportController();
  late Future<void> _itemsFuture;
  @override
  void initState() {
    super.initState();
// Load the user's currently borrowed items.
    _itemsFuture = _controller.loadBorrowedItems();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
// The AppBar changes depending on whether the user is reporting an item.
      appBar: _buildAppBar(),
      body: FutureBuilder<void>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
// The body also changes based on the reporting state.
          return _controller.isReporting
              ? _buildReportForm()
              : _buildBorrowedItemsList();
        },
      ),
    );
  }
  /// Builds the appropriate AppBar based on the controller's state.
  PreferredSizeWidget _buildAppBar() {
    if (_controller.isReporting) {
// Form-specific AppBar with a back button to cancel.
      return CommonAppBar(
        title: 'Report Damaged',
// Overriding the default hamburger menu with a back button.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() => _controller.cancelReporting()),
        ),
      );
    } else {
// Default list view AppBar.
      return const CommonAppBar(title: 'Borrowed Items');
    }
  }
  /// Builds the list of borrowed items that can be reported.
  Widget _buildBorrowedItemsList() {
    if (_controller.borrowedItems.isEmpty) {
      return const Center(child: Text("You have no items to report."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _controller.borrowedItems.length,
      itemBuilder: (context, index) {
        final item = _controller.borrowedItems[index];
        return _BorrowedItemCard(
          item: item,
          onReport: () {
            // Tell the controller to switch to reporting mode for this item.
            setState(() => _controller.startReporting(item));
          },
        );
      },
    );
  }
  /// Builds the form for submitting a report.
  Widget _buildReportForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
// Placeholder for image upload.
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const SizedBox(
              height: 200,
              width: double.infinity,
              child: Center(
                child: Icon(Icons.add_a_photo_outlined, size: 60, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),
// Description text field.
          TextField(
            decoration: InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 24),
// Submit button.
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
// The controller handles submission and state change logic.
              setState(() => _controller.submitReport(context));
            },
            child: const Text('Submit Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
// --- Private UI Widget ---
/// A card to display a single borrowed item in the list.
class _BorrowedItemCard extends StatelessWidget {
  final CartItem item; // Reusing CartItem model for simplicity
  final VoidCallback onReport;
  const _BorrowedItemCard({
    required this.item,
    required this.onReport,
  });
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
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quantity: ${item.quantity}x',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: onReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Report', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}