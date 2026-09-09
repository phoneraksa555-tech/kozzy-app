class MenuNavItem {
  final String label;
  final String? type;
  final String? query;
  final String? filter;
  final String? path;
  final String imageKey;

  const MenuNavItem({
    required this.label,
    this.type,
    this.query,
    this.filter,
    this.path,
    required this.imageKey,
  });
}

class MenuNavCategory {
  final String id;
  final String label;
  final List<MenuNavItem> items;

  const MenuNavCategory({
    required this.id,
    required this.label,
    required this.items,
  });
}

const menuTabs = ['MEN', 'WOMEN'];

const navCategories = [
  MenuNavCategory(
    id: 'new_in',
    label: 'New In',
    items: [
      MenuNavItem(label: 'All', filter: 'new_in', type: 'all', imageKey: 'all'),
      MenuNavItem(label: 'New In Boxy', filter: 'new_in', type: 'boxy', imageKey: 'boxy'),
      MenuNavItem(label: 'New In Long Sleeve', filter: 'new_in', type: 'long sleeve', imageKey: 'long sleeve'),
      MenuNavItem(label: 'New In Tops', filter: 'new_in', type: 'tops', imageKey: 'tops'),
      MenuNavItem(label: 'New In Accessories', filter: 'new_in', type: 'accessories', imageKey: 'bags'),
    ],
  ),
  MenuNavCategory(
    id: 'clothing',
    label: 'Clothing',
    items: [
      MenuNavItem(label: 'All', type: 'all', imageKey: 'all'),
      MenuNavItem(label: 'Boxy', type: 'boxy', imageKey: 'boxy'),
      MenuNavItem(label: 'Long Sleeve', type: 'long sleeve', imageKey: 'long sleeve'),
      MenuNavItem(label: 'Tops', type: 'tops', imageKey: 'tops'),
      MenuNavItem(label: 'Accessories', type: 'accessories', imageKey: 'bags'),
    ],
  ),
  MenuNavCategory(
    id: 'accessories',
    label: 'Accessories',
    items: [
      MenuNavItem(label: 'All Accessories', type: 'accessories', imageKey: 'bags'),
      MenuNavItem(label: 'Bags', type: 'accessories', imageKey: 'bags'),
      MenuNavItem(label: 'Caps', query: 'cap', imageKey: 'caps'),
    ],
  ),
  MenuNavCategory(
    id: 'collections',
    label: 'Collections',
    items: [
      MenuNavItem(label: 'All Collections', type: 'all', imageKey: 'all'),
      MenuNavItem(label: 'On-Trend', path: 'latest', imageKey: 'all'),
      MenuNavItem(label: 'Accessories', type: 'accessories', imageKey: 'bags'),
      MenuNavItem(label: 'Best Sellers', path: 'bestsellers', imageKey: 'tops'),
    ],
  ),
];

String deptToCategory(String dept) {
  final key = dept.toUpperCase();
  if (key == 'MEN') return 'Men';
  if (key == 'WOMEN') return 'Women';
  if (key.isEmpty) return '';
  return key[0] + key.substring(1).toLowerCase();
}
