import 'package:labtrack/student/services/database.dart';
import 'package:labtrack/student/models/return_item.dart';
import 'package:labtrack/student/services/auth.dart';
import 'package:labtrack/student/models/user.dart';

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
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  List<DisplayTransaction> _transactions = [];
  List<DisplayTransaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    final UserModel? currentUser = await _authService.getCurrentUserDetails();
    if (currentUser == null) return;

    final results = await Future.wait([
      _dbService.getBorrowTransactions(currentUser.upMail),
      _dbService.getReturnItems(currentUser.upMail),
    ]);

    final borrowList = results[0] as List<dynamic>;
    final returnList = results[1] as List<dynamic>;
    final List<DisplayTransaction> consolidatedList = [];

    for (var tx in borrowList) {
      final itemCount = tx.borrowedItems.length;
      consolidatedList.add(
        DisplayTransaction(
          courseCode: tx.courseCode,
          status: '$itemCount ${itemCount == 1 ? "Item" : "Items"}',
          date: tx.dateBorrowed,
          type: 'Borrow',
        ),
      );
    }

    for (var item in returnList) {
      final status = item.status == ReturnStatus.complete ? 'COMPLETE' : 'PARTIAL';
      consolidatedList.add(
        DisplayTransaction(
          courseCode: item.courseCode,
          status: status,
          date: item.returnDate,
          type: 'Return',
        ),
      );
    }

    consolidatedList.sort((a, b) => b.date.compareTo(a.date));
    _transactions = consolidatedList;
  }
}