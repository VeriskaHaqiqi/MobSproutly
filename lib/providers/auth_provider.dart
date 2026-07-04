// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email, password);
    _isLoading = false;

    if (result['success']) {
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Register Regular User
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.registerUser(
      name: name,
      email: email,
      phone: phone,
      gender: gender,
      password: password,
    );

    _isLoading = false;
    if (!result['success']) {
      _errorMessage = result['message'];
    }
    notifyListeners();
    return result;
  }

  // Register Expert
  Future<Map<String, dynamic>> registerExpert(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.registerExpert(data);

    _isLoading = false;
    if (!result['success']) {
      _errorMessage = result['message'];
    }
    notifyListeners();
    return result;
  }

  // Get current profile
  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    final result = await _userService.getProfile();
    _isLoading = false;

    if (result['success']) {
      _user = result['user'];
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? gender,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userService.updateProfile(
        name: name, phone: phone, gender: gender);
    _isLoading = false;

    if (result['success']) {
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Upload profile photo
  Future<bool> uploadPhoto(String photoPath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userService.uploadPhoto(photoPath);

    if (result['success']) {
      // Refresh entire profile to get new photoUrl and nested models
      final profileResult = await _userService.getProfile();
      if (profileResult['success']) {
        _user = profileResult['user'];
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete profile photo
  Future<bool> deletePhoto() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userService.deletePhoto();

    if (result['success']) {
      final profileResult = await _userService.getProfile();
      if (profileResult['success']) {
        _user = profileResult['user'];
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update expert profile info (university, fee, duration)
  Future<bool> updateExpertProfile({
    String? university,
    int? yearsOfExperience,
    String? description,
    String? certificate,
    String? diploma,
    double? sessionFee,
    int? sessionDuration,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userService.updateExpertProfile(
      university: university,
      yearsOfExperience: yearsOfExperience,
      description: description,
      certificate: certificate,
      diploma: diploma,
      sessionFee: sessionFee,
      sessionDuration: sessionDuration,
    );

    if (result['success']) {
      final profileResult = await _userService.getProfile();
      if (profileResult['success']) {
        _user = profileResult['user'];
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveSpecializations(List<String> specializations) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userService.saveSpecializations(specializations);

    if (result['success']) {
      final profileResult = await _userService.getProfile();
      if (profileResult['success']) {
        _user = profileResult['user'];
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadCertificate({
    required String filePath,
    required bool isDiploma,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userService.uploadCertificate(
      filePath: filePath,
      isDiploma: isDiploma,
    );

    if (result['success']) {
      final profileResult = await _userService.getProfile();
      if (profileResult['success']) {
        _user = profileResult['user'];
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update expert bank account details
  Future<bool> updateBankAccount({
    required String bankName,
    required String accountHolder,
    required String accountNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userService.updateBankAccount(
      bankName: bankName,
      accountHolder: accountHolder,
      accountNumber: accountNumber,
    );

    if (result['success']) {
      final profileResult = await _userService.getProfile();
      if (profileResult['success']) {
        _user = profileResult['user'];
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get expert schedules
  Future<List<dynamic>?> getSchedules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userService.getSchedules();

    if (result['success']) {
      _isLoading = false;
      notifyListeners();
      return result['data'];
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Save expert schedules
  Future<bool> saveSchedules(List<Map<String, dynamic>> schedules) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userService.saveSchedules(schedules);

    if (result['success']) {
      final profileResult = await _userService.getProfile();
      if (profileResult['success']) {
        _user = profileResult['user'];
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
