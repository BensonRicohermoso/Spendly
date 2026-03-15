import 'package:flutter/foundation.dart';

/// API configuration — base URL and endpoints.
class ApiConfig {
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String _localhostBaseUrl = 'http://localhost:8000/api/v1';

  /// Returns the correct API host for the current platform.
  static String get baseUrl {
    if (kIsWeb) {
      return _localhostBaseUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorBaseUrl;
    }

    return _localhostBaseUrl;
  }

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String deleteAccount = '/auth/me';

  // Expenses
  static const String expenses = '/expenses';

  // Budgets
  static const String budgets = '/budgets';
  static const String budgetRemaining = '/budgets/remaining';

  // Summary
  static const String weeklySummary = '/summary/weekly';
}
