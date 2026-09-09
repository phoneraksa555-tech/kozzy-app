import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../utils/category_types.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/category_section.dart';
import '../widgets/hero_slideshow.dart';
import '../widgets/product_rail.dart';
import '../widgets/promo_grid.dart';
import 'collection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final dept = shop.activeDepartment;
    final products = shop.products.where((p) => productMatchesDepartment(p, dept)).toList();
    final onTrend = products.where(isOnTrendProduct).take(10).toList();
    final bags = products.where(isBagsProduct).take(10).toList();
    final bestsellers = products.where(isBestsellerProduct).take(12).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppTopBar(),
          const ShippingBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: shop.refreshAllCatalog,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  if (shop.catalogError != null && !shop.productsLoading)
                    _CatalogErrorBanner(
                      message: shop.catalogError!,
                      onRetry: shop.refreshAllCatalog,
                    ),
                  const HeroSlideshow(),
                  const SizedBox(height: 16),
                  const CategorySection(),
                  ProductRail(
                    title: 'On-Trend',
                    loading: shop.productsLoading,
                    products: onTrend,
                    onSeeAll: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CollectionScreen(
                          initialCategory: dept.isEmpty ? null : dept,
                          initialPath: 'latest',
                        ),
                      ),
                    ),
                  ),
                  ProductRail(
                    title: 'Accessories',
                    loading: shop.productsLoading,
                    products: bags,
                    onSeeAll: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CollectionScreen(
                          initialCategory: dept.isEmpty ? null : dept,
                          initialType: 'accessories',
                          initialPath: 'bags',
                        ),
                      ),
                    ),
                  ),
                  ProductRail(
                    title: 'Best Sellers',
                    loading: shop.productsLoading,
                    products: bestsellers,
                    onSeeAll: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CollectionScreen(
                          initialCategory: dept.isEmpty ? null : dept,
                          initialPath: 'bestsellers',
                        ),
                      ),
                    ),
                  ),
                  const PromoGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogErrorBanner extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _CatalogErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Could not load the store',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(fontSize: 12, height: 1.35, color: Color(0xFF6B7280))),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('TRY AGAIN'),
          ),
        ],
      ),
    );
  }
}
