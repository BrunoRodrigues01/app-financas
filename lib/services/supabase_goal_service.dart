import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/goal.dart';
import 'supabase_service.dart';

class SupabaseGoalService {
  final _supabase = SupabaseService.instance.client;
  final String _tableName = 'goals';

  // ==================== CRUD METAS ====================

  // Obter todas as metas do usuário
  Future<List<Goal>> getGoals() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('deadline', ascending: true);

      return (response as List)
          .map((json) => Goal.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obter metas ativas
  Future<List<Goal>> getActiveGoals() async {
    try {
      final goals = await getGoals();
      return goals.where((goal) => !goal.isCompleted).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obter metas concluídas
  Future<List<Goal>> getCompletedGoals() async {
    try {
      final goals = await getGoals();
      return goals.where((goal) => goal.isCompleted).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Adicionar nova meta
  Future<Goal> addGoal(Goal goal) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final data = goal.toJson();
      data['user_id'] = userId;

      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return Goal.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar meta
  Future<Goal> updateGoal(Goal goal) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
          .from(_tableName)
          .update(goal.toJson())
          .eq('id', goal.id)
          .eq('user_id', userId)
          .select()
          .single();

      return Goal.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Adicionar valor à meta
  Future<Goal> addAmountToGoal(String goalId, double amount) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      // Primeiro, obter a meta atual
      final currentGoal = await _supabase
          .from(_tableName)
          .select()
          .eq('id', goalId)
          .eq('user_id', userId)
          .single();

      final goal = Goal.fromJson(currentGoal);
      final newAmount = goal.currentAmount + amount;

      // Atualizar a meta
      final response = await _supabase
          .from(_tableName)
          .update({'current_amount': newAmount})
          .eq('id', goalId)
          .eq('user_id', userId)
          .select()
          .single();

      return Goal.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Deletar meta
  Future<void> deleteGoal(String id) async {
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

  // Obter progresso geral das metas
  Future<double> getOverallProgress() async {
    try {
      final goals = await getGoals();
      if (goals.isEmpty) return 0;

      final totalTarget = goals.fold<double>(
        0, 
        (sum, goal) => sum + goal.targetAmount,
      );
      final totalCurrent = goals.fold<double>(
        0, 
        (sum, goal) => sum + goal.currentAmount,
      );

      return totalTarget > 0 ? (totalCurrent / totalTarget * 100) : 0;
    } catch (e) {
      rethrow;
    }
  }

  // Stream de metas em tempo real
  Stream<List<Goal>> watchGoals() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('deadline', ascending: true)
        .map((data) => data.map((json) => Goal.fromJson(json)).toList());
  }
}
