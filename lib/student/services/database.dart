import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labtrack/student/models/user.dart';
import 'package:labtrack/student/models/lab_item.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';
import 'package:labtrack/student/models/penalty_item.dart';
import 'package:labtrack/student/models/report_item.dart';
import 'package:labtrack/student/models/return_item.dart';
import 'package:labtrack/student/models/request_item.dart';
import 'package:labtrack/student/models/waitlist_item.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/models/course.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Getter Methods

  Future<List<UserModel>> getUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot = await _firestore.collection('users').where('upmail', isEqualTo: email).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  Future<List<LabItem>> getLabItems() async {
    final snapshot = await _firestore.collection('lab_items').get();
    return snapshot.docs.map((doc) => LabItem.fromFirestore(doc)).toList();
  }

  Future<List<Course>> getCourses() async {
    final snapshot = await _firestore.collection('courses').get();
    return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
  }

  /// Fetches borrow transactions where the user is listed as a group member
  Future<List<BorrowTransaction>> getBorrowTransactions(String userEmail) async {
    final snapshot = await _firestore.collection('borrow_transactions').where('groupMembers', arrayContains: userEmail).orderBy('dateBorrowed', descending: true).get();
    return snapshot.docs.map((doc) => BorrowTransaction.fromFirestore(doc)).toList();
  }

  Future<List<Penalty>> getPenalties(String userEmail) async {
    final snapshot = await _firestore.collection('penalties').where('penalizedUpMail', isEqualTo: userEmail).get();
    return snapshot.docs.map((doc) => Penalty.fromFirestore(doc)).toList();
  }

  Future<List<ReportedItem>> getReportedItems(String userEmail) async {
    final snapshot = await _firestore.collection('reported_items').where('reporterUpMail', isEqualTo: userEmail).orderBy('reportDate', descending: true).get();
    return snapshot.docs.map((doc) => ReportedItem.fromFirestore(doc)).toList();
  }

  Future<List<ReturnItem>> getReturnItems(String userEmail) async {
    final snapshot = await _firestore.collection('return_items').where('returnerUpMail', isEqualTo: userEmail).orderBy('returnDate', descending: true).get();
    return snapshot.docs.map((doc) => ReturnItem.fromFirestore(doc)).toList();
  }

  Future<List<RequestItem>> getRequests(String userEmail) async {
    final snapshot = await _firestore.collection('request_items').where('requesterUpMail', isEqualTo: userEmail).orderBy('requestDate', descending: true).get();
    return snapshot.docs.map((doc) => RequestItem.fromFirestore(doc)).toList();
  }

  Future<List<WaitlistItem>> getWaitlistItems(String userEmail) async {
    final snapshot = await _firestore.collection('waitlist_items').where('waitlistedUpMail', isEqualTo: userEmail).get();
    return snapshot.docs.map((doc) => WaitlistItem.fromFirestore(doc)).toList();
  }

  Future<List<BorrowTransaction>> getAllBorrowTransactions() async {
    final snapshot = await _firestore.collection('borrow_transactions').orderBy('dateBorrowed', descending: true).get();
    return snapshot.docs.map((doc) => BorrowTransaction.fromFirestore(doc)).toList();
  }

  Future<void> deleteBorrowTransaction(String borrowId) async {
    await _firestore.collection('borrow_transactions').doc(borrowId).delete();
  }

  /// Setter Methods

  /// Adds a new borrow transaction and updates item stocks
  Future<void> addBorrowTransaction(BorrowTransaction transaction) async {
    final batch = _firestore.batch();
    final transactionRef = _firestore.collection('borrow_transactions').doc(transaction.borrowId);
    batch.set(transactionRef, transaction.toJson());

    for (var item in transaction.borrowedItems) {
      await _updateStockInBatch(batch, item.name, -item.quantity);
    }
    await batch.commit();
  }

  Future<void> addReport(ReportedItem report) async {
    await _firestore.collection('reported_items').doc(report.reportId).set(report.toJson());
  }

  Future<void> cancelRequest(String requestId) async {
    await _firestore.collection('request_items').doc(requestId).delete();
  }

  Future<void> updatePenaltyStatus(String penaltyId, PenaltyStatus newStatus) async {
    await _firestore.collection('penalties').doc(penaltyId).update({'status': newStatus.name});
  }

  Future<void> cancelWaitlistReservation(String waitlistId) async {
    await _firestore.collection('waitlist_items').doc(waitlistId).delete();
  }

  Future<void> _updateStockInBatch(WriteBatch batch, String itemName, int quantityChange) async {
    final itemQuery = await _firestore.collection('lab_items').where('name', isEqualTo: itemName).limit(1).get();
    if (itemQuery.docs.isNotEmpty) {
      final itemDocRef = itemQuery.docs.first.reference;
      batch.update(itemDocRef, {'stock': FieldValue.increment(quantityChange)});
    } else {
      print("Warning: Item '$itemName' not found. Stock not updated.");
    }
  }

  Future<void> processReturn(ReturnItem returnRecord, List<CartItem> returnedItems) async {
    try {
      final batch = _firestore.batch();
      final returnRef = _firestore.collection('return_items').doc(
          returnRecord.returnId);
      batch.set(returnRef, returnRecord.toJson());
      for (var item in returnedItems) {
        await _updateStockInBatch(
            batch, item.name, item.quantity);
      }

      await batch.commit();
    } catch (e) {
      print("Error in processReturn: $e");
      rethrow;
    }
  }
}