import 'package:flutter/material.dart';
import '../models/rating_model.dart';
import '../services/rating_service.dart';

class RatingProvider extends ChangeNotifier {
  final RatingService _ratingService = RatingService();

  List<Rating> _ratings = [];
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  // Getters
  List<Rating> get ratings => _ratings;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  // Submit rating
  Future<bool> submitRating({
    required int consultationId,
    required int score,
    String? comment,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _ratingService.submitRating(
      consultationId: consultationId,
      score: score,
      comment: comment,
    );

    _isActionLoading = false;

    if (result['success']) {
      final Rating newRating = result['rating'];
      _ratings.insert(0, newRating);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Fetch user's ratings
  Future<void> fetchUserRatings({int page = 1, bool refresh = false}) async {
    if (page == 1 || refresh) {
      _ratings.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _ratingService.getUserRatings(page: page);
    _isLoading = false;

    if (result['success']) {
      _ratings.addAll(result['ratings']);
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  // Fetch expert's ratings
  Future<void> fetchExpertRatings({int page = 1, bool refresh = false}) async {
    if (page == 1 || refresh) {
      _ratings.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _ratingService.getExpertRatings(page: page);
    _isLoading = false;

    if (result['success']) {
      _ratings.addAll(result['ratings']);
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  // Fetch public ratings for a specific expert
  Future<void> fetchPublicRatings(int expertId,
      {int page = 1, bool refresh = false}) async {
    if (page == 1 || refresh) {
      _ratings.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result =
        await _ratingService.getPublicExpertRatings(expertId, page: page);
    _isLoading = false;

    if (result['success']) {
      _ratings.addAll(result['ratings']);
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
