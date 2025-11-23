class CartItem {
  final String name;
  final int quantity;

  const CartItem({
    required this.name,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
  };
}