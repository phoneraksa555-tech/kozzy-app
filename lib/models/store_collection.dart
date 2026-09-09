class StoreCollection {
  final String id;
  final String name;
  final String slug;
  final String kind;
  final String image;
  final String imageWomen;
  final int sortOrder;
  final bool showOnStorefront;

  const StoreCollection({
    required this.id,
    required this.name,
    required this.slug,
    this.kind = 'collection',
    this.image = '',
    this.imageWomen = '',
    this.sortOrder = 999,
    this.showOnStorefront = true,
  });

  factory StoreCollection.fromJson(Map<String, dynamic> json) {
    return StoreCollection(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: (json['slug']?.toString() ?? json['name']?.toString() ?? '')
          .toLowerCase()
          .trim(),
      kind: json['kind']?.toString() ?? 'collection',
      image: json['image']?.toString() ?? '',
      imageWomen: json['imageWomen']?.toString() ?? '',
      sortOrder: json['sortOrder'] is num ? (json['sortOrder'] as num).toInt() : 999,
      showOnStorefront: json['showOnStorefront'] != false,
    );
  }
}
