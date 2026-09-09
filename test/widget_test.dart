import 'package:flutter_test/flutter_test.dart';
import 'package:kozzy_flutter/models/product.dart';
import 'package:kozzy_flutter/models/cart_item.dart';

void main() {
  test('Product model parses json correctly', () {
    final json = {
      '_id': 'prod_123',
      'name': 'Kozzy Boxy T-Shirt',
      'description': 'Heavyweight cotton boxy fit t-shirt',
      'price': 18.5,
      'image': ['https://api.kozzy.online/images/tshirt.jpg'],
      'category': 'Men',
      'subCategory': 'Topwear',
      'sizes': ['S', 'M', 'L', 'XL'],
      'bestseller': true,
      'date': 1710000000000,
    };

    final product = Product.fromJson(json);
    expect(product.id, 'prod_123');
    expect(product.name, 'Kozzy Boxy T-Shirt');
    expect(product.price, 18.5);
    expect(product.firstImage, 'https://api.kozzy.online/images/tshirt.jpg');
    expect(product.sizes.length, 4);
    expect(product.bestseller, true);
  });

  test('CartItem calculates line total correctly', () {
    final product = Product(
      id: 'p1',
      name: 'Item',
      description: 'Desc',
      price: 25.0,
      images: [],
      category: 'Men',
      subCategory: 'Tops',
      sizes: ['M'],
    );

    final item = CartItem(
      productId: 'p1',
      size: 'M',
      quantity: 3,
      product: product,
    );

    expect(item.totalPrice, 75.0);
  });
}
