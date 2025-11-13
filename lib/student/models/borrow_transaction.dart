class BorrowTransaction {
  final String transactionId;
  final String courseCode;
  final String courseName;
  final String borrowerName;
  final String dateBorrowed;
  final String deadlineDate;
  final List<String> groupMembers;
  final List<Map<String, dynamic>> borrowedItems;

  const BorrowTransaction({
    required this.transactionId,
    required this.courseCode,
    required this.courseName,
    required this.borrowerName,
    required this.dateBorrowed,
    required this.deadlineDate,
    required this.groupMembers,
    required this.borrowedItems,
  });
}