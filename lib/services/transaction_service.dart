import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class TransactionService {
  final _supabase = SupabaseService.instance.client;
  final String _tableName = 'transacoes';

  // ==================== CRUD TRANSAÇÕES ====================

  /// Adicionar nova transação
  /// Valida os dados e atualiza o saldo automaticamente via trigger
  Future<Map<String, dynamic>> addTransaction({
    required String tipo, // 'entrada' ou 'saida'
    required String categoria,
    required double valor,
    String? descricao,
    DateTime? data,
    bool? pago,
    DateTime? dataVencimento,
    DateTime? dataPagamento,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      // Validações
      if (valor <= 0) {
        throw Exception('O valor deve ser maior que zero');
      }
      if (tipo != 'entrada' && tipo != 'saida') {
        throw Exception('Tipo inválido. Use "entrada" ou "saida"');
      }
      if (categoria.isEmpty) {
        throw Exception('Categoria é obrigatória');
      }

      final transactionData = {
        'usuario_id': userId,
        'tipo': tipo,
        'categoria': categoria,
        'valor': valor,
        'descricao': descricao,
        'data': (data ?? DateTime.now()).toIso8601String(),
      };

      // Adicionar campos de pagamento para TODAS as transações (receitas e despesas)
      if (pago != null) {
        transactionData['pago'] = pago;
      }
      if (dataVencimento != null) {
        transactionData['data_vencimento'] = dataVencimento.toIso8601String().split('T')[0];
      }
      if (dataPagamento != null && (pago == true)) {
        transactionData['data_pagamento'] = dataPagamento.toIso8601String().split('T')[0];
      }

      final response = await _supabase
          .from(_tableName)
          .insert(transactionData)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Transação adicionada com sucesso!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao adicionar transação: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Obter todas as transações do usuário
  Future<List<Map<String, dynamic>>> getTransactions({
    int? limit,
    String? tipo,
    String? categoria,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      dynamic query = _supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', userId);

      if (tipo != null) {
        query = query.eq('tipo', tipo);
      }
      if (categoria != null) {
        query = query.eq('categoria', categoria);
      }
      
      query = query.order('data', ascending: false);
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar transações: ${e.toString()}');
    }
  }

  /// Obter transações por período
  Future<List<Map<String, dynamic>>> getTransactionsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    String? tipo,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      dynamic query = _supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', userId)
          .gte('data', startDate.toIso8601String())
          .lte('data', endDate.toIso8601String());

      if (tipo != null) {
        query = query.eq('tipo', tipo);
      }
      
      query = query.order('data', ascending: false);

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar transações: ${e.toString()}');
    }
  }

  /// Atualizar transação
  Future<Map<String, dynamic>> updateTransaction({
    required String id,
    String? tipo,
    String? categoria,
    double? valor,
    String? descricao,
    DateTime? data,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final updateData = <String, dynamic>{};
      if (tipo != null) updateData['tipo'] = tipo;
      if (categoria != null) updateData['categoria'] = categoria;
      if (valor != null) {
        if (valor <= 0) throw Exception('Valor deve ser maior que zero');
        updateData['valor'] = valor;
      }
      if (descricao != null) updateData['descricao'] = descricao;
      if (data != null) updateData['data'] = data.toIso8601String();

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .eq('usuario_id', userId)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Transação atualizada!',
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

  /// Deletar transação
  Future<Map<String, dynamic>> deleteTransaction(String id) async {
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
        'message': 'Transação deletada!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao deletar: ${e.toString()}',
      };
    }
  }

  // ==================== ESTATÍSTICAS ====================

  /// Obter estatísticas do mês atual
  Future<Map<String, dynamic>> getMonthlyStats({
    int? month,
    int? year,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final now = DateTime.now();
      final targetMonth = month ?? now.month;
      final targetYear = year ?? now.year;

      // Calcular período do mês
      final startOfMonth = DateTime(targetYear, targetMonth, 1);
      final endOfMonth = DateTime(targetYear, targetMonth + 1, 0, 23, 59, 59);

      // Buscar transações do período
      final transactions = await getTransactionsByPeriod(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      // Calcular totais
      double totalEntradas = 0.0;
      double totalSaidas = 0.0;

      for (var transaction in transactions) {
        final valor = (transaction['valor'] as num).toDouble();
        final tipo = transaction['tipo'] as String;

        if (tipo == 'entrada') {
          totalEntradas += valor;
        } else if (tipo == 'saida') {
          totalSaidas += valor;
        }
      }

      return {
        'total_entradas': totalEntradas,
        'total_saidas': totalSaidas,
        'saldo_mes': totalEntradas - totalSaidas,
        'transacoes_count': transactions.length,
      };
    } catch (e) {
      // Retornar valores zerados em caso de erro
      return {
        'total_entradas': 0.0,
        'total_saidas': 0.0,
        'saldo_mes': 0.0,
        'transacoes_count': 0,
      };
    }
  }

  /// Obter gastos por categoria no mês
  Future<Map<String, double>> getExpensesByCategory({
    int? month,
    int? year,
  }) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(
        year ?? now.year,
        month ?? now.month,
        1,
      );
      final endOfMonth = DateTime(
        year ?? now.year,
        (month ?? now.month) + 1,
        0,
        23,
        59,
        59,
      );

      final transactions = await getTransactionsByPeriod(
        startDate: startOfMonth,
        endDate: endOfMonth,
        tipo: 'saida',
      );

      final Map<String, double> categoryTotals = {};
      
      for (var transaction in transactions) {
        final category = transaction['categoria'] as String;
        final amount = (transaction['valor'] as num).toDouble();
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }

      return categoryTotals;
    } catch (e) {
      throw Exception('Erro ao calcular gastos: ${e.toString()}');
    }
  }

  /// Obter receitas por categoria
  Future<Map<String, double>> getIncomesByCategory({
    int? year,
    int? month,
  }) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(
        year ?? now.year,
        month ?? now.month,
        1,
      );
      final endOfMonth = DateTime(
        year ?? now.year,
        (month ?? now.month) + 1,
        0,
        23,
        59,
        59,
      );

      final transactions = await getTransactionsByPeriod(
        startDate: startOfMonth,
        endDate: endOfMonth,
        tipo: 'entrada',
      );

      final Map<String, double> categoryTotals = {};
      
      for (var transaction in transactions) {
        final category = transaction['categoria'] as String;
        final amount = (transaction['valor'] as num).toDouble();
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }

      return categoryTotals;
    } catch (e) {
      throw Exception('Erro ao calcular receitas: ${e.toString()}');
    }
  }

  /// Stream de transações em tempo real
  Stream<List<Map<String, dynamic>>> watchTransactions() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('usuario_id', userId)
        .order('data', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // ==================== CONTROLE DE PAGAMENTOS ====================

  /// Marcar uma despesa como paga
  Future<Map<String, dynamic>> markAsPaid(
    String transactionId, {
    DateTime? paymentDate,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      // Usar a função do banco de dados
      final response = await _supabase.rpc(
        'marcar_como_pago',
        params: {
          'transaction_id': transactionId,
          'payment_date': (paymentDate ?? DateTime.now()).toIso8601String().split('T')[0],
        },
      ).single();

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'],
        };
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao marcar como paga: ${e.toString()}',
      };
    }
  }

  /// Desmarcar pagamento de uma despesa
  Future<Map<String, dynamic>> unmarkPaid(String transactionId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase.rpc(
        'desmarcar_pagamento',
        params: {'transaction_id': transactionId},
      ).single();

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'],
        };
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao desmarcar pagamento: ${e.toString()}',
      };
    }
  }

  /// Obter estatísticas de pagamento do mês
  Future<Map<String, dynamic>> getPaymentStatistics({
    required int month,
    required int year,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase.rpc(
        'get_payment_statistics',
        params: {
          'user_uuid': userId,
          'target_month': month,
          'target_year': year,
        },
      ).single();

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao obter estatísticas: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Obter despesas pendentes (não pagas)
  Future<List<Map<String, dynamic>>> getPendingExpenses() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
          .from('despesas_pendentes')
          .select()
          .eq('usuario_id', userId)
          .order('data_vencimento', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Obter despesas atrasadas
  Future<List<Map<String, dynamic>>> getOverdueExpenses() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', userId)
          .eq('tipo', 'saida')
          .eq('pago', false)
          .not('data_vencimento', 'is', null)
          .lt('data_vencimento', today)
          .order('data_vencimento', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Obter próximos vencimentos (próximos N dias)
  Future<List<Map<String, dynamic>>> getUpcomingDueExpenses({int days = 7}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final today = DateTime.now();
      final futureDate = today.add(Duration(days: days));
      
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', userId)
          .eq('tipo', 'saida')
          .eq('pago', false)
          .gte('data_vencimento', today.toIso8601String().split('T')[0])
          .lte('data_vencimento', futureDate.toIso8601String().split('T')[0])
          .order('data_vencimento', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
