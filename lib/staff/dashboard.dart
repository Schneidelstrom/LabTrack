import 'package:flutter/material.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';
import 'package:labtrack/staff/staff_dashboard_controller.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  late final StaffDashboardController _controller;
  late Future<void> _dataFuture;
  int _selectedIndex = 0;
  final navItems = ['Dashboard', 'Returns', 'Inventory', 'Student Accounts', 'Penalties', 'Settings'];

  @override
  void initState() {
    super.initState();
    _controller = StaffDashboardController();
    _dataFuture = _controller.loadInitialData();
  }

  void _refreshData() {
    setState(() {
      _dataFuture = _controller.loadInitialData();
    });
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: const Color(0xFF1F2A44),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: const [
                Icon(Icons.science, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'LabTrack - Staff',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final selected = index == _selectedIndex;
                return InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    color: selected ? Colors.indigo.shade700 : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(_getNavIcon(index), color: Colors.white),
                        const SizedBox(width: 12),
                        Text(navItems[index], style: const TextStyle(color: Colors.white, fontSize: 15)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      Text('Staff', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.logout, color: Colors.white70),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  IconData _getNavIcon(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.request_page;
      case 2:
        return Icons.assignment_returned;
      case 3:
        return Icons.inventory;
      case 4:
        return Icons.group;
      case 5:
        return Icons.report_problem;
      default:
        return Icons.settings;
    }
  }

  Widget _buildTopBar() {
    // Personalized welcome message
    final userName = _controller.currentUser?.firstName ?? 'Staff';
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Spacer(),
          Text('Welcome, $userName', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const SizedBox(width: 8),
          CircleAvatar(child: Text(userName.isNotEmpty ? userName[0] : 'S')),
        ],
      ),
    );
  }

  Widget _buildReturnsPage() {
    return FutureBuilder(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error loading data: ${snapshot.error}"));
        }
        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _controller.searchTransactions(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search by Borrower, Course, or Item...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            // List of Transactions
            Expanded(
              child: _controller.filteredTransactions.isEmpty
                  ? const Center(child: Text("No active borrow transactions found."))
                  : ListView.builder(
                itemCount: _controller.filteredTransactions.length,
                itemBuilder: (context, index) {
                  final tx = _controller.filteredTransactions[index];
                  return _TransactionCard(
                    transaction: tx,
                    onReturn: () => _showReturnDialog(context, tx),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContentForIndex() {
    switch (_selectedIndex) {
      case 1: // Returns Page
        return _buildReturnsPage();
      default:
        return Center(child: Text("${navItems[_selectedIndex]} Page (UI Only)"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                FutureBuilder(
                  future: _dataFuture,
                  builder: (context, snapshot) => _buildTopBar(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: _buildContentForIndex(),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showReturnDialog(BuildContext context, BorrowTransaction transaction) async {
    // Map to store the quantity of each item to be returned.
    final Map<String, int> returnedQuantities = {
      for (var item in transaction.borrowedItems) item.name: 0
    };

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Process Return for ${transaction.courseCode}'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: transaction.borrowedItems.map((item) {
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('Borrowed: ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () {
                                setDialogState(() {
                                  if (returnedQuantities[item.name]! > 0) {
                                    returnedQuantities[item.name] = returnedQuantities[item.name]! - 1;
                                  }
                                });
                              },
                            ),
                            Text('${returnedQuantities[item.name]}', style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              onPressed: () {
                                setDialogState(() {
                                  // Can't return more than was borrowed
                                  if (returnedQuantities[item.name]! < item.quantity) {
                                    returnedQuantities[item.name] = returnedQuantities[item.name]! + 1;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close dialog first
                    await _controller.handleReturn(
                      context: context,
                      transaction: transaction,
                      returnedQuantities: returnedQuantities,
                    );
                    _refreshData(); // Refresh the main list
                  },
                  child: const Text('Submit Return'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final BorrowTransaction transaction;
  final VoidCallback onReturn;

  const _TransactionCard({required this.transaction, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    final totalItems = transaction.borrowedItems.fold<int>(0, (sum, item) => sum + item.quantity);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text('${transaction.courseCode} - ${transaction.borrowerUpMail}'),
        subtitle: Text('$totalItems items borrowed on ${transaction.dateBorrowed}. Due: ${transaction.deadlineDate}'),
        trailing: ElevatedButton(
          onPressed: onReturn,
          child: const Text('Process Return'),
        ),
      ),
    );
  }
}