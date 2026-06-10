import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/consultation_model.dart';
import '../models/payment_model.dart';
import '../services/consultation_service.dart';

class ConsultationProvider extends ChangeNotifier {
  final ConsultationService _consultationService = ConsultationService();

  List<User> _experts = [];
  List<Consultation> _userConsultations = [];
  List<Consultation> _expertConsultations = [];

  Consultation? _currentConsultation;
  Payment? _currentPayment;
  Map<String, dynamic>? _expertBank;

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  // Pagination
  int _expertsPage = 1;
  int _expertsLastPage = 1;
  int _historyPage = 1;
  int _historyLastPage = 1;

  // Getters
  List<User> get experts => _experts;
  List<Consultation> get userConsultations => _userConsultations;
  List<Consultation> get expertConsultations => _expertConsultations;
  Consultation? get currentConsultation => _currentConsultation;
  Payment? get currentPayment => _currentPayment;
  Map<String, dynamic>? get expertBank => _expertBank;

  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  // Fetch experts
  Future<void> fetchExperts(
      {int page = 1, String? search, bool refresh = false}) async {
    if (page == 1 || refresh) {
      _experts.clear();
      _expertsPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result =
        await _consultationService.getExperts(page: page, search: search);
    _isLoading = false;

    if (result['success']) {
      _experts.addAll(result['experts']);
      _expertsPage = page;
      _expertsLastPage = result['lastPage'];
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  // Start a consultation (user)
  Future<bool> startConsultation(int expertId, String? topic) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _consultationService.createConsultation(
        expertId: expertId, topic: topic);
    _isActionLoading = false;

    if (result['success']) {
      _currentConsultation = result['consultation'];
      _currentPayment = result['payment'];
      _expertBank = result['expertBank'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Upload payment proof (user)
  Future<bool> uploadPaymentProof(int consultationId, String proofPath) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _consultationService.uploadPaymentProof(
      consultationId: consultationId,
      paymentProofPath: proofPath,
    );
    _isActionLoading = false;

    if (result['success']) {
      _currentConsultation = result['consultation'];
      _currentPayment = result['payment'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Fetch consultations for users
  Future<void> fetchUserConsultations(
      {int page = 1, String? status, bool refresh = false}) async {
    if (page == 1 || refresh) {
      _userConsultations.clear();
      _historyPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _consultationService.getUserConsultations(
        page: page, status: status);
    _isLoading = false;

    if (result['success']) {
      _userConsultations.addAll(result['consultations']);
      _historyPage = page;
      _historyLastPage = result['lastPage'];
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  // Fetch consultations for experts
  Future<void> fetchExpertConsultations(
      {int page = 1, String? status, bool refresh = false}) async {
    if (page == 1 || refresh) {
      _expertConsultations.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _consultationService.getExpertConsultations(
        page: page, status: status);
    _isLoading = false;

    if (result['success']) {
      _expertConsultations.addAll(result['consultations']);
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  // Fetch consultation detail
  Future<void> fetchConsultationDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _consultationService.getConsultationDetail(id);
    _isLoading = false;

    if (result['success']) {
      _currentConsultation = result['consultation'];
      _currentPayment = _currentConsultation?.payment;
      if (_currentConsultation?.expert?.expertProfile != null) {
        _expertBank = {
          'bank_name': _currentConsultation!.expert!.expertProfile!.bankName,
          'account_holder':
              _currentConsultation!.expert!.expertProfile!.accountHolder,
          'account_number':
              _currentConsultation!.expert!.expertProfile!.accountNumber,
        };
      }
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  // Verify Payment (expert)
  Future<bool> verifyPayment(int consultationId, bool approve,
      {String? rejectionNote}) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _consultationService.verifyPayment(
      consultationId: consultationId,
      approve: approve,
      rejectionNote: rejectionNote,
    );
    _isActionLoading = false;

    if (result['success']) {
      _currentConsultation = result['consultation'];
      _currentPayment = _currentConsultation?.payment;

      // Update in expert list
      final idx =
          _expertConsultations.indexWhere((c) => c.id == consultationId);
      if (idx != -1) {
        _expertConsultations[idx] = result['consultation'];
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // End consultation (expert)
  Future<bool> endConsultation(int consultationId) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _consultationService.endConsultation(consultationId);
    _isActionLoading = false;

    if (result['success']) {
      _currentConsultation = result['consultation'];
      _currentPayment = _currentConsultation?.payment;

      // Update in lists
      final expIdx =
          _expertConsultations.indexWhere((c) => c.id == consultationId);
      if (expIdx != -1) {
        _expertConsultations[expIdx] = result['consultation'];
      }

      final userIdx =
          _userConsultations.indexWhere((c) => c.id == consultationId);
      if (userIdx != -1) {
        _userConsultations[userIdx] = result['consultation'];
      }

      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
