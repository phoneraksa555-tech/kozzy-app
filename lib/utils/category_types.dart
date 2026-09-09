import '../models/product.dart';

class TypeMeta {
  final String title;
  final List<String> subCategories;
  final List<String> nameIncludes;

  const TypeMeta({
    required this.title,
    required this.subCategories,
    required this.nameIncludes,
  });
}

const typeMeta = {
  'all': TypeMeta(title: 'All', subCategories: ['all'], nameIncludes: []),
  'tops': TypeMeta(
    title: 'Tops',
    subCategories: ['tops', 'topwear'],
    nameIncludes: [
      'tops', 'top', 't-shirt', 't shirt', 'tee', 'blouse', 'shirt',
      'hoodie', 'sweater', 'tank', 'crop top',
    ],
  ),
  'boxy': TypeMeta(title: 'Boxy', subCategories: ['boxy'], nameIncludes: ['boxy']),
  'long sleeve': TypeMeta(
    title: 'Long Sleeve',
    subCategories: ['long sleeve', 'longsleeve'],
    nameIncludes: ['long sleeve', 'longsleeve'],
  ),
  'bags': TypeMeta(
    title: 'Accessories',
    subCategories: ['bags', 'bag', 'accessories', 'accessory'],
    nameIncludes: [
      'bag', 'bags', 'tote', 'purse', 'handbag', 'backpack', 'clutch',
      'shoulder bag', 'hat', 'cap', 'belt', 'accessory', 'accessories',
    ],
  ),
  'accessories': TypeMeta(
    title: 'Accessories',
    subCategories: ['bags', 'bag', 'accessories', 'accessory'],
    nameIncludes: [
      'bag', 'bags', 'tote', 'purse', 'handbag', 'backpack', 'clutch',
      'shoulder bag', 'hat', 'cap', 'belt', 'accessory', 'accessories',
    ],
  ),
};

bool _isAllSubCategory(String sub) => sub.toLowerCase() == 'all';

bool nameHasKeyword(String name, String keyword) {
  final n = name.toLowerCase();
  final k = keyword.toLowerCase();
  if (k.isEmpty) return false;
  if (k.contains(' ')) return n.contains(k);
  final escaped = RegExp.escape(k);
  return RegExp('(^|[^a-z0-9])$escaped([^a-z0-9]|\$)', caseSensitive: false).hasMatch(n);
}

String collectionTitle(String? typeParam) {
  if (typeParam == null || typeParam.isEmpty || typeParam.toLowerCase() == 'all') {
    return 'ALL COLLECTIONS';
  }
  final meta = typeMeta[typeParam.toLowerCase()];
  if (meta != null) return meta.title.toUpperCase();
  return typeParam.toUpperCase();
}

bool productMatchesType(Product product, String? typeParam) {
  if (typeParam == null || typeParam.isEmpty) return true;
  final key = typeParam.toLowerCase();
  if (key == 'all') return true;
  if (_isAllSubCategory(product.subCategory)) return true;

  final normalized = key == 'topwear'
      ? 'tops'
      : key == 'bag'
          ? 'bags'
          : key;

  final meta = typeMeta[normalized];
  if (meta == null) {
    final sub = product.subCategory.toLowerCase();
    if (sub == key || sub == typeParam.toLowerCase()) return true;
    return nameHasKeyword(product.name, key);
  }

  final sub = product.subCategory.toLowerCase();
  if (meta.subCategories.contains(sub)) return true;
  return meta.nameIncludes.any((kw) => nameHasKeyword(product.name, kw));
}

bool productMatchesDepartment(Product product, String? category) {
  if (category == null || category.isEmpty) return true;
  final key = category.toLowerCase();
  final cat = product.category.toLowerCase();
  return cat == key ||
      cat == 'unisex' ||
      cat == 'both' ||
      cat == 'men & women' ||
      cat == 'all';
}

bool isOnTrendProduct(Product p) => p.showInOnTrend;

bool isBagsProduct(Product p) => p.showInBags;

bool isBestsellerProduct(Product p) {
  if (p.bestseller) return true;
  return p.badges.any((b) => b.toLowerCase().replaceAll(RegExp(r'[-_ ]'), '') == 'bestseller');
}
