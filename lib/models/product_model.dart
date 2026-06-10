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
  final double? price;

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
    this.price,
  });

  String? get imageUrl {
    final raw = image?.trim();
    if (raw == null || raw.isEmpty) return null;

    final uri = Uri.tryParse(raw);
    if (uri != null && uri.hasScheme) return raw;

    return 'https://admin.rasmuspharmaceuticals.com/$raw';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      formattedPrice: json['formatted_price'] ?? '\$0.00',
      image: json['main_image'] ?? json['image'],
      description: json['short_description'] ?? json['description'],
      category: json['category']?['name'] ?? json['category'],
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      reviewCount: json['review_count'] ?? json['reviews_count'],
      inStock: json['in_stock'] ?? json['stock'] != 0,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
    );
  }
}