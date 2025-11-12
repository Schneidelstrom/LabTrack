import 'package:flutter/material.dart';
import 'package:labtrack/student/reusables.dart';

enum ReturnStatus { partial, complete }

class _ReturnedItem {
  final String courseCode;
  final String borrowDate;
  final String returnDate;
  final int quantity;
  final int returnedQuantity;

  const _ReturnedItem({
    required this.courseCode,
    required this.borrowDate,
    required this.returnDate,
    required this.quantity,
    required this.returnedQuantity,
  }) : assert(returnedQuantity <= quantity, 'Returned quantity cannot exceed borrowed quantity');

  ReturnStatus get returnStatus {
    return returnedQuantity >= quantity
        ? ReturnStatus.complete
        : ReturnStatus.partial;
  }
}

class StudentReturn extends StatefulWidget {
  const StudentReturn({super.key});

  @override
  State<StudentReturn> createState() => _StudentReturnState();
}

class _StudentReturnState extends State<StudentReturn> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_ReturnedItem> _returnedItems = const [
    _ReturnedItem(
      courseCode: 'CS101',
      quantity: 5,
      returnedQuantity: 5,
      borrowDate: '15-01-2025',
      returnDate: '20-01-2025',
    ),
    _ReturnedItem(
      courseCode: 'PHYS205',
      quantity: 10,
      returnedQuantity: 7,
      borrowDate: '14-01-2025',
      returnDate: '18-01-2025',
    ),
    _ReturnedItem(
      courseCode: 'CHEM310',
      quantity: 10,
      returnedQuantity: 10,
      borrowDate: '10-01-2025',
      returnDate: '15-01-2025',
    ),
    _ReturnedItem(
      courseCode: 'BIO101',
      quantity: 2,
      returnedQuantity: 1,
      borrowDate: '05-01-2025',
      returnDate: '10-01-2025',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildAppDrawer(context, selectedIndex: 0),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Returns'),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _returnedItems.length,
        itemBuilder: (context, index) {
          return _ReturnedItemCard(item: _returnedItems[index]);
        },
      ),
    );
  }
}

class _ReturnedItemCard extends StatelessWidget {
  final _ReturnedItem item;
  const _ReturnedItemCard({required this.item});

  (String, Color) _getStatusDisplay(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.complete:
        return ('COMPLETE', Colors.green);
      case ReturnStatus.partial:
        return ('PARTIAL', Colors.orange);
    }
  }

  String _getItemsDisplay() {
    if (item.returnStatus == ReturnStatus.complete) {
      return 'Items: ${item.quantity}';
    } else {
      return 'Items: ${item.returnedQuantity}/${item.quantity}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusText, statusColor) = _getStatusDisplay(item.returnStatus);
    final itemsDisplay = _getItemsDisplay();

    return Card(
      elevation: 3,
      shadowColor: Colors.black,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Viewing details for ${item.courseCode}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.courseCode,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$itemsDisplay • Borrowed: ${item.borrowDate}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.returnDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}