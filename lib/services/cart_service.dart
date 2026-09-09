import 'api_service.dart';

class CartService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> fetchCart() async {
    return await _api.post('/api/cart/get', {});
  }

  Future<Map<String, dynamic>> addToCart(String itemId, String size) async {
    return await _api.post('/api/cart/add', {'itemId': itemId, 'size': size});
  }

  Future<Map<String, dynamic>> updateCart(String itemId, String size, int quantity) async {
    return await _api.post('/api/cart/update', {
      'itemId': itemId,
      'size': size,
      'quantity': quantity,
    });
  }
}
