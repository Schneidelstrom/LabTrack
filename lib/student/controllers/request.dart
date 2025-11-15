import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:labtrack/student/models/request_item.dart';

/// Fetching the user's pending requests and handling cancellations for the [RequestView]
class RequestController {
  List<RequestItem> _requests = [];
  List<RequestItem> get requests => _requests;

  Future<void> loadRequests() async {
    final String jsonString = await rootBundle.loadString('lib/database/request_items.json');
    final Map<String, dynamic> decodedJson = json.decode(jsonString);
    final List<dynamic> requestListJson = decodedJson['request_items'];

    _requests = requestListJson.map((jsonItem) {
      return RequestItem(
        courseCode: jsonItem['courseCode'],
        itemCount: jsonItem['itemCount'],
        requestDate: jsonItem['requestDate'],
      );
    }).toList();
  }

  void cancelRequest(BuildContext context, RequestItem request) {
    print('Cancelling request for ${request.courseCode}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelled request for ${request.courseCode}.'), backgroundColor: Colors.red.shade700,),
    );
  }
}