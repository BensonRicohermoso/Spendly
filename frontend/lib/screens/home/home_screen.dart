import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
      context.read<BudgetProvider>().fetchRemaining();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final expenses = context.watch<ExpenseProvider>();
    final remaining = budget.remaining;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            expenses.fetchExpenses(),
            budget.fetchRemaining(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Budget overview cards
            if (remaining != null) ...[
              _BudgetCard(
                title: 'Today',
                spent: remaining.spentToday,
                budget: remaining.dailyBudget,
                remaining: remaining.remainingDaily,
              ),
              const SizedBox(height: 12),
              _BudgetCard(
                title: 'This Week',
                spent: remaining.spentThisWeek,
                budget: remaining.weeklyBudget,
                remaining: remaining.remainingWeekly,
              ),
              const SizedBox(height: 12),
              _BudgetCard(
                title: 'This Month',
                spent: remaining.spentThisMonth,
                budget: remaining.monthlyBudget,
                remaining: remaining.remainingMonthly,
              ),
              const SizedBox(height: 24),
            ],

            // Recent expenses header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Expenses', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.push('/expenses'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Recent expenses list
            if (expenses.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (expenses.expenses.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No expenses yet. Tap + to add one!', textAlign: TextAlign.center),
                ),
              )
            else
              ...expenses.expenses.take(5).map((e) => Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(e.category[0].toUpperCase())),
                      title: Text(e.category),
                      subtitle: Text(e.note ?? ''),
                      trailing: Text(
                        '\$${e.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/add'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: break; // Already on home
            case 1: context.push('/expenses');
            case 2: context.push('/budget');
            case 3: context.push('/summary');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.savings), label: 'Budget'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Summary'),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final String title;
  final double spent;
  final double budget;
  final double remaining;

  const _BudgetCard({
    required this.title,
    required this.spent,
    required this.budget,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = remaining < 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  '\$${remaining.toStringAsFixed(2)} left',
                  style: TextStyle(
                    color: isOver ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(isOver ? Colors.red : Colors.green),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${spent.toStringAsFixed(2)} / \$${budget.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
