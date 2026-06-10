import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/expert_service.dart';

class ExpertProvider extends ChangeNotifier {
  final ExpertService _expertService = ExpertService();

  List<User> _experts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;

  // Income History
  List<dynamic> _incomeHistory = [];
  bool _isIncomeLoading = false;
  int _incomeCurrentPage = 1;
  int _incomeLastPage = 1;

  // Getters
  List<User> get experts => _experts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;

  List<dynamic> get incomeHistory => _incomeHistory;
  bool get isIncomeLoading => _isIncomeLoading;

  // Fetch experts
  Future<void> fetchExperts(
      {int page = 1, String? search, bool refresh = false}) async {
    if (page == 1 || refresh) {
      _experts.clear();
      _currentPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _expertService.getExperts(page: page, search: search);
    _isLoading = false;

    if (result['success']) {
      final List<User> fetched = result['experts'];
      _experts.addAll(fetched);
      _currentPage = page;
      _lastPage = result['lastPage'];
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  // Fetch Income History
  Future<void> fetchIncomeHistory({int page = 1, bool refresh = false}) async {
    if (page == 1 || refresh) {
      _incomeHistory.clear();
      _incomeCurrentPage = 1;
    }

    _isIncomeLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _expertService.getIncomeHistory(page: page);
    _isIncomeLoading = false;

    if (result['success']) {
      final data = result['data'];
      final consultations = data['consultations'];
      _incomeHistory.addAll(consultations['data'] as List);
      _incomeCurrentPage = page;
      _incomeLastPage = consultations['last_page'] ?? 1;
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
