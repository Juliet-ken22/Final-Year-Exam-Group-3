class Product {
  final int id;
  final String name;
  final String formattedPrice;
  final String? image;
  final String? description;      // ← add this
  final String? category;         // ← add this

  Product({
    required this.id,
    required this.name,
    required this.formattedPrice,
    this.image,
    this.description,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      formattedPrice: json['formatted_price'],
      image: json['main_image'],           // ← main_image from API
      description: json['short_description'], // ← use short_description
      category: json['category']?['name'],    // ← nested category object
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'formatted_price': formattedPrice,
      'main_image': image,
      'short_description': description,
    };
  }
}
