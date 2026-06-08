class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
  });

  // Convert object → Map (useful for API / database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  // Convert Map → object
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'],
    );
  }
}