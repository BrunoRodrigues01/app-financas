import '../models/transaction.dart';
import '../models/goal.dart';

class DatabaseService {
  // Simulação de banco de dados em memória
  final List<Transaction> _transactions = [];
  final List<Goal> _goals = [];

  // TRANSAÇÕES
  
  // Obter todas as transações
  Future<List<Transaction>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_transactions);
  }

  // Adicionar transação
  Future<void> addTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _transactions.add(transaction);
  }

  // Atualizar transação
  Future<void> updateTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  // Deletar transação
  Future<void> deleteTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _transactions.removeWhere((t) => t.id == id);
  }

  // METAS

  // Obter todas as metas
  Future<List<Goal>> getGoals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_goals);
  }

  // Adicionar meta
  Future<void> addGoal(Goal goal) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _goals.add(goal);
  }

  // Atualizar meta
  Future<void> updateGoal(Goal goal) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    }
  }

  // Deletar meta
  Future<void> deleteGoal(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _goals.removeWhere((g) => g.id == id);
  }
}
