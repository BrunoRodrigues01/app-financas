import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
import 'supabase_service.dart';

class SupabaseTransactionService {
  final _supabase = SupabaseService.instance.client;
  final String _tableName = 'transactions';

  // ==================== CRUD TRANSAÇÕES ====================

  // Obter todas as transações do usuário
  Future<List<Transaction>> getTransactions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return (response as List)
          .map((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obter transações por período
  Future<List<Transaction>> getTransactionsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: false);

      return (response as List)
          .map((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obter transações por tipo
  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('type', type.toString())
          .order('date', ascending: false);

      return (response as List)
          .map((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obter transações por categoria
  Future<List<Transaction>> getTransactionsByCategory(String category) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('category', category)
          .order('date', ascending: false);

      return (response as List)
          .map((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Adicionar nova transação
  Future<Transaction> addTransaction(Transaction transaction) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final data = transaction.toJson();
      data['user_id'] = userId;

      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar transação
  Future<Transaction> updateTransaction(Transaction transaction) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
          .from(_tableName)
          .update(transaction.toJson())
          .eq('id', transaction.id)
          .eq('user_id', userId)
          .select()
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Deletar transação
  Future<void> deleteTransaction(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== ESTATÍSTICAS ====================

  // Obter total de receitas do mês
  Future<double> getMonthlyIncome() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final transactions = await getTransactionsByPeriod(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      return transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);
    } catch (e) {
      rethrow;
    }
  }

  // Obter total de despesas do mês
  Future<double> getMonthlyExpenses() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final transactions = await getTransactionsByPeriod(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      return transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);
    } catch (e) {
      rethrow;
    }
  }

  // Obter saldo atual
  Future<double> getCurrentBalance() async {
    try {
      final transactions = await getTransactions();
      
      double balance = 0;
      for (var transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }
      }
      
      return balance;
    } catch (e) {
      rethrow;
    }
  }

  // Stream de transações em tempo real
  Stream<List<Transaction>> watchTransactions() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('date', ascending: false)
        .map((data) => data.map((json) => Transaction.fromJson(json)).toList());
  }
}
