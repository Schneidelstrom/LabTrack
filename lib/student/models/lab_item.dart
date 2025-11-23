import 'package:cloud_firestore/cloud_firestore.dart';

class LabItem {
  final String id;
  final String name;
  final int stock;
  final String category;

  const LabItem({
    required this.id,
    required this.name,
    required this.stock,
    required this.category,
  });

  bool get isAvailable => stock > 0;

  factory LabItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LabItem(
      id: doc.id,
      name: data['name'] ?? '',
      stock: data['stock'] ?? 0,
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'stock': stock,
    'category': category,
  };
}