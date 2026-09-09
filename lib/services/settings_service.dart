import 'api_service.dart';
import '../models/store_collection.dart';

class SettingsService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getPublicSettings() async {
    return await _api.get('/api/settings/public', skipAuth: true);
  }

  Future<List<StoreCollection>> getPublicCategories() async {
    final res = await _api.get('/api/category/public', skipAuth: true);
    if (res['success'] == true && res['categories'] is List) {
      return (res['categories'] as List)
          .whereType<Map>()
          .map((e) => StoreCollection.fromJson(asJsonMap(e)))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> validateCoupon(String code, List<Map<String, dynamic>> items) async {
    return await _api.post('/api/coupon/validate', {
      'code': code,
      'items': items,
    });
  }
}
