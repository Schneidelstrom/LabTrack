enum ReturnStatus {
  partial,
  complete,
}

class ReturnItem {
  final String courseCode;
  final String borrowDate;
  final String returnDate;
  final int quantity;
  final int returnedQuantity;

  const ReturnItem({
    required this.courseCode,
    required this.borrowDate,
    required this.returnDate,
    required this.quantity,
    required this.returnedQuantity,
  }) : assert(returnedQuantity <= quantity, 'Returned quantity cannot exceed borrowed quantity');

  ReturnStatus get status {
    return returnedQuantity >= quantity ? ReturnStatus.complete : ReturnStatus.partial;
  }
}