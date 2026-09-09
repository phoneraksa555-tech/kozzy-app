import 'api_service.dart';

class PaymentService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> createPaywayQr(Map<String, dynamic> paymentData) async {
    return await _api.post('/api/payment/payway/qr', paymentData);
  }

  Future<Map<String, dynamic>> checkPaywayStatus(String transactionId) async {
    return await _api.get('/api/payment/payway/status/$transactionId');
  }
}
