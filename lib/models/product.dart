class ProductColor {
  final String name;
  final String hex;
  final String image;
  final List<String> gallery;

  const ProductColor({
    this.name = '',
    this.hex = '',
    this.image = '',
    this.gallery = const [],
  });

  factory ProductColor.fromJson(dynamic json) {
    if (json is String) {
      return ProductColor(name: json, hex: json);
    }
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      List<String> gallery = [];
      final gallerySrc = map['gallery'] ?? map['images'];
      if (gallerySrc is List) {
        gallery = gallerySrc.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      }
      final image = map['image']?.toString() ?? (gallery.isNotEmpty ? gallery.first : '');
      return ProductColor(
        name: map['name']?.toString() ?? '',
        hex: map['hex']?.toString() ?? map['color']?.toString() ?? '',
        image: image,
        gallery: gallery,
      );
    }
    return const ProductColor();
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final int discount;
  final List<String> images;
  final String category;
  final String subCategory;
  final List<String> sizes;
  final List<ProductColor> colors;
  final bool bestseller;
  final bool showInOnTrend;
  final bool showInBags;
  final bool newIn;
  final List<String> badges;
  final int date;
  final String? brand;
  final String? department;
  final dynamic stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.subCategory,
    required this.sizes,
    this.originalPrice = 0,
    this.discount = 0,
    this.colors = const [],
    this.bestseller = false,
    this.showInOnTrend = false,
    this.showInBags = false,
    this.newIn = false,
    this.badges = const [],
    this.date = 0,
    this.brand,
    this.department,
    this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> parseImages(dynamic img) {
      if (img is List) {
        return img.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      } else if (img is String && img.isNotEmpty) {
        return [img];
      }
      return [];
    }

    const colorMetaKeys = {'images', 'hex', 'swatch', 'name', 'gallery', 'image', 'sizes'};

    List<String> parseSizes(dynamic s) {
      if (s is List) {
        return s
            .map((e) {
              if (e is Map) {
                final map = Map<String, dynamic>.from(e);
                return map['size']?.toString() ?? '';
              }
              return e.toString();
            })
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (s is String && s.isNotEmpty) {
        return s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    List<String> sizesFromColors(dynamic c) {
      if (c is! Map) return [];
      final found = <String>{};
      for (final val in c.values) {
        if (val is! Map) continue;
        for (final entry in val.entries) {
          final key = entry.key.toString();
          if (colorMetaKeys.contains(key.toLowerCase())) continue;
          final v = entry.value;
          final isStock = v is num || (v is String && v.isNotEmpty && num.tryParse(v) != null);
          if (isStock) found.add(key.toUpperCase());
        }
      }
      return found.toList();
    }

    double parsePrice(dynamic p) {
      if (p is num) return p.toDouble();
      if (p is String) return double.tryParse(p) ?? 0.0;
      return 0.0;
    }

    int parseDate(dynamic d) {
      if (d is int) return d;
      if (d is String) return int.tryParse(d) ?? 0;
      return 0;
    }

    bool parseBool(dynamic v) => v == true || v == 'true';

    List<ProductColor> parseColors(dynamic c) {
      if (c is List) return c.map(ProductColor.fromJson).toList();
      if (c is Map) {
        return c.entries
            .where((e) => e.key.toString().toLowerCase() != 'default')
            .map((e) {
              final val = e.value;
              if (val is Map) {
                final map = Map<String, dynamic>.from(val);
                map['name'] ??= e.key.toString();
                return ProductColor.fromJson(map);
              }
              return ProductColor(name: e.key.toString());
            })
            .toList();
      }
      return [];
    }

    dynamic parseStock(dynamic raw, dynamic sizesRaw, dynamic colorsRaw) {
      if (raw != null) return raw;
      final sizeStocks = <String, int>{};
      if (sizesRaw is List) {
        for (final e in sizesRaw) {
          if (e is Map) {
            final map = Map<String, dynamic>.from(e);
            final size = map['size']?.toString() ?? '';
            if (size.isNotEmpty && map['stock'] is num) {
              sizeStocks[size] = (map['stock'] as num).toInt();
            }
          }
        }
      }
      if (sizeStocks.isNotEmpty) return sizeStocks;

      final colorStocks = <String, int>{};
      if (colorsRaw is Map) {
        for (final colorEntry in colorsRaw.entries) {
          final val = colorEntry.value;
          if (val is! Map) continue;
          for (final entry in val.entries) {
            final key = entry.key.toString();
            if (colorMetaKeys.contains(key.toLowerCase())) continue;
            if (entry.value is num) {
              final stockKey = '${colorEntry.key}_$key';
              colorStocks[stockKey] = (entry.value as num).toInt();
            }
          }
        }
      }
      if (colorStocks.isNotEmpty) return colorStocks;
      return null;
    }

    List<String> parseBadges(dynamic b) {
      if (b is List) return b.map((e) => e.toString()).toList();
      return [];
    }

    final price = parsePrice(json['price']);
    final original = parsePrice(json['originalPrice']);
    int disc = 0;
    if (json['discount'] is num) {
      disc = (json['discount'] as num).toInt();
    } else if (original > price && price > 0) {
      disc = ((1 - price / original) * 100).round();
    }

    var sizes = parseSizes(json['sizes'] ?? json['size']);
    if (sizes.isEmpty) {
      sizes = sizesFromColors(json['colors']);
    }

    return Product(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: price,
      originalPrice: original,
      discount: disc,
      images: parseImages(json['image'] ?? json['images']),
      category: json['category']?.toString() ?? '',
      subCategory: json['subCategory']?.toString() ?? '',
      sizes: sizes,
      colors: parseColors(json['colors']),
      bestseller: parseBool(json['bestseller']),
      showInOnTrend: parseBool(json['showInOnTrend']),
      showInBags: parseBool(json['showInBags']) || parseBool(json['showInKozzy']),
      newIn: parseBool(json['newIn']),
      badges: parseBadges(json['badges']),
      date: parseDate(json['date']),
      brand: json['brand']?.toString(),
      department: json['department']?.toString(),
      stock: parseStock(json['stock'], json['sizes'], json['colors']),
    );
  }

  String get firstImage {
    if (images.isNotEmpty) return images.first;
    if (colors.isNotEmpty) {
      if (colors.first.gallery.isNotEmpty) return colors.first.gallery.first;
      if (colors.first.image.isNotEmpty) return colors.first.image;
    }
    return '';
  }

  bool get hasDiscount => discount > 0 && originalPrice > price;

  bool get isSoldOut {
    if (stock == null) return false;
    if (stock is Map) {
      final values = (stock as Map).values;
      if (values.isEmpty) return false;
      return values.every((v) => v is num && v <= 0);
    }
    if (stock is num) return stock <= 0;
    return false;
  }

  bool get isNewIn {
    if (newIn) return true;
    return badges.any((b) => RegExp('new', caseSensitive: false).hasMatch(b));
  }

  bool isAvailableInSize(String size) {
    if (stock == null) return true;
    if (stock is Map) {
      final want = size.toLowerCase();
      num? matched;
      (stock as Map).forEach((key, val) {
        final k = key.toString().toLowerCase();
        if (k == want || k.endsWith('_$want')) {
          if (val is num) matched = (matched ?? 0) + val;
        }
      });
      if (matched != null) return matched! > 0;
      return true;
    }
    if (stock is num) return stock > 0;
    return true;
  }
}
