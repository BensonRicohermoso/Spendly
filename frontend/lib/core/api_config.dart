/// API configuration — base URL and endpoints.
class ApiConfig {
  // Change this to your production URL when deploying
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator -> host
  // static const String baseUrl = 'http://localhost:8000/api/v1'; // Web / iOS simulator

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
