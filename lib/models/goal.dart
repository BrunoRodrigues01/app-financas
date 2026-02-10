class Goal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String? description;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.description,
  });

  // Calcular progresso em porcentagem
  double get progress {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  // Verificar se a meta foi atingida
  bool get isCompleted => currentAmount >= targetAmount;

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'description': description,
    };
  }

  // Criar a partir de JSON
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'],
      deadline: DateTime.parse(json['deadline']),
      description: json['description'],
    );
  }
}
