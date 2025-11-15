import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/report.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';

/// For reporting a damaged or lost item with a list of currently borrowed items that can be reported and aform to submit a report for a selected item
class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  final ReportController _controller = ReportController();
  late Future<void> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _controller.loadBorrowedItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: _buildAppBar(),
      body: FutureBuilder<void>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          return _controller.isReporting ? _buildReportForm() : _buildBorrowedItemsList();
        },
      ),
    );
  }

  /// Builds AppBar based on controller state
  PreferredSizeWidget _buildAppBar() {
    if (_controller.isReporting) {
      return CommonAppBar(
        title: 'Report Damaged',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() => _controller.cancelReporting()),
        ),
      );
    } else return const CommonAppBar(title: 'Borrowed Items');
  }

  /// Build list of borrowed items that can be reported
  Widget _buildBorrowedItemsList() {
    if (_controller.borrowedItems.isEmpty) return const Center(child: Text("You have no items to report."));
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _controller.borrowedItems.length,
      itemBuilder: (context, index) {
        final item = _controller.borrowedItems[index];
        return _BorrowedItemCard(
          item: item,
          onReport: () {
            setState(() => _controller.startReporting(item));
          },
        );
      },
    );
  }

  /// Builds form for submitting report
  Widget _buildReportForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // For image upload
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
          // Description text field
          TextField(
            decoration: InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          // Submit button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              setState(() => _controller.submitReport(context));
            },
            child: const Text('Submit Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Display single borrowed item card in list
class _BorrowedItemCard extends StatelessWidget {
  final CartItem item;
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