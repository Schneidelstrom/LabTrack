class LabItem {
  final String name;
  final int stock;
  final String category;

  const LabItem({
    required this.name,
    required this.stock,
    required this.category,
  });

  bool get isAvailable => stock > 0;
}