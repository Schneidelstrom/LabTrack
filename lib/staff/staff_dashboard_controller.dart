import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/models/return_item.dart';
import 'package:labtrack/student/models/user.dart';
import 'package:labtrack/student/services/auth.dart';
import 'package:labtrack/student/services/database.dart';

class StaffDashboardController {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  UserModel? currentUser;
  bool isLoading = true;

  List<BorrowTransaction> _allTransactions = [];
  List<BorrowTransaction> filteredTransactions = [];

  /// Fetches the staff user's details and all active borrow transactions.
  Future<void> loadInitialData() async {
    isLoading = true;

    // Fetch current user and all transactions in parallel for speed.
    final results = await Future.wait([
      _authService.getCurrentUserDetails(),
      _dbService.getAllBorrowTransactions(),
    ]);

    currentUser = results[0] as UserModel?;
    _allTransactions = results[1] as List<BorrowTransaction>;
    filteredTransactions = _allTransactions; // Initially, show all.

    isLoading = false;
  }

  /// Filters the list of transactions based on a search query.
  void searchTransactions(String query) {
    if (query.isEmpty) {
      filteredTransactions = _allTransactions;
      return;
    }
    final lowerCaseQuery = query.toLowerCase();
    filteredTransactions = _allTransactions.where((tx) {
      // Search by borrower email, course code, or any item name.
      final borrowerMatch = tx.borrowerUpMail.toLowerCase().contains(lowerCaseQuery);
      final courseMatch = tx.courseCode.toLowerCase().contains(lowerCaseQuery);
      final itemMatch = tx.borrowedItems.any((item) => item.name.toLowerCase().contains(lowerCaseQuery));
      return borrowerMatch || courseMatch || itemMatch;
    }).toList();
  }

  /// Processes a return, updates stock, creates a return record, and cleans up the original borrow record.
  Future<void> handleReturn({
    required BuildContext context,
    required BorrowTransaction transaction,
    required Map<String, int> returnedQuantities,
  }) async {
    final returnedItemsList = returnedQuantities.entries.where((entry) => entry.value > 0).map((entry) => CartItem(name: entry.key, quantity: entry.value)).toList();

    if (returnedItemsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No items were marked for return.")));
      return;
    }

    final totalBorrowed = transaction.borrowedItems.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalReturned = returnedItemsList.fold<int>(0, (sum, item) => sum + item.quantity);

    print(transaction.borrowerUpMail);

    // Create a record for the return_items collection.
    final newReturnRecord = ReturnItem(
      returnId: 'TNRTN-${DateFormat('yyyy-MM-dd').format(DateTime.now())}-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      courseCode: transaction.courseCode,
      borrowDate: transaction.dateBorrowed,
      returnDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      quantity: totalBorrowed,
      returnedQuantity: totalReturned,
      returnerUpMail: transaction.borrowerUpMail,
    );

    try {
      // Use the existing DatabaseService method to update stock and add the return record
      await _dbService.processReturn(newReturnRecord, returnedItemsList);

      // If all items were returned, delete the original borrow transaction
      if (totalReturned >= totalBorrowed) {
        await _dbService.deleteBorrowTransaction(transaction.borrowId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return processed successfully!'), backgroundColor: Colors.green),
      );

    } catch (e) {
      print("Error processing return: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing return: $e'), backgroundColor: Colors.red),
      );
    }
    // Refresh data to update the UI
    await loadInitialData();
  }
}