class BudgetModel {
  final String id;
  final String userId;
  final double dailyBudget;
  final double weeklyBudget;
  final double monthlyBudget;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.dailyBudget,
    required this.weeklyBudget,
    required this.monthlyBudget,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      userId: json['user_id'],
      dailyBudget: (json['daily_budget'] as num).toDouble(),
      weeklyBudget: (json['weekly_budget'] as num).toDouble(),
      monthlyBudget: (json['monthly_budget'] as num).toDouble(),
    );
  }
}

class BudgetRemainingModel {
  final double dailyBudget;
  final double weeklyBudget;
  final double monthlyBudget;
  final double spentToday;
  final double spentThisWeek;
  final double spentThisMonth;
  final double remainingDaily;
  final double remainingWeekly;
  final double remainingMonthly;

  BudgetRemainingModel({
    required this.dailyBudget,
    required this.weeklyBudget,
    required this.monthlyBudget,
    required this.spentToday,
    required this.spentThisWeek,
    required this.spentThisMonth,
    required this.remainingDaily,
    required this.remainingWeekly,
    required this.remainingMonthly,
  });

  factory BudgetRemainingModel.fromJson(Map<String, dynamic> json) {
    return BudgetRemainingModel(
      dailyBudget: (json['daily_budget'] as num).toDouble(),
      weeklyBudget: (json['weekly_budget'] as num).toDouble(),
      monthlyBudget: (json['monthly_budget'] as num).toDouble(),
      spentToday: (json['spent_today'] as num).toDouble(),
      spentThisWeek: (json['spent_this_week'] as num).toDouble(),
      spentThisMonth: (json['spent_this_month'] as num).toDouble(),
      remainingDaily: (json['remaining_daily'] as num).toDouble(),
      remainingWeekly: (json['remaining_weekly'] as num).toDouble(),
      remainingMonthly: (json['remaining_monthly'] as num).toDouble(),
    );
  }
}
