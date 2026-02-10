import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import '../services/budget_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _transactionService = TransactionService();
  final _budgetService = BudgetService();
  
  Map<String, double> expensesByCategory = {};
  Map<String, double> incomesByCategory = {};
  Map<String, double> budgetByCategory = {}; // Orçamento anual por categoria
  bool _isLoading = true;
  String _selectedTab = 'despesas'; // 'despesas' ou 'receitas'
  
  // Filtros de data
  DateTime _selectedDate = DateTime.now();
  
  // Categorias padrão
  final List<String> _defaultExpenseCategories = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Saúde',
    'Educação',
    'Lazer',
    'Compras',
    'Contas',
    'Vestuário',
    'Beleza e Cuidados',
    'Pet',
    'Assinaturas',
    'Impostos',
    'Seguros',
    'Manutenção',
    'Viagem',
    'Presentes',
    'Doações',
    'Investimentos',
    'Outros Gastos',
  ];
  
  final List<String> _defaultIncomeCategories = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Bônus',
    'Décimo Terceiro',
    'Férias',
    'PLR',
    'Comissão',
    'Aluguel Recebido',
    'Dividendos',
    'Vendas',
    'Reembolso',
    'Prêmio',
    'Presente',
    'Pensão',
    'Restituição',
    'Renda Extra',
    'Outros Ganhos',
  ];
  
  List<String> _customCategories = [];

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final expenses = await _transactionService.getExpensesByCategory(
        month: _selectedDate.month,
        year: _selectedDate.year,
      );
      final incomes = await _transactionService.getIncomesByCategory(
        month: _selectedDate.month,
        year: _selectedDate.year,
      );
      
      // Carregar orçamento anual
      final budgets = await _budgetService.getBudgetCategories(
        month: 1, // Sempre mês 1 para orçamento anual
        year: _selectedDate.year,
      );
      
      setState(() {
        expensesByCategory = expenses;
        incomesByCategory = incomes;
        budgetByCategory = budgets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showMonthYearPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione o mês e ano',
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }
  
  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nome da Categoria',
                hintText: 'Ex: Farmácia, Uber, etc.',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _customCategories.add(controller.text.trim());
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Categoria "${controller.text.trim()}" adicionada!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
  
  void _deleteCategory(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Categoria'),
        content: Text('Deseja realmente excluir a categoria "$category"?\n\nAs transações existentes não serão afetadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _customCategories.remove(category);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Categoria "$category" excluída!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nova Categoria'),
        tooltip: 'Adicionar Categoria',
      ),
      body: Column(
        children: [
          // Filtro de Mês/Ano
          _buildMonthYearFilter(),
          
          // Abas
          _buildTabs(),
          
          // Conteúdo
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _selectedTab == 'despesas'
                        ? _buildCategoryList(_defaultExpenseCategories, expensesByCategory, Colors.red)
                        : _buildCategoryList(_defaultIncomeCategories, incomesByCategory, Colors.green),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthYearFilter() {
    final monthName = DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDate);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
              _loadData();
            },
            tooltip: 'Mês anterior',
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showMonthYearPicker,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    monthName[0].toUpperCase() + monthName.substring(1),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                );
              });
              _loadData();
            },
            tooltip: 'Próximo mês',
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 'despesas'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 'despesas' ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: _selectedTab == 'despesas' ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Despesas',
                      style: TextStyle(
                        color: _selectedTab == 'despesas' ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 'receitas'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 'receitas' ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: _selectedTab == 'receitas' ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Receitas',
                      style: TextStyle(
                        color: _selectedTab == 'receitas' ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<String> defaultCategories, Map<String, double> transactionData, Color color) {
    // Combinar categorias padrão e personalizadas
    final allCategories = [...defaultCategories, ..._customCategories];
    
    // Criar mapa com todas as categorias (incluindo as sem transações)
    final categoriesWithData = <String, double>{};
    for (var category in allCategories) {
      categoriesWithData[category] = transactionData[category] ?? 0.0;
    }
    
    // Adicionar categorias que existem nas transações mas não estão na lista padrão
    for (var entry in transactionData.entries) {
      if (!categoriesWithData.containsKey(entry.key)) {
        categoriesWithData[entry.key] = entry.value;
      }
    }
    
    // Ordenar: categorias com valor > 0 primeiro, depois alfabética
    final sortedCategories = categoriesWithData.entries.toList()
      ..sort((a, b) {
        if (a.value == 0 && b.value == 0) {
          return a.key.compareTo(b.key);
        }
        if (a.value == 0) return 1;
        if (b.value == 0) return -1;
        return b.value.compareTo(a.value);
      });

    final total = transactionData.values.fold(0.0, (a, b) => a + b);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final entry = sortedCategories[index];
        final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
        final hasTransactions = entry.value > 0;
        final isCustom = _customCategories.contains(entry.key);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: hasTransactions ? null : Colors.grey[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: hasTransactions 
                            ? color.withOpacity(0.1) 
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(entry.key),
                        color: hasTransactions ? color : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: hasTransactions ? null : Colors.grey,
                                ),
                              ),
                              if (isCustom) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'CUSTOM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasTransactions 
                                ? '${percentage.toStringAsFixed(1)}% do total'
                                : 'Sem transações neste mês',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          // Mostrar orçamento se existir
                          if (budgetByCategory.containsKey(entry.key)) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet, size: 12, color: Colors.blue[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'Orçado: ${_formatCurrency(budgetByCategory[entry.key]! / 12)}/mês',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${_formatCurrency(budgetByCategory[entry.key]!)}/ano)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isCustom)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(entry.key),
                        tooltip: 'Excluir categoria',
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCurrency(entry.value),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hasTransactions ? color : Colors.grey,
                      ),
                    ),
                  ],
                ),
                // Barra de progresso do percentual do total
                if (hasTransactions) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
                // Barra de progresso do orçamento
                if (budgetByCategory.containsKey(entry.key)) ...[
                  const SizedBox(height: 12),
                  _buildBudgetProgress(entry.key, entry.value, budgetByCategory[entry.key]!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBudgetProgress(String category, double spent, double budgetAnual) {
    // Orçamento mensal = orçamento anual / 12
    final budgetMensal = budgetAnual / 12;
    final percentualGasto = (spent / budgetMensal * 100).clamp(0, 100);
    final percentualExcedido = spent > budgetMensal ? ((spent - budgetMensal) / budgetMensal * 100) : 0.0;
    
    Color progressColor;
    String statusText;
    
    if (percentualGasto < 80) {
      progressColor = Colors.green;
      statusText = 'Dentro do orçamento';
    } else if (percentualGasto < 100) {
      progressColor = Colors.orange;
      statusText = 'Atenção ao orçamento';
    } else {
      progressColor = Colors.red;
      statusText = 'Orçamento excedido';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${percentualGasto.toStringAsFixed(0)}% usado',
              style: TextStyle(
                fontSize: 11,
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (percentualGasto / 100).clamp(0, 1),
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        if (spent > budgetMensal) ...[
          const SizedBox(height: 4),
          Text(
            'Excedido em ${_formatCurrency(spent - budgetMensal)}',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    final iconMap = {
      // Despesas
      'Alimentação': Icons.restaurant,
      'Transporte': Icons.directions_car,
      'Moradia': Icons.home,
      'Saúde': Icons.health_and_safety,
      'Educação': Icons.school,
      'Lazer': Icons.sports_esports,
      'Compras': Icons.shopping_bag,
      'Contas': Icons.receipt,
      'Vestuário': Icons.checkroom,
      'Beleza e Cuidados': Icons.spa,
      'Pet': Icons.pets,
      'Assinaturas': Icons.subscriptions,
      'Impostos': Icons.account_balance,
      'Seguros': Icons.security,
      'Manutenção': Icons.build,
      'Viagem': Icons.flight,
      'Presentes': Icons.card_giftcard,
      'Doações': Icons.favorite,
      'Investimentos': Icons.trending_up,
      'Outros Gastos': Icons.more_horiz,
      // Receitas
      'Salário': Icons.work,
      'Freelance': Icons.laptop,
      'Bônus': Icons.star,
      'Décimo Terceiro': Icons.celebration,
      'Férias': Icons.beach_access,
      'PLR': Icons.money,
      'Comissão': Icons.percent,
      'Aluguel Recebido': Icons.home_work,
      'Dividendos': Icons.show_chart,
      'Vendas': Icons.sell,
      'Reembolso': Icons.replay,
      'Prêmio': Icons.emoji_events,
      'Presente': Icons.redeem,
      'Pensão': Icons.account_balance_wallet,
      'Restituição': Icons.restore,
      'Renda Extra': Icons.add_business,
      'Outros Ganhos': Icons.attach_money,
    };
    return iconMap[category] ?? Icons.category;
  }
}
