import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user_model.dart';

class ExpertService {
  final ApiClient _apiClient = ApiClient();
  late final Dio _dio;

  ExpertService() {
    _dio = _apiClient.dio;
  }

  // Get list of experts (Public)
  Future<Map<String, dynamic>> getExperts({int page = 1, String? search}) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get('/experts', queryParameters: queryParams);
      final listJson = response.data['data']['data'] as List;
      final experts = listJson.map((json) => User.fromJson(json)).toList();
      final lastPage = response.data['data']['last_page'] ?? 1;

      return {
        'success': true,
        'experts': experts,
        'lastPage': lastPage,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load experts');
      return {'success': false, 'message': msg};
    }
  }

  // Get expert details
  Future<Map<String, dynamic>> getExpert(int id) async {
    try {
      final response = await _dio.get('/experts/$id');
      return {
        'success': true,
        'expert': User.fromJson(response.data['data']),
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load expert details');
      return {'success': false, 'message': msg};
    }
  }

  // Get income history for logged-in expert
  Future<Map<String, dynamic>> getIncomeHistory({int page = 1}) async {
    try {
      final response = await _dio.get('/experts/profile/income-history', queryParameters: {'page': page});
      return {
        'success': true,
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load income history');
      return {'success': false, 'message': msg};
    }
  }
}
