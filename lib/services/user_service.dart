import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user_model.dart';
import '../utils/file_helper.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();
  late final Dio _dio;

  UserService() {
    _dio = _apiClient.dio;
  }

  // Get user profile (including expert profile details if expert)
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      final user = User.fromJson(response.data['data']);
      return {
        'success': true,
        'user': user,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to get profile');
      return {'success': false, 'message': msg};
    }
  }

  // Update general user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? gender,
  }) async {
    try {
      final response = await _dio.put('/profile/update', data: {
        'name': name,
        'phone': phone,
        'gender': gender,
      });

      return {
        'success': true,
        'user': User.fromJson(response.data['data']),
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to update profile');
      return {'success': false, 'message': msg};
    }
  }

  // Upload profile photo
  Future<Map<String, dynamic>> uploadPhoto(String photoPath) async {
    try {
      // Handle both Windows (\) and Unix (/) path separators
      final filename = photoPath.split(RegExp(r'[/\\]')).last;

      final formData = FormData.fromMap({
        'profile_photo': await FileHelper.createMultipartFile(
          photoPath,
          filename: filename,
        ),
      });

      final response = await _dio.post(
        '/profile/photo',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return {
        'success': true,
        'photoUrl': response.data['data']?['photo_url'] ?? response.data['photo_url'],
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to upload photo');
      return {'success': false, 'message': msg};
    }
  }

  // Delete profile photo
  Future<Map<String, dynamic>> deletePhoto() async {
    try {
      final response = await _dio.delete('/profile/photo');
      return {
        'success': true,
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to delete photo');
      return {'success': false, 'message': msg};
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put('/profile/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      });

      return {
        'success': true,
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to change password');
      return {'success': false, 'message': msg};
    }
  }

  // Update expert profile details
  Future<Map<String, dynamic>> updateExpertProfile({
    String? university,
    int? yearsOfExperience,
    String? description,
    String? certificate,
    String? diploma,
    double? sessionFee,
    int? sessionDuration,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (university != null) data['university'] = university;
      if (yearsOfExperience != null) data['years_of_experience'] = yearsOfExperience;
      if (description != null) data['description'] = description;
      if (certificate != null) data['certificate'] = certificate;
      if (diploma != null) data['diploma'] = diploma;
      if (sessionFee != null) data['session_fee'] = sessionFee;
      if (sessionDuration != null) data['session_duration'] = sessionDuration;

      final response = await _dio.put('/profile/expert', data: data);

      return {
        'success': true,
        'expertProfile': ExpertProfile.fromJson(response.data['data']),
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to update expert profile');
      return {'success': false, 'message': msg};
    }
  }

  // Update bank account details (expert only)
  Future<Map<String, dynamic>> updateBankAccount({
    required String bankName,
    required String accountHolder,
    required String accountNumber,
  }) async {
    try {
      final response = await _dio.put('/profile/bank-account', data: {
        'bank_name': bankName,
        'account_holder': accountHolder,
        'account_number': accountNumber,
      });

      return {
        'success': true,
        'expertProfile': ExpertProfile.fromJson(response.data['data']),
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to update bank account');
      return {'success': false, 'message': msg};
    }
  }

  // Upload professional certificate or diploma
  Future<Map<String, dynamic>> uploadCertificate({
    required String filePath,
    required bool isDiploma, // true for diploma, false for certificate
  }) async {
    try {
      final keyName = isDiploma ? 'diploma' : 'certificate';
      final formData = FormData.fromMap({
        keyName: await FileHelper.createMultipartFile(
          filePath,
          filename: filePath.split(RegExp(r'[/\\]')).last,
        ),
      });

      final response = await _dio.post('/profile/certificate', data: formData);

      return {
        'success': true,
        'expertProfile': ExpertProfile.fromJson(response.data['data']),
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to upload document');
      return {'success': false, 'message': msg};
    }
  }

  // Get expert schedules
  Future<Map<String, dynamic>> getSchedules() async {
    try {
      final response = await _dio.get('/experts/profile/schedules');
      return {
        'success': true,
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load schedules');
      return {'success': false, 'message': msg};
    }
  }

  // Save expert schedules
  Future<Map<String, dynamic>> saveSchedules(List<Map<String, dynamic>> schedules) async {
    try {
      final response = await _dio.post('/experts/profile/schedules', data: {
        'schedules': schedules,
      });
      return {
        'success': true,
        'message': response.data['message'],
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to save schedules');
      return {'success': false, 'message': msg};
    }
  }

  // Save expert specializations
  Future<Map<String, dynamic>> saveSpecializations(List<String> specializations) async {
    try {
      final response = await _dio.post('/experts/profile/specializations', data: {
        'specializations': specializations,
      });
      return {
        'success': true,
        'message': response.data['message'],
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to save specializations');
      return {'success': false, 'message': msg};
    }
  }
}