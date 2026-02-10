import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class GoalService {
  final _supabase = SupabaseService.instance.client;
  final String _tableName = 'metas';

  // ==================== CRUD METAS ====================

  /// Adicionar nova meta
  /// O progresso é calculado automaticamente pelo trigger
  Future<Map<String, dynamic>> addGoal({
    required String tipo, // 'economia', 'orcamento', etc
    required String titulo,
    required double valor,
    required DateTime dataConclusao,
    String? descricao,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      // Validações
      if (valor <= 0) {
        throw Exception('O valor deve ser maior que zero');
      }
      if (titulo.isEmpty) {
        throw Exception('Título é obrigatório');
      }
      if (dataConclusao.isBefore(DateTime.now())) {
        throw Exception('A data de conclusão deve ser futura');
      }

      final goalData = {
        'usuario_id': userId,
        'tipo': tipo,
        'titulo': titulo,
        'valor': valor,
        'valor_atual': 0,
        'data_conclusao': dataConclusao.toIso8601String(),
        'descricao': descricao,
        'status': 'ativa',
      };

      final response = await _supabase
          .from(_tableName)
          .insert(goalData)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Meta criada com sucesso!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao criar meta: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Obter todas as metas do usuário
  Future<List<Map<String, dynamic>>> getGoals({
    String? status, // 'ativa', 'concluida', 'cancelada'
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      var query = _supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('data_conclusao', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar metas: ${e.toString()}');
    }
  }

  /// Obter metas ativas
  Future<List<Map<String, dynamic>>> getActiveGoals() async {
    return await getGoals(status: 'ativa');
  }

  /// Obter metas concluídas
  Future<List<Map<String, dynamic>>> getCompletedGoals() async {
    return await getGoals(status: 'concluida');
  }

  /// Adicionar valor à meta
  /// O progresso é atualizado automaticamente pelo trigger
  Future<Map<String, dynamic>> addAmountToGoal({
    required String goalId,
    required double amount,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      if (amount <= 0) {
        throw Exception('O valor deve ser maior que zero');
      }

      // Buscar meta atual
      final currentGoal = await _supabase
          .from(_tableName)
          .select()
          .eq('id', goalId)
          .eq('usuario_id', userId)
          .single();

      final currentAmount = (currentGoal['valor_atual'] as num).toDouble();
      final newAmount = currentAmount + amount;

      // Atualizar valor atual (o trigger calcula o progresso)
      final response = await _supabase
          .from(_tableName)
          .update({'valor_atual': newAmount})
          .eq('id', goalId)
          .eq('usuario_id', userId)
          .select()
          .single();

      final progress = (response['progresso'] as num).toDouble();
      final isCompleted = response['status'] == 'concluida';

      return {
        'success': true,
        'message': isCompleted 
            ? '🎉 Parabéns! Meta concluída!' 
            : 'Valor adicionado! Progresso: ${progress.toStringAsFixed(1)}%',
        'data': response,
        'completed': isCompleted,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao adicionar valor: ${e.toString()}',
        'data': null,
        'completed': false,
      };
    }
  }

  /// Atualizar meta
  Future<Map<String, dynamic>> updateGoal({
    required String id,
    String? titulo,
    double? valor,
    DateTime? dataConclusao,
    String? descricao,
    String? status,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final updateData = <String, dynamic>{};
      if (titulo != null) updateData['titulo'] = titulo;
      if (valor != null) {
        if (valor <= 0) throw Exception('Valor deve ser maior que zero');
        updateData['valor'] = valor;
      }
      if (dataConclusao != null) {
        updateData['data_conclusao'] = dataConclusao.toIso8601String();
      }
      if (descricao != null) updateData['descricao'] = descricao;
      if (status != null) updateData['status'] = status;

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .eq('usuario_id', userId)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Meta atualizada!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao atualizar: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Deletar meta
  Future<Map<String, dynamic>> deleteGoal(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('usuario_id', userId);

      return {
        'success': true,
        'message': 'Meta deletada!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao deletar: ${e.toString()}',
      };
    }
  }

  /// Cancelar meta
  Future<Map<String, dynamic>> cancelGoal(String id) async {
    return await updateGoal(id: id, status: 'cancelada');
  }

  // ==================== ESTATÍSTICAS ====================

  /// Obter progresso geral das metas
  Future<Map<String, dynamic>> getOverallProgress() async {
    try {
      final goals = await getActiveGoals();
      
      if (goals.isEmpty) {
        return {
          'total_metas': 0,
          'progresso_medio': 0.0,
          'valor_total': 0.0,
          'valor_atual': 0.0,
        };
      }

      double totalTarget = 0;
      double totalCurrent = 0;
      double totalProgress = 0;

      for (var goal in goals) {
        totalTarget += (goal['valor'] as num).toDouble();
        totalCurrent += (goal['valor_atual'] as num).toDouble();
        totalProgress += (goal['progresso'] as num).toDouble();
      }

      return {
        'total_metas': goals.length,
        'progresso_medio': totalProgress / goals.length,
        'valor_total': totalTarget,
        'valor_atual': totalCurrent,
      };
    } catch (e) {
      throw Exception('Erro ao calcular progresso: ${e.toString()}');
    }
  }

  /// Atualizar progresso de meta com base em transações
  /// Usado quando uma nova transação é criada
  Future<void> updateGoalProgressFromTransaction({
    required String categoria,
    required double valor,
    required String tipo,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Buscar metas ativas relacionadas à categoria
      final goals = await _supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', userId)
          .eq('status', 'ativa')
          .eq('tipo', 'economia'); // Apenas metas de economia

      for (var goal in goals) {
        if (tipo == 'entrada') {
          // Adicionar valor à meta
          final currentAmount = (goal['valor_atual'] as num).toDouble();
          final newAmount = currentAmount + valor;

          await _supabase
              .from(_tableName)
              .update({'valor_atual': newAmount})
              .eq('id', goal['id']);
        }
      }
    } catch (e) {
      // Erro silencioso - não interrompe a execução
    }
  }

  /// Stream de metas em tempo real
  Stream<List<Map<String, dynamic>>> watchGoals() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('usuario_id', userId)
        .order('data_conclusao', ascending: true)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }
}
