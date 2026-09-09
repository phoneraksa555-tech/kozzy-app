import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login(String email, String password, {String? turnstileToken}) async {
    return await _api.post(
      '/api/user/login',
      {
        'email': email,
        'password': password,
        'turnstileToken': turnstileToken ?? 'dev-token',
      },
      skipAuth: true,
    );
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, {String? turnstileToken}) async {
    return await _api.post(
      '/api/user/register',
      {
        'name': name,
        'email': email,
        'password': password,
        'turnstileToken': turnstileToken ?? 'dev-token',
      },
      skipAuth: true,
    );
  }

  Future<Map<String, dynamic>> googleAuth(String code, {String? turnstileToken}) async {
    return await _api.post(
      '/api/user/google',
      {
        'code': code,
        'turnstileToken': turnstileToken ?? 'dev-token',
      },
      skipAuth: true,
    );
  }

  Future<Map<String, dynamic>> verifyRegisterOtp(String email, String code) async {
    return await _api.post(
      '/api/user/verify-register-otp',
      {'email': email, 'code': code},
      skipAuth: true,
    );
  }

  Future<Map<String, dynamic>> resendRegisterOtp(String email) async {
    return await _api.post(
      '/api/user/resend-register-otp',
      {'email': email},
      skipAuth: true,
    );
  }

  Future<Map<String, dynamic>> getProfile() async {
    return await _api.get('/api/user/profile');
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await _api.put('/api/user/profile', data);
  }

  Future<Map<String, dynamic>> sendEmailVerification() async {
    return await _api.post('/api/user/send-verification-email', {});
  }

  Future<Map<String, dynamic>> verifyEmailCode(String code) async {
    return await _api.post('/api/user/verify-email', {'code': code});
  }
}
