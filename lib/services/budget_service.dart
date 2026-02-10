import '../services/supabase_service.dart';

class BudgetService {
  final _supabase = SupabaseService.instance.client;
  static const String _budgetTable = 'budgets';
  static const String _budgetCategoriesTable = 'budget_categories';

  /// Buscar ou criar orçamento do mês
  Future<Map<String, dynamic>?> getBudgetForMonth({
    required int month,
    required int year,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
          .from(_budgetTable)
          .select('*, budget_categories(*)')
          .eq('user_id', userId)
          .eq('mes', month)
          .eq('ano', year)
          .maybeSingle();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Criar ou atualizar orçamento
  Future<Map<String, dynamic>> saveBudget({
    required int month,
    required int year,
    required double receitaPlanejada,
    required Map<String, double> categorias,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      // Verificar se já existe orçamento
      final existing = await getBudgetForMonth(month: month, year: year);

      Map<String, dynamic> budget;

      if (existing != null) {
        // Atualizar orçamento existente
        final updated = await _supabase
            .from(_budgetTable)
            .update({
              'receita_planejada': receitaPlanejada,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id'])
            .select()
            .single();

        budget = updated;

        // Deletar categorias antigas
        await _supabase
            .from(_budgetCategoriesTable)
            .delete()
            .eq('budget_id', existing['id']);
      } else {
        // Criar novo orçamento
        final created = await _supabase
            .from(_budgetTable)
            .insert({
              'user_id': userId,
              'mes': month,
              'ano': year,
              'receita_planejada': receitaPlanejada,
            })
            .select()
            .single();

        budget = created;
      }

      // Inserir categorias
      if (categorias.isNotEmpty) {
        final categoriasData = categorias.entries.map((entry) {
          return {
            'budget_id': budget['id'],
            'categoria': entry.key,
            'valor_orcado': entry.value,
          };
        }).toList();

        await _supabase
            .from(_budgetCategoriesTable)
            .insert(categoriasData);
      }

      // Retornar orçamento completo
      return await getBudgetForMonth(month: month, year: year) ?? budget;
    } catch (e) {
      rethrow;
    }
  }

  /// Buscar categorias do orçamento
  Future<Map<String, double>> getBudgetCategories({
    required int month,
    required int year,
  }) async {
    try {
      final budget = await getBudgetForMonth(month: month, year: year);
      
      if (budget == null || budget['budget_categories'] == null) {
        return {};
      }

      final Map<String, double> result = {};
      for (var cat in budget['budget_categories']) {
        result[cat['categoria']] = (cat['valor_orcado'] as num).toDouble();
      }

      return result;
    } catch (e) {
      return {};
    }
  }

  /// Deletar orçamento
  Future<void> deleteBudget({
    required int month,
    required int year,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _supabase
          .from(_budgetTable)
          .delete()
          .eq('user_id', userId)
          .eq('mes', month)
          .eq('ano', year);
    } catch (e) {
      rethrow;
    }
  }

  /// Verificar se existe orçamento para o mês
  Future<bool> hasBudgetForMonth({
    required int month,
    required int year,
  }) async {
    try {
      final budget = await getBudgetForMonth(month: month, year: year);
      return budget != null;
    } catch (e) {
      return false;
    }
  }

  /// Calcular percentual usado do orçamento por categoria
  Future<Map<String, Map<String, dynamic>>> getBudgetProgress({
    required int month,
    required int year,
    required Map<String, double> actualExpenses,
  }) async {
    try {
      final budgetCategories = await getBudgetCategories(
        month: month,
        year: year,
      );

      final Map<String, Map<String, dynamic>> progress = {};

      // Para cada categoria orçada
      for (var entry in budgetCategories.entries) {
        final categoria = entry.key;
        final orcado = entry.value;
        final gasto = actualExpenses[categoria] ?? 0.0;
        final restante = orcado - gasto;
        final percentual = orcado > 0 ? (gasto / orcado * 100) : 0.0;

        progress[categoria] = {
          'orcado': orcado,
          'gasto': gasto,
          'restante': restante,
          'percentual': percentual,
          'status': _getStatus(percentual),
        };
      }

      return progress;
    } catch (e) {
      return {};
    }
  }

  /// Determinar status do orçamento
  String _getStatus(double percentual) {
    if (percentual <= 80) {
      return 'ok'; // Verde
    } else if (percentual <= 100) {
      return 'warning'; // Amarelo
    } else {
      return 'exceeded'; // Vermelho
    }
  }

  /// Obter resumo do orçamento total
  Future<Map<String, dynamic>> getBudgetSummary({
    required int month,
    required int year,
    required Map<String, double> actualExpenses,
  }) async {
    try {
      final budget = await getBudgetForMonth(month: month, year: year);
      
      if (budget == null) {
        return {
          'tem_orcamento': false,
        };
      }

      final receitaPlanejada = (budget['receita_planejada'] as num).toDouble();
      final categorias = await getBudgetCategories(month: month, year: year);
      final totalOrcado = categorias.values.fold(0.0, (a, b) => a + b);
      final totalGasto = actualExpenses.values.fold(0.0, (a, b) => a + b);
      final saldoPlanejado = receitaPlanejada - totalOrcado;
      final saldoReal = receitaPlanejada - totalGasto;

      return {
        'tem_orcamento': true,
        'receita_planejada': receitaPlanejada,
        'total_orcado': totalOrcado,
        'total_gasto': totalGasto,
        'saldo_planejado': saldoPlanejado,
        'saldo_real': saldoReal,
        'percentual_usado': receitaPlanejada > 0 
            ? (totalGasto / receitaPlanejada * 100) 
            : 0.0,
        'categorias_count': categorias.length,
      };
    } catch (e) {
      return {
        'tem_orcamento': false,
      };
    }
  }
}
