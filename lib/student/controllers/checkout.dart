import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/models/course.dart';
import 'package:labtrack/student/models/user.dart';
import 'package:labtrack/student/main_screen.dart';
import 'package:labtrack/student/models/lab_item.dart';
import 'package:labtrack/student/services/database.dart';


/// Managing the cart, group members, course selection, and the final checkout process for the [CheckoutView]
class CheckoutController {
  final DatabaseService _dbService = DatabaseService();
  final UserModel currentUser;
  List<CartItem> _cartItems;
  final List<LabItem> _originalLabItems;
  final Set<UserModel> _groupMembers;
  Course? _selectedCourse;
  List<Course> _allCourses = [];
  List<UserModel> _allUsers = [];
  List<CartItem> get cartItems => _cartItems;
  Set<UserModel> get groupMembers => _groupMembers;
  Course? get selectedCourse => _selectedCourse;
  List<Course> get allCourses => _allCourses;

  CheckoutController({
    required this.currentUser,
    required List<LabItem> selectedItems,
    required Set<UserModel> initialGroupMembers,
    Course? initialCourse,
  }) : _groupMembers = initialGroupMembers, _selectedCourse = initialCourse, _originalLabItems = selectedItems, _cartItems = selectedItems.map((item) => CartItem(name: item.name, quantity: 1)).toList();

  Future<void> loadInitialData() async {
    final results = await Future.wait([
      _dbService.getCourses(),
      _dbService.getUsers(),
    ]);

    _allCourses = results[0] as List<Course>;
    _allUsers = results[1] as List<UserModel>;

    if (_selectedCourse == null && _allCourses.isNotEmpty) _selectedCourse = _allCourses.first; // Set default course as the first course in the list
  }

  void incrementQuantity(int index, BuildContext context) {
    if (index >= _cartItems.length) return;

    final cartItem = _cartItems[index];
    final originalItem = _originalLabItems.firstWhere((item) => item.name == cartItem.name,);

    if (cartItem.quantity < originalItem.stock) {
      _cartItems[index] = CartItem(name: cartItem.name, quantity: cartItem.quantity + 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add more. Stock limit for ${cartItem.name} is ${originalItem.stock}.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void decrementQuantity(int index) {
    if (index < _cartItems.length && _cartItems[index].quantity > 1) {
      final item = _cartItems[index];
      _cartItems[index] = CartItem(name: item.name, quantity: item.quantity - 1);
    }
  }

  void addGroupMember(UserModel member) {
    _groupMembers.add(member);
  }

  void removeGroupMember(UserModel member) {
    _groupMembers.remove(member);
  }

  void setSelectedCourse(Course course) {
    _selectedCourse = course;
  }

  /// Search for students who can be added as group members
  Future<Iterable<UserModel>> searchGroupMembers(String pattern) async {
    if (pattern.isEmpty) return const Iterable.empty();
    final lowerCasePattern = pattern.toLowerCase();

    return _allUsers.where((user) {
      if (user.upMail == currentUser.upMail) return false;
      final isAlreadyAdded = _groupMembers.any((member) => member.upMail == user.upMail);
      if (isAlreadyAdded) return false;
      return user.fullName.toLowerCase().contains(lowerCasePattern) || user.upMail.toLowerCase().contains(lowerCasePattern);
    }).take(5);
  }

  /// Popping view and returning current state to the [BorrowView]
  void onWillPop(BuildContext context) {
    final result = {'groupMembers': _groupMembers, 'course': _selectedCourse,};
    Navigator.of(context).pop(result);
  }

  /// Final checkout confirmation and navigation
  Future<void> handleCheckout(BuildContext context) async {
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a course.')),);
      return;
    }
    // Show a confirmation dialog.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
            title: const Text('Confirm Borrowing'),
            content: Text('Submit borrow request for ${_selectedCourse!.courseCode} (${_selectedCourse!.title})?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
      );

    if (confirmed == true && context.mounted) {
      final allMemberEmails = [currentUser, ..._groupMembers].map((user) => user.upMail).toList();
      final newTransaction = BorrowTransaction(
        borrowId: 'TNBRW-${DateFormat('yyyy-MM-dd').format(DateTime.now())}-${currentUser.studentId}-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        courseCode: _selectedCourse!.courseCode,
        courseName: _selectedCourse!.title,
        borrowerUpMail: currentUser.upMail,
        dateBorrowed: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        deadlineDate: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7))),
        groupMembers: allMemberEmails,
        borrowedItems: _cartItems,
      );

      await _dbService.addBorrowTransaction(newTransaction);

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Borrow Request Submitted & Database Updated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}