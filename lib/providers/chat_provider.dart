import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/consultation_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<Message> _messages = [];
  Consultation? _consultation;

  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  Timer? _pollingTimer;
  int? _activeConsultationId;

  // Getters
  List<Message> get messages => _messages;
  Consultation? get consultation => _consultation;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  // Fetch messages
  Future<void> fetchMessages(int consultationId, {bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    final result = await _chatService.getMessages(consultationId);

    if (result['success']) {
      _messages = result['messages'];
      _consultation = result['consultation'];
    } else {
      if (!silent) {
        _errorMessage = result['message'];
      }
    }

    if (!silent || result['success']) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message
  Future<bool> sendMessage(int consultationId,
      {String? text, String? attachmentPath}) async {
    _isSending = true;
    notifyListeners();

    final result = await _chatService.sendMessage(
      consultationId: consultationId,
      messageText: text,
      attachmentPath: attachmentPath,
    );

    _isSending = false;

    if (result['success']) {
      final Message newMsg = result['message'];
      _messages.add(newMsg);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Mark as read
  Future<void> markAsRead(int consultationId) async {
    await _chatService.markAsRead(consultationId);
  }

  // Start polling for new messages every 3 seconds
  void startPolling(int consultationId) {
    stopPolling();
    _activeConsultationId = consultationId;
    fetchMessages(consultationId);
    markAsRead(consultationId);

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_activeConsultationId != null) {
        fetchMessages(_activeConsultationId!, silent: true);
      }
    });
  }

  // Stop polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _activeConsultationId = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
