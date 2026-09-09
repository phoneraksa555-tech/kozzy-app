import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/layout.dart';
import '../models/product.dart';
import '../providers/shop_provider.dart';
import '../utils/category_types.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/site_header.dart';

class CollectionScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialType;
  final String? initialQuery;
  final String? initialFilter;
  final String? initialPath;
  final bool openSearch;
  final bool showBack;
  final bool showSiteHeader;

  const CollectionScreen({
    super.key,
    this.initialCategory,
    this.initialType,
    this.initialQuery,
    this.initialFilter,
    this.initialPath,
    this.openSearch = false,
    this.showBack = true,
    this.showSiteHeader = false,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late TextEditingController _searchCtrl;
  late String _category;
  late String? _type;
  String _sortBy = 'Relevant';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery ?? '');
    _category = widget.initialCategory ?? '';
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> _filter(List<Product> all) {
    var list = all.where((p) => productMatchesDepartment(p, _category)).toList();

    if (widget.initialPath == 'latest') {
      list = list.where(isOnTrendProduct).toList();
    } else if (widget.initialPath == 'bags') {
      list = list.where(isBagsProduct).toList();
    } else if (widget.initialPath == 'bestsellers') {
      list = list.where(isBestsellerProduct).toList();
    } else {
      list = list.where((p) => productMatchesType(p, _type)).toList();
    }

    if (widget.initialFilter == 'new_in') {
      list = list.where((p) => p.isNewIn).toList();
    }

    final query = _searchCtrl.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.subCategory.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();
    }

    if (_sortBy == 'Low-High') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'High-Low') {
      list.sort((a, b) => b.price.compareTo(a.price));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final filtered = _filter(shop.products);
    final title = widget.initialPath == 'latest'
        ? 'ON-TREND'
        : widget.initialPath == 'bags'
            ? 'ACCESSORIES'
            : widget.initialPath == 'bestsellers'
                ? 'BEST SELLERS'
                : collectionTitle(_type);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (widget.showSiteHeader)
            SafeArea(bottom: false, child: SiteHeader(showBack: widget.showBack))
          else
            AppTopBar(
              showLogo: false,
              showBack: widget.showBack,
              title: widget.openSearch ? 'Search' : 'Shop',
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.4),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() => _sortBy = val),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'Relevant', child: Text('Relevant')),
                    PopupMenuItem(value: 'Low-High', child: Text('Price: Low to High')),
                    PopupMenuItem(value: 'High-Low', child: Text('Price: High to Low')),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.sort, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              controller: _searchCtrl,
              autofocus: widget.openSearch,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search Kozzy...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final dept in ['', 'Men', 'Women'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(dept.isEmpty ? 'All' : dept),
                      selected: _category == dept,
                      selectedColor: AppConstants.brandBlack,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _category == dept ? Colors.white : AppConstants.brandBlack,
                      ),
                      onSelected: (_) => setState(() => _category = dept),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtered.length} products',
                style: const TextStyle(fontSize: 12, color: AppConstants.brandGray),
              ),
            ),
          ),
          Expanded(
            child: shop.productsLoading
                ? const Center(child: CircularProgressIndicator())
                : shop.catalogError != null && shop.products.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                shop.catalogError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: AppConstants.brandGray),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: shop.refreshAllCatalog,
                                child: const Text('TRY AGAIN'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filtered.isEmpty
                        ? const Center(child: Text('No products match your filter'))
                        : GridView.builder(
                            padding: SiteLayout.pagePadding(context).copyWith(top: 4, bottom: 24),
                            itemCount: filtered.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: SiteLayout.collectionColumns(context),
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.58,
                            ),
                            itemBuilder: (context, i) => ProductCard(product: filtered[i]),
                          ),
          ),
        ],
      ),
    );
  }
}
