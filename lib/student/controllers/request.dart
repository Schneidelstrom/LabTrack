import 'package:flutter/material.dart';
import 'package:labtrack/student/models/request_item.dart';

/// Fetching the user's pending requests and handling cancellations for the [RequestView]
class RequestController {
  List<RequestItem> _requests = [];
  List<RequestItem> get requests => _requests;

  Future<void> loadRequests() async {
    await Future.delayed(const Duration(milliseconds: 350));
    _requests = const [
      RequestItem(
        courseCode: 'PHYS-101',
        itemCount: 4,
        requestDate: '25-10-2025',
      ),
      RequestItem(
        courseCode: 'CHEM-205',
        itemCount: 12,
        requestDate: '24-10-2025',
      ),
      RequestItem(
        courseCode: 'BIO-301',
        itemCount: 7,
        requestDate: '24-10-2025',
      ),
    ];
  }

  void cancelRequest(BuildContext context, RequestItem request) {
    print('Cancelling request for ${request.courseCode}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelled request for ${request.courseCode}.'), backgroundColor: Colors.red.shade700,),
    );
  }
}