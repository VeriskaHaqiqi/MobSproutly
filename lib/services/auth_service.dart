// Login, register, logout, forgot password
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  late final Dio _dio;

  AuthService() {
    _dio = _apiClient.dio; // <-- inisialisasi di constructor
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data['data'];
      final token = data['token'];
      final userJson = data['user'];
      await _apiClient.setToken(token);
      return {
        'success': true,
        'user': User.fromJson(userJson),
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Login failed');
      return {'success': false, 'message': msg};
    }
  }

  // Register User biasa
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/register/user', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'password': password,
        'password_confirmation': password,
      });
      return {'success': true, 'message': response.data['message']};
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Registration failed');
      return {'success': false, 'message': msg};
    }
  }

  // Register Expert (lengkap dengan file upload - nanti terpisah)
  Future<Map<String, dynamic>> registerExpert(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      final response = await _dio.post('/auth/register/expert', data: formData);
      return {'success': true, 'message': response.data['message']};
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Registration failed');
      return {'success': false, 'message': msg};
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await _apiClient.clearToken();
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/auth/forgot-password', data: {'email': email});
      return {'success': true, 'message': response.data['message']};
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Request failed');
      return {'success': false, 'message': msg};
    }
  }

  // Reset password (dengan token dari email)
  Future<Map<String, dynamic>> resetPassword(String email, String token, String password) async {
    try {
      final response = await _dio.post('/auth/reset-password', data: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': password,
      });
      return {'success': true, 'message': response.data['message']};
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Reset failed');
      return {'success': false, 'message': msg};
    }
  }
}