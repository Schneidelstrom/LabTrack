import 'package:flutter/material.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/models/course.dart';
import 'package:labtrack/student/models/group_member.dart';
import 'package:labtrack/student/main_screen.dart';

/// Managing the cart, group members, course selection, and the final checkout process for the [CheckoutView]
class CheckoutController {
  late List<CartItem> _cartItems;
  final Set<GroupMember> _groupMembers;
  Course? _selectedCourse;
  List<Course> _allCourses = [];
  List<GroupMember> _allStudents = [];
  List<CartItem> get cartItems => _cartItems;
  Set<GroupMember> get groupMembers => _groupMembers;
  Course? get selectedCourse => _selectedCourse;
  List<Course> get allCourses => _allCourses;
  CheckoutController({required Set<String> selectedItemNames, required Set<GroupMember> initialGroupMembers, Course? initialCourse,}) :_cartItems = selectedItemNames.map((name) => CartItem(name: name)).toList(), _groupMembers = initialGroupMembers, _selectedCourse = initialCourse; // Initialize state from data passed by [BorrowView]

  Future<void> loadInitialData() async {
    await Future.delayed(
        const Duration(milliseconds: 200));
    _allCourses = const [
      Course(code: 'BIO-107', title: 'General Biology I'),
      Course(code: 'CMSC-189', title: 'Introduction to Computer Science'),
      Course(code: 'CHEM-102', title: 'General Chemistry'),
    ];
    _allStudents = const [
      GroupMember(upmail: 'asmith@up.edu.ph', name: 'Alice Smith'),
      GroupMember(upmail: 'bjohnson@up.edu.ph', name: 'Bob Johnson'),
      GroupMember(upmail: 'cbrown@up.edu.ph', name: 'Charlie Brown'),
    ];
    _selectedCourse ??= _allCourses.first;
  }

  void incrementQuantity(int index) {
    if (index < _cartItems.length) _cartItems[index].quantity++;
  }

  void decrementQuantity(int index) {
    if (index < _cartItems.length && _cartItems[index].quantity > 1) _cartItems[index].quantity--;
  }

  void addGroupMember(GroupMember member) {
    _groupMembers.add(member);
  }

  void removeGroupMember(GroupMember member) {
    _groupMembers.remove(member);
  }

  void setSelectedCourse(Course course) {
    _selectedCourse = course;
  }

  /// Search for students who can be added as group members
  Future<Iterable<GroupMember>> searchGroupMembers(String pattern) async {
    if (pattern.isEmpty) return const Iterable.empty();
    final lowerCasePattern = pattern.toLowerCase();

    return _allStudents.where((student) {
      // Exclude students who are already in the group
      final isAlreadyAdded = _groupMembers.any((member) => member.upmail == student.upmail);
      if (isAlreadyAdded) return false;
      // Match by name
      return student.name.toLowerCase().contains(lowerCasePattern);}).take(5); // Limit results for performance
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
            content: Text('Submit borrow request for ${_selectedCourse!.code} (${_selectedCourse!.title})?'),
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
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false,); // Go back to main screen and show a success message on confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Borrow Request Submitted Successfully!'), backgroundColor: Colors.green,),
      );
    }
  }
}