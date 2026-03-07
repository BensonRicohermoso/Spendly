import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/expenses/expense_list_screen.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/summary/summary_screen.dart';
import '../screens/settings/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // Auth
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

    // Main
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/expenses', builder: (_, __) => const ExpenseListScreen()),
    GoRoute(path: '/expenses/add', builder: (_, __) => const AddExpenseScreen()),
    GoRoute(path: '/budget', builder: (_, __) => const BudgetScreen()),
    GoRoute(path: '/summary', builder: (_, __) => const SummaryScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);
