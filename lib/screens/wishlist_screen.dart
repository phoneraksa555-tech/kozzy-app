import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/shop_provider.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/product_card.dart';
import 'collection_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final products = shop.products.where((p) => shop.wishlist.contains(p.id)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppTopBar(showLogo: false, title: 'Wishlist'),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bookmark_border, size: 48, color: Colors.black54),
                          const SizedBox(height: 16),
                          const Text('Your Wishlist is Empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          const Text(
                            'Save items you love by tapping the heart icon on any product.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppConstants.brandGray),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CollectionScreen()),
                              );
                            },
                            child: const Text('START BROWSING'),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.58,
                    ),
                    itemBuilder: (context, i) => ProductCard(product: products[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
