import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/models/course.dart';
import 'package:labtrack/student/models/user.dart';
import 'package:labtrack/student/main_screen.dart';

/// Managing the cart, group members, course selection, and the final checkout process for the [CheckoutView]
class CheckoutController {
  late List<CartItem> _cartItems;
  final UserModel currentUser;
  final Set<UserModel> _groupMembers;
  Course? _selectedCourse;
  List<Course> _allCourses = [];
  List<UserModel> _allUsers = [];
  List<CartItem> get cartItems => _cartItems;
  Set<UserModel> get groupMembers => _groupMembers;
  Course? get selectedCourse => _selectedCourse;
  List<Course> get allCourses => _allCourses;
  CheckoutController({required this.currentUser, required Set<String> selectedItemNames, required Set<UserModel> initialGroupMembers, Course? initialCourse,}) :_cartItems = selectedItemNames.map((name) => CartItem(name: name)).toList(), _groupMembers = initialGroupMembers, _selectedCourse = initialCourse; // Initialize state from data passed by [BorrowView]

  Future<void> loadInitialData() async {
    final jsonStrings = await Future.wait([
      rootBundle.loadString('lib/database/courses.json'),
      rootBundle.loadString('lib/database/users.json'),
    ]);

    final decodedCourses = json.decode(jsonStrings[0]);
    final List<dynamic> courseListJson = decodedCourses['courses'];
    _allCourses = courseListJson.map((jsonItem) {
      return Course(code: jsonItem['code'], title: jsonItem['title']);
    }).toList();

    final decodedStudents = json.decode(jsonStrings[1]);
    final List<dynamic> studentListJson = decodedStudents['users'];
    _allUsers = studentListJson.map((jsonItem) {
      return UserModel.fromJson(jsonItem);
    }).toList();

    if (_selectedCourse == null && _allCourses.isNotEmpty) _selectedCourse = _allCourses.first;
  }

  void incrementQuantity(int index) {
    if (index < _cartItems.length) {
      final item = _cartItems[index];
      _cartItems[index] = CartItem(name: item.name, quantity: item.quantity + 1);
    }
  }

  void decrementQuantity(int index) {
    if (index < _cartItems.length && _cartItems[index].quantity > 1) _cartItems[index].quantity--;
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
      // Exclude students who are already in the group
      final isAlreadyAdded = _groupMembers.any((member) => member.upMail == user.upMail);
      if (isAlreadyAdded) return false;
      // Match by name
      return user.fullName.toLowerCase().contains(lowerCasePattern) || user.upMail.toLowerCase().contains(lowerCasePattern);}).take(5); // Limit results for performance
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