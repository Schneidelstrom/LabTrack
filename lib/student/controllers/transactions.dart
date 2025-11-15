/// Presentation-layer model to unify different transaction types for display
class DisplayTransaction {
  final String courseCode;
  final String status;
  final String date;
  final String type;
  const DisplayTransaction({
    required this.courseCode,
    required this.status,
    required this.date,
    required this.type,
  });
}

/// fetching and consolidating all transaction types into a single, displayable list for the [TransactionsView]
class TransactionsController {
  List<DisplayTransaction> _transactions = [];
  List<DisplayTransaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _transactions = const [
      DisplayTransaction(
        courseCode: 'CHEM-89',
        status: 'COMPLETE',
        date: '09-08-2025',
        type: 'Return',
      ),
      DisplayTransaction(
        courseCode: 'CHEM-87',
        status: '13 Items',
        date: '09-01-2025',
        type: 'Borrow',
      ),
      DisplayTransaction(
        courseCode: 'BIO-101',
        status: 'PARTIAL',
        date: '08-25-2025',
        type: 'Return',
      ),
      DisplayTransaction(
        courseCode: 'PHYS-99',
        status: '7 Items',
        date: '08-22-2025',
        type: 'Borrow',
      ),
    ];
  }
}