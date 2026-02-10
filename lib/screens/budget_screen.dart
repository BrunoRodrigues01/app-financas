import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/budget_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetService = BudgetService();
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;
  String _selectedTab = 'despesas'; // 'despesas' ou 'receitas'
  
  // Categorias padrão de despesas
  final List<String> _expenseCategories = [
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
  
  // Categorias padrão de receitas
  final List<String> _incomeCategories = [
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
  
  Map<String, TextEditingController> _expenseCategoryControllers = {};
  Map<String, TextEditingController> _incomeCategoryControllers = {};
  Map<String, double> _expenseBudgets = {};
  Map<String, double> _incomeBudgets = {};
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadBudget();
  }
  
  void _initializeControllers() {
    for (var category in _expenseCategories) {
      _expenseCategoryControllers[category] = TextEditingController();
    }
    for (var category in _incomeCategories) {
      _incomeCategoryControllers[category] = TextEditingController();
    }
  }
  
  @override
  void dispose() {
    for (var controller in _expenseCategoryControllers.values) {
      controller.dispose();
    }
    for (var controller in _incomeCategoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  Future<void> _loadBudget() async {
    setState(() => _isLoading = true);
    
    try {
      // Carregar orçamento do ano (fixo no mês 1)
      final budget = await _budgetService.getBudgetForMonth(
        month: 1, // Sempre mês 1 para orçamento anual
        year: _selectedDate.year,
      );
      
      if (budget != null) {
        // Carregar categorias
        final categories = await _budgetService.getBudgetCategories(
          month: 1, // Sempre mês 1 para orçamento anual
          year: _selectedDate.year,
        );
        
        setState(() {
          // Separar despesas e receitas
          _expenseBudgets = {};
          _incomeBudgets = {};
          
          for (var entry in categories.entries) {
            if (_expenseCategories.contains(entry.key)) {
              _expenseBudgets[entry.key] = entry.value;
              if (_expenseCategoryControllers.containsKey(entry.key)) {
                _expenseCategoryControllers[entry.key]!.text = _formatCurrencyInput(entry.value / 12);
              }
            } else if (_incomeCategories.contains(entry.key)) {
              _incomeBudgets[entry.key] = entry.value;
              if (_incomeCategoryControllers.containsKey(entry.key)) {
                _incomeCategoryControllers[entry.key]!.text = _formatCurrencyInput(entry.value / 12);
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar orçamento: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _saveBudget() async {
    setState(() => _isSaving = true);
    
    try {
      // Coletar TODAS as categorias (despesas + receitas) com valores mensais e converter para anual
      final Map<String, double> categorias = {};
      
      // Despesas
      for (var entry in _expenseCategoryControllers.entries) {
        final text = entry.value.text.trim();
        if (text.isNotEmpty) {
          final valorMensal = _parseCurrency(text);
          if (valorMensal > 0) {
            categorias[entry.key] = valorMensal * 12; // Salvar valor anual
          }
        }
      }
      
      // Receitas
      double totalReceitasAnual = 0.0;
      for (var entry in _incomeCategoryControllers.entries) {
        final text = entry.value.text.trim();
        if (text.isNotEmpty) {
          final valorMensal = _parseCurrency(text);
          if (valorMensal > 0) {
            final valorAnual = valorMensal * 12;
            categorias[entry.key] = valorAnual; // Salvar valor anual
            totalReceitasAnual += valorAnual;
          }
        }
      }
      
      // Calcular total de receitas (soma das categorias de receita)
      // Usar 0 se não houver receitas definidas
      final receitaPlanejada = totalReceitasAnual > 0 ? totalReceitasAnual : 0.0;
      
      await _budgetService.saveBudget(
        month: 1, // Sempre mês 1 para orçamento anual
        year: _selectedDate.year,
        receitaPlanejada: receitaPlanejada,
        categorias: categorias,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Orçamento salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBudget();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }
  
  void _showMonthYearPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      initialDatePickerMode: DatePickerMode.year, // Mostrar seletor de ano
    );
    
    if (picked != null && picked.year != _selectedDate.year) {
      setState(() => _selectedDate = DateTime(picked.year, 1, 1)); // Sempre janeiro
      _loadBudget();
    }
  }
  
  double _getTotalOrcado() {
    double total = 0.0;
    final controllers = _selectedTab == 'despesas' ? _expenseCategoryControllers : _incomeCategoryControllers;
    for (var controller in controllers.values) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        try {
          total += _parseCurrency(text);
        } catch (e) {
          // Ignora erros de conversão
        }
      }
    }
    return total;
  }
  
  double _getTotalReceitas() {
    double total = 0.0;
    for (var controller in _incomeCategoryControllers.values) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        try {
          total += _parseCurrency(text);
        } catch (e) {
          // Ignora erros de conversão
        }
      }
    }
    return total;
  }
  
  double _getTotalDespesas() {
    double total = 0.0;
    for (var controller in _expenseCategoryControllers.values) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        try {
          total += _parseCurrency(text);
        } catch (e) {
          // Ignora erros de conversão
        }
      }
    }
    return total;
  }
  
  double _getSaldoDisponivel() {
    return _getTotalReceitas() - _getTotalDespesas();
  }
  
  // Formatar valor para moeda brasileira
  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
  
  // Formatar valor para input (sem R$, com vírgula)
  String _formatCurrencyInput(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }
  
  // Converter texto em número (aceita vírgula e ponto)
  double _parseCurrency(String text) {
    final cleaned = text.trim().replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.');
    return double.parse(cleaned);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamento Anual'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveBudget,
            tooltip: 'Salvar Orçamento',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seletor de Ano
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, color: Colors.blue),
                      title: Text(
                        'Ano ${_selectedDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Clique para alterar'),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _showMonthYearPicker,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Resumo
                  _buildSummaryCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Abas: Despesas ou Receitas
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Categorias
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                color: _selectedTab == 'despesas' ? Colors.red[700] : Colors.green[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedTab == 'despesas' 
                                    ? 'Orçamento de Despesas' 
                                    : 'Orçamento de Receitas',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedTab == 'despesas'
                                ? 'Defina quanto quer gastar por mês em cada categoria (será multiplicado por 12 automaticamente)'
                                : 'Defina quanto espera receber por mês em cada categoria (será multiplicado por 12 automaticamente)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Lista de categorias baseada na aba selecionada
                          ...(_selectedTab == 'despesas' ? _expenseCategories : _incomeCategories).map((category) {
                            final controller = _selectedTab == 'despesas' 
                                ? _expenseCategoryControllers[category]! 
                                : _incomeCategoryControllers[category]!;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextField(
                                controller: controller,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                                ],
                                decoration: InputDecoration(
                                  labelText: category,
                                  prefixText: 'R\$ ',
                                  border: const OutlineInputBorder(),
                                  hintText: '0,00',
                                  suffixIcon: controller.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            setState(() {
                                              controller.clear();
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                onChanged: (value) => setState(() {}),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 80), // Espaço para o botão flutuante
                ],
              ),
            ),
      floatingActionButton: _isSaving
          ? const CircularProgressIndicator()
          : FloatingActionButton.extended(
              onPressed: _saveBudget,
              icon: const Icon(Icons.save),
              label: const Text('Salvar Orçamento'),
              backgroundColor: Colors.blue,
            ),
    );
  }
  
  Widget _buildSummaryCard() {
    final totalReceitasMensal = _getTotalReceitas();
    final totalReceitasAnual = totalReceitasMensal * 12;
    final totalDespesasMensal = _getTotalDespesas();
    final totalDespesasAnual = totalDespesasMensal * 12;
    final saldoMensal = totalReceitasMensal - totalDespesasMensal;
    final saldoAnual = saldoMensal * 12;
    final percentualUsado = totalReceitasMensal > 0
        ? (totalDespesasMensal / totalReceitasMensal * 100)
        : 0.0;
    
    return Card(
      color: saldoMensal >= 0 ? Colors.blue[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: saldoMensal >= 0 ? Colors.blue[700] : Colors.red[700],
                ),
                const SizedBox(width: 8),
                const Text(
                  'Resumo do Orçamento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Valores mensais
            Text(
              'Valores Mensais',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow('Receitas/mês', totalReceitasMensal, Colors.green),
            const SizedBox(height: 4),
            _buildSummaryRow('Despesas/mês', totalDespesasMensal, Colors.red),
            const SizedBox(height: 4),
            _buildSummaryRow(
              'Saldo/mês',
              saldoMensal,
              saldoMensal >= 0 ? Colors.blue : Colors.red,
            ),
            
            const SizedBox(height: 12),
            
            // Valores anuais
            Text(
              'Valores Anuais (x12)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow('Receitas/ano', totalReceitasAnual, Colors.green[300]!),
            const SizedBox(height: 4),
            _buildSummaryRow('Despesas/ano', totalDespesasAnual, Colors.red[300]!),
            const SizedBox(height: 4),
            _buildSummaryRow(
              'Saldo/ano',
              saldoAnual,
              saldoAnual >= 0 ? Colors.blue[300]! : Colors.red[300]!,
            ),
            
            if (totalReceitasMensal > 0) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Orçamento utilizado',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    '${percentualUsado.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: percentualUsado > 100 ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (percentualUsado / 100).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentualUsado > 100 ? Colors.red : Colors.blue,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          _formatCurrency(value),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
