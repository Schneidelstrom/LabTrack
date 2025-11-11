import 'package:flutter/material.dart';
import 'package:labtrack/student/models/group_member.dart';
import 'package:labtrack/student/models/course.dart';
import 'package:labtrack/student/screens/dashboard.dart';

class _CartItem {
  String name;
  int quantity;

  _CartItem({required this.name, this.quantity = 1});
}

class StudentCheckout extends StatefulWidget {
  final Set<String> selectedItems;
  final Set<GroupMember> initialGroupMembers;
  final Course? initialCourse;

  const StudentCheckout({super.key, required this.selectedItems, required this.initialGroupMembers, this.initialCourse});

  @override
  State<StudentCheckout> createState() => _StudentCheckoutState();
}

class _StudentCheckoutState extends State<StudentCheckout> {
  late List<_CartItem> _cartItems;
  final Set<GroupMember> _groupMembers = {};
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<_CheckoutBarState> _checkoutBarKey = GlobalKey<_CheckoutBarState>();

  final List<GroupMember> _allStudents = [
    GroupMember(email: 'asmith@up.edu.ph', name: 'Alice Smith'),
    GroupMember(email: 'bjohnson@up.edu.ph', name: 'Bob Johnson'),
    GroupMember(email: 'cbrown@up.edu.ph', name: 'Charlie Brown'),
    GroupMember(email: 'dprince@up.edu.ph', name: 'Diana Prince'),
  ];

  Future<Iterable<GroupMember>> _searchGroupMembers(String pattern) async {
    if (pattern.isEmpty) return const Iterable.empty();

    final lowerCasePattern = pattern.toLowerCase();

    return _allStudents.where((student) {
      return (student.email.toLowerCase().contains(lowerCasePattern) || student.name.toLowerCase().contains(lowerCasePattern)) && !_groupMembers.any((member) => member.email == student.email);
    }).take(5);
  }

  void _addGroupMember(GroupMember member) {
    setState(() {
      _groupMembers.add(member);
      _emailController.clear();
    });
  }

  void _removeGroupMember(GroupMember member) {
    setState(() {
      _groupMembers.remove(member);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cartItems = widget.selectedItems.map((name) => _CartItem(name: name)).toList();
    _groupMembers.addAll(widget.initialGroupMembers);
  }

  void _incrementQuantity(int index) {
    setState(() {
      _cartItems[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Checkout'),
        titleTextStyle: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        shadowColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop({
            'groupMembers': _groupMembers,
            'courseCode': _checkoutBarKey.currentState?._selectedCourse,
          }),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _GroupMemberSearch(
              groupMembers: _groupMembers,
              onAddGroupMember: _addGroupMember,
              onRemoveGroupMember: _removeGroupMember,
              searchGroupMembers: _searchGroupMembers,
            ),
            const Text(
              'Selected Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  final item = _cartItems[index];
                  return _CartItemCard(
                    item: item,
                    onIncrement: () => _incrementQuantity(index),
                    onDecrement: () => _decrementQuantity(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CheckoutBar(groupMembers: _groupMembers, key: _checkoutBarKey, initialCourse: widget.initialCourse),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final _CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            _QuantityStepper(
              quantity: item.quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: OutlinedButton(
            onPressed: onDecrement,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Icon(Icons.remove, color: Color(0xFF0D47A1)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            quantity.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 36,
          height: 36,
          child: OutlinedButton(
            onPressed: onIncrement,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Icon(Icons.add, color: Color(0xFF0D47A1)),
          ),
        ),
      ],
    );
  }
}

class _CheckoutBar extends StatefulWidget {
  final Set<GroupMember> groupMembers;
  final Course? initialCourse;

  const _CheckoutBar({super.key, required this.groupMembers, this.initialCourse});

  @override
  State<_CheckoutBar> createState() => _CheckoutBarState();
}

class _CheckoutBarState extends State<_CheckoutBar> {
  final List<Course> _allCourses = const [
    Course(code: 'BIO-107', title: 'General Biology I'),
    Course(code: 'CMSC-189', title: 'Introduction to Computer Science'),
    Course(code: 'ECO-101', title: 'Basic Economics'),
    Course(code: 'CHEM-102', title: 'General Chemistry'),
    Course(code: 'PHYSICS-103', title: 'College Physics'),
    Course(code: 'MATH-154', title: 'Differential Calculus'),
    Course(code: 'BIO-67', title: 'Cellular Biology'),
    Course(code: 'BIOCHEM-1', title: 'Fundamentals of Biochemistry'),
    Course(code: 'SCIENCE-10', title: 'Introduction to Science'),
  ];

  Course? _selectedCourse;

  @override
  void initState() {
    super.initState();
    _selectedCourse = widget.initialCourse ?? _allCourses.first;
  }

  void _handleCheckout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Text(
                  'Confirm borrowing items for\n${_selectedCourse?.code} (${_selectedCourse?.title})?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const StudentDashboard(),
        ),
            (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Borrow Request Submitted Successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 12,
            offset: const Offset(0, -2),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<Course?>(
            value: _selectedCourse,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            underline: Container(
              height: 2,
              color: Colors.blue,
            ),
            onChanged: (Course? newCourse) {
              setState(() {
                _selectedCourse = newCourse;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected Course: ${_selectedCourse?.title}')),
                );
              });
            },
            items: _allCourses.map<DropdownMenuItem<Course>>((Course course) {
              return DropdownMenuItem<Course>(
                value: course,
                child: Text(course.code),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: _handleCheckout,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Checkout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupMemberSearch extends StatelessWidget {
  final Set<GroupMember> groupMembers;
  final Function(GroupMember) onAddGroupMember;
  final Function(GroupMember) onRemoveGroupMember;
  final Future<Iterable<GroupMember>> Function(String) searchGroupMembers;

  const _GroupMemberSearch({
    required this.groupMembers,
    required this.onAddGroupMember,
    required this.onRemoveGroupMember,
    required this.searchGroupMembers,
  });

  String _getEmailPrefix(String email) {
    const suffix = '@up.edu.ph';
    if (email.endsWith(suffix)) {
      return email.substring(0, email.length - suffix.length);
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Group Members',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1)
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<GroupMember>(
          displayStringForOption: (option) => _getEmailPrefix(option.email),
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.isEmpty) {
              return const Iterable.empty();
            }
            return await searchGroupMembers(textEditingValue.text);
          },
          onSelected: (GroupMember selection) {
            onAddGroupMember(selection);
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (String value) => onFieldSubmitted(),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Search Group Member by UPMail',
                suffixText: '@up.edu.ph',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: SizedBox(
                  width: 300,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final GroupMember option = options.elementAt(index);
                      return ListTile(
                        title: Text(option.name),
                        subtitle: Text(option.email),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        if (groupMembers.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: groupMembers.map((member) {
              return Chip(
                label: Text(member.name),
                deleteIcon: const Icon(Icons.cancel, size: 18),
                onDeleted: () => onRemoveGroupMember(member),
                backgroundColor: Colors.blue.shade50,
                labelStyle: TextStyle(color: Colors.blue.shade900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.blue.shade100),
                ),
              );
            }).toList(),
          ),
        const Divider(height: 32),
      ],
    );
  }
}