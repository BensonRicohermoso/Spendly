import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _dailyController = TextEditingController();
  final _weeklyController = TextEditingController();
  final _monthlyController = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<BudgetProvider>();
      await provider.fetchBudget();
      await provider.fetchRemaining();
      _loadValues();
    });
  }

  void _loadValues() {
    final b = context.read<BudgetProvider>().budget;
    if (b != null) {
      _dailyController.text = b.dailyBudget.toStringAsFixed(2);
      _weeklyController.text = b.weeklyBudget.toStringAsFixed(2);
      _monthlyController.text = b.monthlyBudget.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _dailyController.dispose();
    _weeklyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<BudgetProvider>();
    final success = await provider.setBudget(
      daily: double.tryParse(_dailyController.text) ?? 0,
      weekly: double.tryParse(_weeklyController.text) ?? 0,
      monthly: double.tryParse(_monthlyController.text) ?? 0,
    );
    if (success) {
      setState(() => _editing = false);
      await provider.fetchRemaining();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BudgetProvider>();
    final remaining = provider.remaining;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _editing = !_editing),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_editing) ...[
            TextField(
              controller: _dailyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Daily Budget', prefixText: '\$ '),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weeklyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weekly Budget', prefixText: '\$ '),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _monthlyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monthly Budget', prefixText: '\$ '),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('Save Budget')),
            const SizedBox(height: 24),
          ],

          if (remaining != null) ...[
            _RemainingCard(label: 'Daily', spent: remaining.spentToday, budget: remaining.dailyBudget, remaining: remaining.remainingDaily),
            const SizedBox(height: 12),
            _RemainingCard(label: 'Weekly', spent: remaining.spentThisWeek, budget: remaining.weeklyBudget, remaining: remaining.remainingWeekly),
            const SizedBox(height: 12),
            _RemainingCard(label: 'Monthly', spent: remaining.spentThisMonth, budget: remaining.monthlyBudget, remaining: remaining.remainingMonthly),
          ] else if (provider.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class _RemainingCard extends StatelessWidget {
  final String label;
  final double spent;
  final double budget;
  final double remaining;

  const _RemainingCard({
    required this.label,
    required this.spent,
    required this.budget,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = remaining < 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label Budget', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spent: \$${spent.toStringAsFixed(2)}'),
                Text('Budget: \$${budget.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Remaining: \$${remaining.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isOver ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
