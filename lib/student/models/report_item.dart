enum ReportStatus {
  underReview,
  resolved,
}

class ReportedItem {
  final String itemName;
  final String reportDate;
  final ReportStatus status;

  const ReportedItem({
    required this.itemName,
    required this.reportDate,
    required this.status,
  });
}