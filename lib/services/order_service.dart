import 'api_service.dart';
import '../models/order.dart';

class OrderService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> orderData) async {
    return await _api.post('/api/order/create', {
      ...orderData,
      'paymentMethod': orderData['paymentMethod'] ?? 'COD',
      'paymentSuccess': orderData['paymentSuccess'] ?? true,
    });
  }

  Future<List<Order>> fetchUserOrders() async {
    final res = await _api.post('/api/order/userorders', {});
    if (res['success'] == true && res['orders'] is List) {
      final list = (res['orders'] as List)
          .whereType<Map>()
          .map((item) => Order.fromJson(asJsonMap(item)))
          .toList();
      return list.reversed.toList();
    }
    return [];
  }

  Future<Order?> trackOrder(String orderId) async {
    final res = await _api.post('/api/order/track', {'orderId': orderId});
    if (res['success'] == true && res['order'] != null) {
      return Order.fromJson(asJsonMap(res['order']));
    }
    return null;
  }
}
