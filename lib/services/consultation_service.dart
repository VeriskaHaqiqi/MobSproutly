import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user_model.dart';
import '../models/consultation_model.dart';
import '../models/payment_model.dart';

class ConsultationService {
  final ApiClient _apiClient = ApiClient();
  late final Dio _dio;

  ConsultationService() {
    _dio = _apiClient.dio;
  }

  // Get all experts
  Future<Map<String, dynamic>> getExperts({
    int page = 1,
    String? search,
    bool availableNow = false,
    bool topRated = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (availableNow) queryParams['available_now'] = 'true';
      if (topRated) queryParams['top_rated'] = 'true';

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
  Future<Map<String, dynamic>> getExpertDetail(int id) async {
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

  // Start a consultation (user)
  Future<Map<String, dynamic>> createConsultation({required int expertId, String? topic}) async {
    try {
      final response = await _dio.post('/consultations', data: {
        'expert_id': expertId,
        'topic': topic,
      });

      final consultation = Consultation.fromJson(response.data['data']['consultation']);
      final payment = Payment.fromJson(response.data['data']['payment']);
      final expertBank = response.data['data']['expert_bank'];

      return {
        'success': true,
        'consultation': consultation,
        'payment': payment,
        'expertBank': expertBank,
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to create consultation');
      return {'success': false, 'message': msg};
    }
  }

  // Upload proof of payment (user)
  Future<Map<String, dynamic>> uploadPaymentProof({
    required int consultationId,
    required String paymentProofPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'payment_proof': await MultipartFile.fromFile(
          paymentProofPath,
          filename: paymentProofPath.split('/').last,
        ),
      });

      final response = await _dio.post('/consultations/$consultationId/upload-proof', data: formData);

      return {
        'success': true,
        'consultation': Consultation.fromJson(response.data['data']['consultation']),
        'payment': Payment.fromJson(response.data['data']['payment']),
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to upload payment proof');
      return {'success': false, 'message': msg};
    }
  }

  // Get user consultations history
  Future<Map<String, dynamic>> getUserConsultations({int page = 1, String? status}) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _dio.get('/consultations', queryParameters: queryParams);
      final listJson = response.data['data']['data'] as List;
      final consultations = listJson.map((json) => Consultation.fromJson(json)).toList();
      final lastPage = response.data['data']['last_page'] ?? 1;

      return {
        'success': true,
        'consultations': consultations,
        'lastPage': lastPage,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load consultations');
      return {'success': false, 'message': msg};
    }
  }

  // Get expert consultations queue/list
  Future<Map<String, dynamic>> getExpertConsultations({int page = 1, String? status}) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _dio.get('/consultations/expert/list', queryParameters: queryParams);
      final listJson = response.data['data']['data'] as List;
      final consultations = listJson.map((json) => Consultation.fromJson(json)).toList();
      final lastPage = response.data['data']['last_page'] ?? 1;

      return {
        'success': true,
        'consultations': consultations,
        'lastPage': lastPage,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load expert consultations');
      return {'success': false, 'message': msg};
    }
  }

  // Get consultation detail
  Future<Map<String, dynamic>> getConsultationDetail(int id) async {
    try {
      final response = await _dio.get('/consultations/$id');
      return {
        'success': true,
        'consultation': Consultation.fromJson(response.data['data']),
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load consultation details');
      return {'success': false, 'message': msg};
    }
  }

  // Verify / Reject Payment (expert only)
  Future<Map<String, dynamic>> verifyPayment({
    required int consultationId,
    required bool approve,
    String? rejectionNote,
  }) async {
    try {
      final response = await _dio.post('/consultations/$consultationId/verify-payment', data: {
        'action': approve ? 'verify' : 'reject',
        'rejection_note': rejectionNote,
      });

      return {
        'success': true,
        'consultation': Consultation.fromJson(response.data['data']),
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to verify payment');
      return {'success': false, 'message': msg};
    }
  }

  // End Consultation (expert only)
  Future<Map<String, dynamic>> endConsultation(int consultationId) async {
    try {
      final response = await _dio.post('/consultations/$consultationId/end');
      return {
        'success': true,
        'consultation': Consultation.fromJson(response.data['data']),
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to end consultation');
      return {'success': false, 'message': msg};
    }
  }

  // Get payment history (user)
  Future<Map<String, dynamic>> getPaymentHistory({int page = 1}) async {
    try {
      final response = await _dio.get('/consultations/payment-history', queryParameters: {'page': page});
      final listJson = response.data['data']['data'] as List;
      final consultations = listJson.map((json) => Consultation.fromJson(json)).toList();
      final lastPage = response.data['data']['last_page'] ?? 1;

      return {
        'success': true,
        'consultations': consultations,
        'lastPage': lastPage,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load payment history');
      return {'success': false, 'message': msg};
    }
  }
}