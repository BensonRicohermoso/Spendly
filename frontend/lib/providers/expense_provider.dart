import 'dart:convert';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final _api = ApiClient();

  List<ExpenseModel> _expenses = [];
  int _total = 0;
  bool _isLoading = false;
  String? _error;

  List<ExpenseModel> get expenses => _expenses;
  int get total => _total;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchExpenses({int skip = 0, int limit = 50, String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var path = '${ApiConfig.expenses}?skip=$skip&limit=$limit';
      if (category != null) path += '&category=$category';

      final response = await _api.get(path);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _expenses = (data['items'] as List).map((e) => ExpenseModel.fromJson(e)).toList();
        _total = data['total'];
      } else {
        _error = 'Failed to load expenses';
      }
    } catch (e) {
      _error = 'Network error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense({
    required double amount,
    required String category,
    String? note,
  }) async {
    try {
      final response = await _api.post(
        '${ApiConfig.expenses}/',
        body: {
          'amount': amount,
          'category': category,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      if (response.statusCode == 201) {
        await fetchExpenses();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> updateExpense(String id, {double? amount, String? category, String? note}) async {
    final body = <String, dynamic>{};
    if (amount != null) body['amount'] = amount;
    if (category != null) body['category'] = category;
    if (note != null) body['note'] = note;

    try {
      final response = await _api.put('${ApiConfig.expenses}/$id', body: body);
      if (response.statusCode == 200) {
        await fetchExpenses();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> deleteExpense(String id) async {
    try {
      final response = await _api.delete('${ApiConfig.expenses}/$id');
      if (response.statusCode == 204) {
        _expenses.removeWhere((e) => e.id == id);
        _total--;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
