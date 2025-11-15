enum PenaltyStatus {
  unresolved,
  resolved,
}

class Penalty {
  final String itemName;
  final String reason;
  final String dateIncurred;
  final double amount;
  final PenaltyStatus status;

  const Penalty({
    required this.itemName,
    required this.reason,
    required this.dateIncurred,
    required this.amount,
    required this.status,
  });
}