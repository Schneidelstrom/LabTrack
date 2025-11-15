enum WaitlistStatus {
  inQueue,
  readyForPickup,
}

class WaitlistItem {
  final String name;
  final String courseCode;
  final String statusMessage;
  final WaitlistStatus status;

  const WaitlistItem({
    required this.name,
    required this.courseCode,
    required this.statusMessage,
    required this.status,
  });
}