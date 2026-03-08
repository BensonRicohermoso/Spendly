import 'dart:convert';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final _api = ApiClient();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiConfig.register,
        body: {'email': email, 'password': password},
        auth: false,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _api.saveTokens(data);
        await fetchUser();
        return true;
      } else {
        _error = jsonDecode(response.body)['detail'] ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiConfig.login,
        body: {'email': email, 'password': password},
        auth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _api.saveTokens(data);
        await fetchUser();
        return true;
      } else {
        _error = jsonDecode(response.body)['detail'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUser() async {
    try {
      final response = await _api.get(ApiConfig.me);
      if (response.statusCode == 200) {
        _user = UserModel.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.clearTokens();
    _user = null;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    try {
      final response = await _api.delete(ApiConfig.deleteAccount);
      if (response.statusCode == 200) {
        await _api.clearTokens();
        _user = null;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Try to restore session from stored tokens on app start.
  Future<void> tryAutoLogin() async {
    final token = await _api.getAccessToken();
    if (token != null) {
      await fetchUser();
    }
  }
}
