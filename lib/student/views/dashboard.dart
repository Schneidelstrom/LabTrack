import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/dashboard.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';

/// For the callback when transaction viewer is tapped to simplify the method signature for the card widget
typedef OnTransactionView = void Function(BuildContext context, int initialIndex);

/// For displaying summary information and providing primary navigation.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}
class _DashboardViewState extends State<DashboardView> {
  final DashboardController _controller = DashboardController();  // State and business logic manager
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = _controller.loadData();
    if (mounted) setState(() {});
  }

  /// Refreshes dashboard data after returning from a screen that might have changed the state
  void _refreshDashboard(dynamic value) {
    if (value is int) setState(() {_controller.setCurrentTransactionIndex(value);});  // Update if transaction viewer returns a new index
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: CommonAppBar(
        title: 'Dashboard',
      ),
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildWelcomeHeader(),
                    const Spacer(),
                    _buildPenaltyButton(),
                  ],
                ),
                const SizedBox(height: 24),
                _buildCurrentlyBorrowedSection(),
                const SizedBox(height: 24),
                _buildSummaryGrid(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final String welcomeMessage = _controller.currentUser != null ? 'Welcome, ${_controller.currentUser!.firstName}!' : 'Welcome, User!';
    return Text(welcomeMessage, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),);
  }

  Widget _buildPenaltyButton() {
    if (!_controller.hasPenalty) return const SizedBox.shrink();

    return TextButton.icon(
      onPressed: () => _controller.navigateToPenalty(context),
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Colors.red.shade700,
        size: 28,
      ),
      label: Text(
        'Penalty',
        style: TextStyle(
          color: Colors.red.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  /// Builds horizontally-scrollable "Currently Borrowed" card section
  Widget _buildCurrentlyBorrowedSection() {
    if (_controller.borrowedItems.isEmpty) return const Center(child: Text('No borrowed items.'));

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 60.0,
          onPressed: () => setState(() => _controller.previousTransaction()),
        ),
        Expanded(
          child: _CurrentlyBorrowedCard(
            transaction: _controller.currentTransaction,
            currentIndex: _controller.currentTransactionIndex,
            totalCount: _controller.borrowedItems.length,
            onTap: () => _controller.navigateToTransactionViewer(context).then(_refreshDashboard),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          iconSize: 60.0,
          onPressed: () => setState(() => _controller.nextTransaction()),
        ),
      ],
    );
  }

  /// Build 2x2 grid of summary cards
  Widget _buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _SummaryCard(
          title: 'Waitlist',
          items: _controller.waitlistSummary,
          onTap: () => _controller.navigateToWaitlist(context),
        ),
        _SummaryCard(
          title: 'Returns',
          items: _controller.returnsSummary,
          onTap: () => _controller.navigateToReturns(context),
        ),
        _SummaryCard(
          title: 'Requests',
          items: _controller.requestsSummary,
          onTap: () => _controller.navigateToRequests(context),
        ),
        _SummaryCard(
          title: 'Reports',
          items: _controller.reportsSummary,
          onTap: () => _controller.navigateToReportedItems(context),
        ),
      ],
    );
  }

  /// Build "Borrow" and "Report" buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Borrow',
            onPressed: () => _controller.navigateToBorrow(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionButton(
            label: 'Report',
            onPressed: () => _controller.navigateToReport(context),
          ),
        ),
      ],
    );
  }
}

class _CurrentlyBorrowedCard extends StatelessWidget {
  final BorrowTransaction transaction;
  final int currentIndex;
  final int totalCount;
  final VoidCallback onTap;

  const _CurrentlyBorrowedCard({
    required this.transaction,
    required this.currentIndex,
    required this.totalCount,
    required this.onTap,
  });

  // UI logic for colors
  Color _getCardColor(int daysLeft, {required bool isBackground}) {
    if (daysLeft < 0) return isBackground ? Colors.red.shade50 : Colors.red.shade600;
    if (daysLeft == 0) return isBackground ? Colors.orange.shade50 : Colors.orange.shade600;
    return isBackground ? Colors.white : Colors.blue.shade800;
  }

  @override
  Widget build(BuildContext context) {
    final int daysLeft = DashboardController.calculateDaysLeft(transaction.deadlineDate);
    final Color borderColor = _getCardColor(daysLeft, isBackground: false);
    final Color backgroundColor = _getCardColor(daysLeft, isBackground: true);
    final Color textColor = daysLeft < 0 ? Colors.red.shade600 : Colors.blue.shade900;
    final int itemCount = transaction.borrowedItems.length;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: borderColor, width: 2.0),
      ),
      shadowColor: Theme.of(context).shadowColor,
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                transaction.courseCode,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$daysLeft days left',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text('$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text('${currentIndex + 1} of $totalCount',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}


class _SummaryCard extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  final VoidCallback onTap;
  const _SummaryCard({required this.title, required this.items, required this.onTap});

  Color _getStatusColor(String status, BuildContext context) {
    final upperStatus = status.toUpperCase();
    if (upperStatus == 'PICK-UP' || upperStatus == 'COMPLETE') return Colors.green.shade700;
    if (upperStatus == 'PARTIAL') return Colors.orange.shade800;
    if (upperStatus.contains('#')) return Colors.red.shade800;
    return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: items.isEmpty ? Center(child: Text('Nothing to show', style: Theme.of(context).textTheme.bodySmall)) : ListView(
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['name']!, style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            item['status']!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(item['status']!, context),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _ActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: const BorderSide(color: Colors.black, width: 2.0)
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        elevation: 5,
      ),
      child: Text(
          label,
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
          )
      ),
    );
  }
}