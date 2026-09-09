import 'api_service.dart';
import '../models/product.dart';

class ProductService {
  final ApiService _api = ApiService();

  Future<List<Product>> getProducts() async {
    final res = await _api.get('/api/product/list', skipAuth: true);
    final raw = res['products'];
    if (res['success'] == true && raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Product.fromJson(asJsonMap(item)))
          .toList()
          .reversed
          .toList();
    }
    return [];
  }

  Future<Product?> getSingleProduct(String productId) async {
    final res = await _api.post('/api/product/single', {'productId': productId}, skipAuth: true);
    if (res['success'] == true && res['product'] != null) {
      return Product.fromJson(asJsonMap(res['product']));
    }
    return null;
  }
}
