class ExpenseModel {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String? note;
  final DateTime dateCreated;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    this.note,
    required this.dateCreated,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      note: json['note'],
      dateCreated: DateTime.parse(json['date_created']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'amount': amount,
      'category': category,
      if (note != null) 'note': note,
    };
  }
}
