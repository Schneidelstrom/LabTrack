import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus {
  underReview,
  resolved,
}

class ReportedItem {
  final String reportId;
  final String itemName;
  final String reportDate;
  final ReportStatus status;
  final String reporterUpMail;

  const ReportedItem({
    required this.reportId,
    required this.itemName,
    required this.reportDate,
    required this.status,
    required this.reporterUpMail,
  });

  factory ReportedItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReportedItem(
      reportId: data['reportId'] ?? doc.id,
      itemName: data['itemName'] ?? '',
      reportDate: data['reportDate'] ?? '',
      status: _statusFromString(data['status']),
      reporterUpMail: data['reporterUpMail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'reportId': reportId,
    'itemName': itemName,
    'reportDate': reportDate,
    'status': status == ReportStatus.underReview ? 'under_review' : 'resolved',
    'reporterUpMail': reporterUpMail,
  };
}

ReportStatus _statusFromString(String? statusStr) {
  switch (statusStr?.toLowerCase()) {
    case 'resolved':
      return ReportStatus.resolved;
    case 'under_review':
      return ReportStatus.underReview;
    default:
      return ReportStatus.underReview;
  }
}
