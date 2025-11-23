import 'package:cloud_firestore/cloud_firestore.dart';

enum PenaltyStatus {
  unresolved,
  resolved,
}

class Penalty {
  final String penaltyId;
  final String itemName;
  final String reason;
  final String dateIncurred;
  final double amount;
  final PenaltyStatus status;
  final String penalizedUpMail;


  const Penalty({
    required this.penaltyId,
    required this.itemName,
    required this.reason,
    required this.dateIncurred,
    required this.amount,
    required this.status,
    required this.penalizedUpMail,
  });

  factory Penalty.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Penalty(
      penaltyId: data['penaltyId'] ?? doc.id,
      itemName: data['itemName'] ?? '',
      reason: data['reason'] ?? '',
      dateIncurred: data['dateIncurred'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      penalizedUpMail: data['penalizedUpMail'] ?? '',
      status: PenaltyStatus.values.firstWhere((e) => e.name == data['status'], orElse: () => PenaltyStatus.unresolved,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'penaltyId': penaltyId,
    'itemName': itemName,
    'reason': reason,
    'dateIncurred': dateIncurred,
    'amount': amount,
    'status': status.name,
    'penalizedUpMail': penalizedUpMail,
  };
}
