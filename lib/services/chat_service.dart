import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/message_model.dart';
import '../models/consultation_model.dart';
import '../utils/file_helper.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();
  late final Dio _dio;

  ChatService() {
    _dio = _apiClient.dio;
  }

  // Get chat messages for a consultation
  Future<Map<String, dynamic>> getMessages(int consultationId, {int page = 1}) async {
    try {
      final response = await _dio.get('/chat/$consultationId', queryParameters: {'page': page});
      final listJson = response.data['data']['messages']['data'] as List;
      final messages = listJson.map((json) => Message.fromJson(json)).toList();
      final consultation = Consultation.fromJson(response.data['data']['consultation']);
      final lastPage = response.data['data']['messages']['last_page'] ?? 1;

      return {
        'success': true,
        'messages': messages,
        'consultation': consultation,
        'lastPage': lastPage,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load chat messages');
      return {'success': false, 'message': msg};
    }
  }

  // Send a chat message (text, image, or video)
  Future<Map<String, dynamic>> sendMessage({
    required int consultationId,
    String? messageText,
    String? attachmentPath,
  }) async {
    try {
      final mapData = <String, dynamic>{};

      if (messageText != null && messageText.trim().isNotEmpty) {
        mapData['message'] = messageText;
      }

      final formData = FormData.fromMap(mapData);

      if (attachmentPath != null && attachmentPath.isNotEmpty) {
        formData.files.add(MapEntry(
          'attachment',
          await FileHelper.createMultipartFile(
            attachmentPath,
            filename: attachmentPath.split(RegExp(r'[/\\]')).last,
          ),
        ));
      }

      final response = await _dio.post('/chat/$consultationId', data: formData);

      return {
        'success': true,
        'message': Message.fromJson(response.data['data']),
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to send message');
      return {'success': false, 'message': msg};
    }
  }

  // Mark all messages as read
  Future<Map<String, dynamic>> markAsRead(int consultationId) async {
    try {
      final response = await _dio.patch('/chat/$consultationId/read');
      return {
        'success': true,
        'message': response.data['message'],
        'messagesUpdated': response.data['messages_updated'] ?? 0,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to mark messages as read');
      return {'success': false, 'message': msg};
    }
  }

  // Get total unread count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await _dio.get('/chat/unread-count');
      return {
        'success': true,
        'unreadCount': response.data['data']['unread_count'] ?? 0,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to get unread count');
      return {'success': false, 'message': msg};
    }
  }

  // Delete message
  Future<Map<String, dynamic>> deleteMessage(int messageId) async {
    try {
      final response = await _dio.delete('/chat/message/$messageId');
      return {
        'success': true,
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to delete message');
      return {'success': false, 'message': msg};
    }
  }
}