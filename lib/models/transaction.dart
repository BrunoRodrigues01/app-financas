enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;
  final String? description;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.description,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'category': category,
      'description': description,
    };
  }

  // Criar a partir de JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      type: json['type'] == 'TransactionType.income'
          ? TransactionType.income
          : TransactionType.expense,
      category: json['category'],
      description: json['description'],
    );
  }
}
