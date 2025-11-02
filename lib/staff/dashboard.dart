import 'package:flutter/material.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaffDashboardPage();
  }
}

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key});

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage> {
  int _selectedIndex = 0;

  final List<Map<String, String>> pendingRequests = [
    {"id": "REQ-001", "student": "John Doe", "item": "Microscope", "date": "2025-09-20"},
    {"id": "REQ-002", "student": "Jane Smith", "item": "Beaker", "date": "2025-09-21"},
    {"id": "REQ-003", "student": "Andrew Lee", "item": "Pipette", "date": "2025-09-22"},
  ];

  final List<Map<String, String>> pendingReturns = [
    {"student": "John Doe", "item": "Microscope", "due": "2025-09-25"},
    {"student": "Jane Smith", "item": "Beaker", "due": "2025-09-25"},
    {"student": "Andrew Lee", "item": "Pipette", "due": "2025-09-20"},
  ];

  final List<Map<String, String>> recentActivity = [
    {"msg": "John Doe borrowed Microscope (Approved)"},
    {"msg": "Jane Smith returned Beaker (No issues)"},
    {"msg": "Penalty issued to Andrew Lee (₱100 fine)"},
    {"msg": "Student A created by User"},
  ];

  final stats = {
    'totalItems': 250,
    'borrowedNow': 73,
    'available': 177,
    'overdue': 5,
  };

  final navItems = [
    'Dashboard',
    'Borrow Requests',
    'Returns',
    'Inventory',
    'Student Accounts',
    'Penalties',
    'Settings',
  ];

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
          const Text('Welcome, User', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const SizedBox(width: 8),
          const CircleAvatar(child: Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTable({
    required String title,
    required List<DataColumn> columns,
    required List<DataRow> rows,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(columns: columns, rows: rows),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...recentActivity.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(a['msg']!)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPendingTable(
                title: "Pending Borrow Requests",
                columns: const [
                  DataColumn(label: Text('Request ID')),
                  DataColumn(label: Text('Student Name')),
                  DataColumn(label: Text('Item Name')),
                  DataColumn(label: Text('Request Date')),
                  DataColumn(label: Text('Action')),
                ],
                rows: pendingRequests.map((r) {
                  return DataRow(cells: [
                    DataCell(Text(r['id']!)),
                    DataCell(Text(r['student']!)),
                    DataCell(Text(r['item']!)),
                    DataCell(Text(r['date']!)),
                    DataCell(Row(
                      children: [
                        ElevatedButton(onPressed: () {}, child: const Text('Approve')),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: () {}, child: const Text('Reject')),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPendingTable(
                title: "Pending Returns",
                columns: const [
                  DataColumn(label: Text('Student Name')),
                  DataColumn(label: Text('Item Name')),
                  DataColumn(label: Text('Due Date')),
                  DataColumn(label: Text('Action')),
                ],
                rows: pendingReturns.map((r) {
                  return DataRow(cells: [
                    DataCell(Text(r['student']!)),
                    DataCell(Text(r['item']!)),
                    DataCell(Text(r['due']!)),
                    DataCell(Row(
                      children: [
                        ElevatedButton(onPressed: () {}, child: const Text('Mark Returned')),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: () {}, child: const Text('Assign Penalty')),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard('Total Items', stats['totalItems'].toString()),
            const SizedBox(width: 12),
            _buildStatCard('Borrowed Now', stats['borrowedNow'].toString()),
            const SizedBox(width: 12),
            _buildStatCard('Available', stats['available'].toString()),
            const SizedBox(width: 12),
            _buildStatCard('Overdue', stats['overdue'].toString()),
          ],
        ),
        const SizedBox(height: 16),
        _buildRecentActivity(),
      ],
    );
  }

  Widget _buildContentForIndex() {
    switch (_selectedIndex) {
      case 0:
        return _buildMainContent();
      case 1:
        return _buildPendingTable(
          title: "Borrow Requests",
          columns: const [
            DataColumn(label: Text('Request ID')),
            DataColumn(label: Text('Student Name')),
            DataColumn(label: Text('Item Name')),
            DataColumn(label: Text('Request Date')),
            DataColumn(label: Text('Action')),
          ],
          rows: pendingRequests.map((r) {
            return DataRow(cells: [
              DataCell(Text(r['id']!)),
              DataCell(Text(r['student']!)),
              DataCell(Text(r['item']!)),
              DataCell(Text(r['date']!)),
              const DataCell(Text("...")),
            ]);
          }).toList(),
        );
      case 2:
        return _buildPendingTable(
          title: "Returns",
          columns: const [
            DataColumn(label: Text('Student Name')),
            DataColumn(label: Text('Item Name')),
            DataColumn(label: Text('Due Date')),
            DataColumn(label: Text('Action')),
          ],
          rows: pendingReturns.map((r) {
            return DataRow(cells: [
              DataCell(Text(r['student']!)),
              DataCell(Text(r['item']!)),
              DataCell(Text(r['due']!)),
              const DataCell(Text("...")),
            ]);
          }).toList(),
        );
      default:
        return const Center(child: Text("Other Pages (UI only)"));
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
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
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
}
