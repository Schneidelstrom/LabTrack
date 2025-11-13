import 'package:flutter/material.dart';
import 'package:labtrack/student/reusables.dart';

enum PenaltyStatus { unresolved, resolved }

class _PenaltyItem {
  final String itemName;
  final String reason;
  final String dateIncurred;
  final double amount;
  final PenaltyStatus status;

  const _PenaltyItem({
    required this.itemName,
    required this.reason,
    required this.dateIncurred,
    required this.amount,
    required this.status,
  });
}

class StudentPenalty extends StatefulWidget {
  const StudentPenalty({super.key});

  @override
  State<StudentPenalty> createState() => _StudentPenaltyState();
}

class _StudentPenaltyState extends State<StudentPenalty> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_PenaltyItem> _penaltyItems = const [
    _PenaltyItem(
      itemName: 'Beaker (250ml)',
      reason: 'Overdue Return',
      dateIncurred: '21-10-2025',
      amount: 5.00,
      status: PenaltyStatus.unresolved,
    ),
    _PenaltyItem(
      itemName: 'Microscope',
      reason: 'Damaged Item',
      dateIncurred: '15-10-2025',
      amount: 50.00,
      status: PenaltyStatus.unresolved,
    ),
    _PenaltyItem(
      itemName: 'Bunsen Burner',
      reason: 'Overdue Return',
      dateIncurred: '05-10-2025',
      amount: 15.00,
      status: PenaltyStatus.resolved,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildAppDrawer(context, selectedIndex: 0),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Penalties'),
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
      body: _penaltyItems.isEmpty
          ? const Center(
        child: Text(
          'You have no penalties.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _penaltyItems.length,
        itemBuilder: (context, index) {
          return _PenaltyCard(item: _penaltyItems[index]);
        },
      ),
    );
  }
}

class _PenaltyCard extends StatelessWidget {
  final _PenaltyItem item;
  const _PenaltyCard({required this.item});

  Map<String, dynamic> _getStatusStyle(BuildContext context) {
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
    final statusStyle = _getStatusStyle(context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
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
                  item.reason,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
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
            const SizedBox(height: 8),
            Text(
              'Item: ${item.itemName}',
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              'Date Incurred: ${item.dateIncurred}',
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '₱${item.amount.toStringAsFixed(2)}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: item.status == PenaltyStatus.unresolved
                        ? Colors.red.shade700
                        : Colors.black,
                  ),
                ),
                if (item.status == PenaltyStatus.unresolved)
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Proceeding to pay for ${item.itemName}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pay Now'),
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.green, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}