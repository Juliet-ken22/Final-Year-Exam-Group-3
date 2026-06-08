class Product {
  final int id;
  final String name;
  final String formattedPrice;
  final String? image;
  final String? description;
  final String? category;
  final double? rating;
  final int? reviewCount;
  final bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.formattedPrice,
    this.image,
    this.description,
    this.category,
    this.rating,
    this.reviewCount,
    this.inStock = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      formattedPrice: json['formatted_price'] ?? '',
      image: json['main_image'],
      description: json['short_description'],
      category: json['category']?['name'],
      rating: double.tryParse(json['rating']?.toString() ?? ''),
      reviewCount: json['review_count'] ?? json['reviews_count'],
      inStock: json['in_stock'] ?? json['stock'] != 0,
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