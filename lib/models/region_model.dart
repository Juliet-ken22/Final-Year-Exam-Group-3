class Region {
  final int id;
  final String name;

  Region({required this.id, required this.name});

  factory Region.fromJson(Map<String, dynamic> json) =>
      Region(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class Town {
  final int id;
  final String name;
  final int regionId;

  Town({required this.id, required this.name, required this.regionId});

  factory Town.fromJson(Map<String, dynamic> json) => Town(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        regionId: json['region_id'] ?? 0,
      );
}