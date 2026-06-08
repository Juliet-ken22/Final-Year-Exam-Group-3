class CartModel {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  // Convert object → Map (useful for API / local storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  // Convert Map → object
  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id'],
      productId: map['productId'],
      name: map['name'],
      price: map['price'].toDouble(),
      imageUrl: map['imageUrl'],
      quantity: map['quantity'] ?? 1,
    );
  }

  // Total price for this item
  double get totalPrice => price * quantity;
}