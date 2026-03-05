import 'dart:convert';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  final _api = ApiClient();

  BudgetModel? _budget;
  BudgetRemainingModel? _remaining;
  bool _isLoading = false;
  String? _error;

  BudgetModel? get budget => _budget;
  BudgetRemainingModel? get remaining => _remaining;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBudget() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get(ApiConfig.budgets);
      if (response.statusCode == 200) {
        _budget = BudgetModel.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRemaining() async {
    try {
      final response = await _api.get(ApiConfig.budgetRemaining);
      if (response.statusCode == 200) {
        _remaining = BudgetRemainingModel.fromJson(jsonDecode(response.body));
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> setBudget({
    required double daily,
    required double weekly,
    required double monthly,
  }) async {
    try {
      final response = await _api.put(
        ApiConfig.budgets,
        body: {
          'daily_budget': daily,
          'weekly_budget': weekly,
          'monthly_budget': monthly,
        },
      );
      if (response.statusCode == 200) {
        _budget = BudgetModel.fromJson(jsonDecode(response.body));
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
