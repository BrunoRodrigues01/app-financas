import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../services/transaction_service.dart';
import '../services/supabase_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  final _transactionService = TransactionService();
  final _supabaseService = SupabaseService.instance;
  
  late TabController _tabController;
  
  Map<String, dynamic> stats = {
    'total_entradas': 0.0,
    'total_saidas': 0.0,
    'saldo_mes': 0.0,
    'transacoes_count': 0,
  };
  Map<String, double> expensesByCategory = {};
  Map<String, double> incomeByCategory = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPremium = false;
  
  // Filtro de período
  DateTime _selectedDate = DateTime.now();
  
  // Filtros avançados
  String? _selectedCategory;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  double? _minValueFilter;
  double? _maxValueFilter;
  String? _descriptionFilter;
  bool _showFilters = false;
  
  // Para detalhamento de categoria
  List<Map<String, dynamic>> _categoryTransactions = [];

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
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _checkPremiumStatus();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _checkPremiumStatus() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId != null) {
        final userData = await _supabaseService.client
            .from('usuarios')
            .select('is_premium')
            .eq('id', userId)
            .single();
        
        setState(() {
          _isPremium = userData['is_premium'] ?? false;
        });
      }
    } catch (e) {
      // Erro ao verificar premium - continua com false
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final statsData = await _transactionService.getMonthlyStats(
        month: _selectedDate.month,
        year: _selectedDate.year,
      );
      
      final expensesData = await _transactionService.getExpensesByCategory(
        month: _selectedDate.month,
        year: _selectedDate.year,
      );
      
      final incomesData = await _transactionService.getIncomesByCategory(
        month: _selectedDate.month,
        year: _selectedDate.year,
      );
      
      if (mounted) {
        setState(() {
          stats = statsData;
          expensesByCategory = expensesData;
          incomeByCategory = incomesData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.assessment),
              text: 'Básicos',
            ),
            Tab(
              icon: Icon(Icons.diamond),
              text: 'Premium',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Seletor de mês/ano
          Container(
            color: colorScheme.primary,
            child: _buildMonthYearSelector(),
          ),
          
          // Conteúdo das tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Básicos
                _buildBasicReports(),
                
                // Tab Premium
                _buildPremiumReports(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthYearSelector() {
    final monthName = DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDate);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
              _loadData();
            },
          ),
          InkWell(
            onTap: _showMonthYearPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    monthName.substring(0, 1).toUpperCase() + monthName.substring(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                );
              });
              _loadData();
            },
          ),
        ],
      ),
    );
  }
  
  Future<void> _showMonthYearPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }
  
  Widget _buildBasicReports() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando relatórios...'),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Erro ao carregar relatórios'),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cards de resumo
          _buildSummaryCards(),
          const SizedBox(height: 20),
          
          // Resumo do Mês
          _buildMonthlyResume(),
          const SizedBox(height: 20),
          
          // Gastos por Categoria
          _buildExpensesByCategory(),
          const SizedBox(height: 20),
          
          // Receitas por Categoria
          _buildIncomeByCategory(),
          const SizedBox(height: 20),
          
          // Balanço
          _buildBalance(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCards() {
    final totalEntradas = (stats['total_entradas'] as num?)?.toDouble() ?? 0.0;
    final totalSaidas = (stats['total_saidas'] as num?)?.toDouble() ?? 0.0;
    final saldo = totalEntradas - totalSaidas;
    
    return Row(
      children: [
        Expanded(
          child: _buildMiniCard(
            'Receitas',
            _formatCurrency(totalEntradas),
            Icons.arrow_downward,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniCard(
            'Despesas',
            _formatCurrency(totalSaidas),
            Icons.arrow_upward,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniCard(
            'Saldo',
            _formatCurrency(saldo),
            Icons.account_balance_wallet,
            saldo >= 0 ? Colors.blue : Colors.orange,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMiniCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyResume() {
    final totalEntradas = (stats['total_entradas'] as num?)?.toDouble() ?? 0.0;
    final totalSaidas = (stats['total_saidas'] as num?)?.toDouble() ?? 0.0;
    final transacoesCount = stats['transacoes_count'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Resumo do Mês',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Receitas
            _buildStatRow(
              icon: Icons.arrow_downward,
              iconColor: Colors.green,
              label: 'Receitas',
              value: _formatCurrency(totalEntradas),
            ),
            const SizedBox(height: 12),
            
            // Despesas
            _buildStatRow(
              icon: Icons.arrow_upward,
              iconColor: Colors.red,
              label: 'Despesas',
              value: _formatCurrency(totalSaidas),
            ),
            const SizedBox(height: 12),
            
            // Transações
            _buildStatRow(
              icon: Icons.receipt_long,
              iconColor: Colors.blue,
              label: 'Transações',
              value: transacoesCount.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesByCategory() {
    if (expensesByCategory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma despesa registrada',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sortedExpenses = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = expensesByCategory.values.fold(0.0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Gastos por Categoria',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            ...sortedExpenses.map((entry) {
              final percentage = (entry.value / total * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(_getCategoryIcon(entry.key), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatCurrency(entry.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage / 100,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(entry.key),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}% do total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalance() {
    final totalEntradas = (stats['total_entradas'] as num?)?.toDouble() ?? 0.0;
    final totalSaidas = (stats['total_saidas'] as num?)?.toDouble() ?? 0.0;
    final saldo = totalEntradas - totalSaidas;
    final isPositive = saldo >= 0;

    return Card(
      color: isPositive ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              size: 48,
              color: isPositive ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              'Balanço do Mês',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${isPositive ? '+' : ''}${_formatCurrency(saldo.abs())}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPositive
                  ? 'Você economizou este mês! 🎉'
                  : 'Despesas maiores que receitas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIncomeByCategory() {
    if (incomeByCategory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.attach_money, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma receita registrada',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sortedIncome = incomeByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = incomeByCategory.values.fold(0.0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Receitas por Categoria',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            ...sortedIncome.map((entry) {
              final percentage = (entry.value / total * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(_getCategoryIcon(entry.key), size: 20, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatCurrency(entry.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage / 100,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}% do total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPremiumReports() {
    if (!_isPremium) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              // Ícone Premium
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.diamond,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Título
              Text(
                'Relatórios Premium',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              
              // Descrição
              Text(
                'Desbloqueie relatórios avançados e análises detalhadas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // Lista de recursos
              _buildFeatureItem(
                Icons.bar_chart,
                'Gráficos Detalhados',
                'Visualize suas finanças com gráficos interativos',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.analytics,
                'Análise de Tendências',
                'Acompanhe tendências de gastos ao longo do tempo',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.compare_arrows,
                'Comparação de Períodos',
                'Compare meses e anos para tomar melhores decisões',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.pie_chart,
                'Relatórios Personalizados',
                'Crie relatórios customizados para suas necessidades',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.download,
                'Exportar PDF/Excel',
                'Exporte seus dados para compartilhar ou arquivar',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.insights,
                'Insights com IA',
                'Receba sugestões inteligentes para otimizar suas finanças',
              ),
              const SizedBox(height: 32),
              
              // Botão de upgrade
              ElevatedButton(
                onPressed: () {
                  _showUpgradeDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.diamond, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Assinar Premium',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A partir de R\$ 9,90/mês',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      );
    }
    
    // Conteúdo para usuários premium
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Barra de ações premium
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.filter_alt,
                    label: 'Filtros',
                    onTap: _showAdvancedFilters,
                    color: Colors.blue,
                  ),
                  _buildActionButton(
                    icon: Icons.picture_as_pdf,
                    label: 'Exportar PDF',
                    onTap: _exportToPDF,
                    color: Colors.red,
                  ),
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Atualizar',
                    onTap: _loadData,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Análise de Tendências
          _buildTrendAnalysis(),
          const SizedBox(height: 20),
          
          // NOVO: Insights Inteligentes
          _buildSmartInsights(),
          const SizedBox(height: 20),
          
          // NOVO: Gráfico de Pizza - Categorias
          _buildCategoryPieChart(),
          const SizedBox(height: 20),
          
          // Comparação Mensal
          _buildMonthlyComparison(),
          const SizedBox(height: 20),
          
          // Top Categorias
          _buildTopCategories(),
          const SizedBox(height: 20),
          
          // NOVO: Métricas Avançadas
          _buildAdvancedMetrics(),
          const SizedBox(height: 20),
          
          // Dicas Personalizadas
          _buildPersonalizedTips(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.amber[700], size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.diamond, color: Colors.amber),
            SizedBox(width: 8),
            Text('Assinar Premium'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escolha seu plano:'),
            const SizedBox(height: 16),
            _buildPlanOption('Mensal', 'R\$ 9,90', '/mês'),
            const SizedBox(height: 12),
            _buildPlanOption('Anual', 'R\$ 99,00', '/ano (economize 17%)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade em desenvolvimento'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('Assinar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlanOption(String name, String price, String period) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
  
  // Widgets para usuários Premium
  Widget _buildTrendAnalysis() {
    // Dados dos últimos 6 meses (simulado)
    final months = ['Ago', 'Set', 'Out', 'Nov', 'Dez', 'Jan'];
    final receitas = [4500.0, 5200.0, 4800.0, 6000.0, 5500.0, 8000.0];
    final despesas = [4200.0, 4800.0, 5100.0, 5500.0, 6000.0, 6329.20];
    
    final maxValue = [...receitas, ...despesas].reduce((a, b) => a > b ? a : b);
    
    // Calcular crescimento
    final crescimentoReceitas = ((receitas.last - receitas.first) / receitas.first * 100);
    final crescimentoDespesas = ((despesas.last - despesas.first) / despesas.first * 100);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.trending_up, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Análise de Tendências',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Últimos 6 meses',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            
            // Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.green, 'Receitas'),
                const SizedBox(width: 20),
                _buildLegendItem(Colors.red, 'Despesas'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Gráfico de barras LADO A LADO
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(months.length, (index) {
                  final receitaHeight = (receitas[index] / maxValue) * 120;
                  final despesaHeight = (despesas[index] / maxValue) * 120;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Duas barras lado a lado
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Barra de Receitas (verde)
                              Expanded(
                                child: Tooltip(
                                  message: 'Receitas: ${_formatCurrency(receitas[index])}',
                                  child: Container(
                                    height: receitaHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [Colors.green[700]!, Colors.green[400]!],
                                      ),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              // Barra de Despesas (vermelha)
                              Expanded(
                                child: Tooltip(
                                  message: 'Despesas: ${_formatCurrency(despesas[index])}',
                                  child: Container(
                                    height: despesaHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [Colors.red[700]!, Colors.red[400]!],
                                      ),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Label do mês
                          Text(
                            months[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Insights inteligentes
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: crescimentoReceitas > 0 
                            ? [Colors.green[50]!, Colors.green[100]!]
                            : [Colors.orange[50]!, Colors.orange[100]!],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: crescimentoReceitas > 0 ? Colors.green[300]! : Colors.orange[300]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          crescimentoReceitas > 0 ? Icons.trending_up : Icons.trending_down,
                          color: crescimentoReceitas > 0 ? Colors.green[700] : Colors.orange[700],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${crescimentoReceitas.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: crescimentoReceitas > 0 ? Colors.green[900] : Colors.orange[900],
                          ),
                        ),
                        Text(
                          'Receitas',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: crescimentoDespesas < 20 
                            ? [Colors.blue[50]!, Colors.blue[100]!]
                            : [Colors.red[50]!, Colors.red[100]!],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: crescimentoDespesas < 20 ? Colors.blue[300]! : Colors.red[300]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: crescimentoDespesas < 20 ? Colors.blue[700] : Colors.red[700],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${crescimentoDespesas.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: crescimentoDespesas < 20 ? Colors.blue[900] : Colors.red[900],
                          ),
                        ),
                        Text(
                          'Despesas',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
  
  Widget _buildMonthlyComparison() {
    // Calcular dados reais baseados nas stats
    final mesAtualReceitas = stats['total_entradas'] ?? 0.0;
    final mesAtualDespesas = stats['total_saidas'] ?? 0.0;
    final mesAtualSaldo = stats['saldo_mes'] ?? 0.0;
    
    // Dados simulados do mês anterior para comparação
    final mesAnteriorReceitas = 5500.0;
    final mesAnteriorDespesas = 6000.0;
    
    final variacaoReceitas = mesAnteriorReceitas > 0 
        ? ((mesAtualReceitas - mesAnteriorReceitas) / mesAnteriorReceitas * 100)
        : 0.0;
    final variacaoDespesas = mesAnteriorDespesas > 0
        ? ((mesAtualDespesas - mesAnteriorDespesas) / mesAnteriorDespesas * 100)
        : 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.compare_arrows, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Comparação Mensal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Comparado com o mês anterior',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            
            // Card de Receitas
            _buildComparisonCard(
              'Receitas',
              mesAtualReceitas,
              mesAnteriorReceitas,
              variacaoReceitas,
              Colors.green,
              Icons.arrow_upward,
            ),
            const SizedBox(height: 12),
            
            // Card de Despesas
            _buildComparisonCard(
              'Despesas',
              mesAtualDespesas,
              mesAnteriorDespesas,
              variacaoDespesas,
              Colors.red,
              Icons.arrow_downward,
            ),
            const SizedBox(height: 12),
            
            // Card de Saldo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: mesAtualSaldo >= 0 
                      ? [Colors.green[50]!, Colors.green[100]!]
                      : [Colors.red[50]!, Colors.red[100]!],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: mesAtualSaldo >= 0 ? Colors.green : Colors.red,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        mesAtualSaldo >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: mesAtualSaldo >= 0 ? Colors.green[700] : Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Saldo do Mês',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(mesAtualSaldo),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: mesAtualSaldo >= 0 ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mesAtualSaldo >= 0 
                        ? '${mesAtualSaldo > 0 ? "Você economizou!" : "Equilibrado"}' 
                        : 'Atenção: Despesas excederam receitas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildComparisonCard(
    String title, 
    double valorAtual, 
    double valorAnterior, 
    double variacao,
    Color color,
    IconData icon,
  ) {
    final isPositive = variacao > 0;
    final variacaoAbs = variacao.abs();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive 
                      ? (title == 'Despesas' ? Colors.red : Colors.green)
                      : (title == 'Despesas' ? Colors.green : Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${variacaoAbs.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mês Atual',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(valorAtual),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Mês Anterior',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(valorAnterior),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopCategories() {
    // Pegar top 3 categorias de despesas reais
    final sortedExpenses = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final top3 = sortedExpenses.take(3).toList();
    
    if (top3.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Nenhuma despesa registrada',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    
    final totalDespesas = sortedExpenses.fold<double>(
      0, (sum, entry) => sum + entry.value
    );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.emoji_events, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Top 3 Categorias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Suas maiores despesas este mês',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            
            ...List.generate(top3.length, (index) {
              final entry = top3[index];
              final percentage = (entry.value / totalDespesas * 100);
              final isFirst = index == 0;
              
              return InkWell(
                onTap: () => _showCategoryDetails(entry.key, entry.value),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Medalha
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isFirst
                                    ? [Colors.amber[400]!, Colors.amber[700]!]
                                    : index == 1
                                        ? [Colors.grey[300]!, Colors.grey[500]!]
                                        : [Colors.orange[200]!, Colors.orange[400]!],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isFirst ? Colors.amber : Colors.grey).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}°',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Ícone da categoria
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(entry.key).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(entry.key),
                              size: 20,
                              color: _getCategoryColor(entry.key),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Nome e porcentagem
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${percentage.toStringAsFixed(1)}% do total',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Valor
                          Text(
                            _formatCurrency(entry.value),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _getCategoryColor(entry.key),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Ícone de clique
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Barra de progresso
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCategoryColor(entry.key),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            // Total
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Despesas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  _formatCurrency(totalDespesas),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPersonalizedTips() {
    // Gerar dicas baseadas nos dados reais
    final List<Map<String, dynamic>> tips = [];
    
    // Análise de despesas
    if (expensesByCategory.isNotEmpty) {
      final sortedExpenses = expensesByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final topCategory = sortedExpenses.first;
      final totalDespesas = stats['total_saidas'] ?? 0.0;
      final receitas = stats['total_entradas'] ?? 0.0;
      
      if (receitas > 0) {
        final percentage = (topCategory.value / receitas * 100);
        if (percentage > 30) {
          tips.add({
            'emoji': '⚠️',
            'text': '${topCategory.key} está consumindo ${percentage.toStringAsFixed(0)}% da sua renda. Considere reduzir esses gastos.',
            'color': Colors.orange,
          });
        }
      }
      
      // Dica sobre saldo
      final saldo = stats['saldo_mes'] ?? 0.0;
      if (saldo > 0) {
        tips.add({
          'emoji': '🎯',
          'text': 'Parabéns! Você economizou ${_formatCurrency(saldo)} este mês. Continue assim!',
          'color': Colors.green,
        });
      } else if (saldo < 0) {
        tips.add({
          'emoji': '💡',
          'text': 'Suas despesas superaram as receitas em ${_formatCurrency(saldo.abs())}. Revise seu orçamento.',
          'color': Colors.red,
        });
      }
      
      // Dica sobre alimentação
      if (expensesByCategory.containsKey('Alimentação')) {
        final alimentacao = expensesByCategory['Alimentação']!;
        if (alimentacao > 800) {
          tips.add({
            'emoji': '🍳',
            'text': 'Seus gastos com alimentação estão elevados (${_formatCurrency(alimentacao)}). Que tal cozinhar mais em casa?',
            'color': Colors.blue,
          });
        }
      }
      
      // Dica sobre transporte
      if (expensesByCategory.containsKey('Transporte')) {
        final transporte = expensesByCategory['Transporte']!;
        if (transporte > 700) {
          tips.add({
            'emoji': '🚗',
            'text': 'Transporte custou ${_formatCurrency(transporte)}. Avalie caronas, transporte público ou home office.',
            'color': Colors.purple,
          });
        }
      }
    }
    
    // Dicas padrão se não houver dados
    if (tips.isEmpty) {
      tips.addAll([
        {
          'emoji': '📊',
          'text': 'Registre mais transações para receber dicas personalizadas baseadas nos seus hábitos.',
          'color': Colors.blue,
        },
        {
          'emoji': '🎯',
          'text': 'Defina metas financeiras para acompanhar seu progresso e manter-se motivado.',
          'color': Colors.green,
        },
        {
          'emoji': '💰',
          'text': 'Estabeleça limites de gastos por categoria para ter maior controle financeiro.',
          'color': Colors.amber,
        },
      ]);
    }
    
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[50]!, Colors.purple[50]!],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.psychology, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insights Personalizados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Baseado nos seus dados',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'IA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              ...List.generate(tips.length, (index) {
                final tip = tips[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: index < tips.length - 1 ? 16 : 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (tip['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            tip['emoji'],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip['text'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ============== NOVOS MÉTODOS: FILTROS E FUNCIONALIDADES PREMIUM ==============
  
  // Método para mostrar detalhes de uma categoria (clicável)
  Future<void> _showCategoryDetails(String category, double amount) async {
    setState(() => _isLoading = true);
    
    try {
      // Calcular início e fim do mês
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      
      final transactions = await _transactionService.getTransactionsByPeriod(
        startDate: startDate,
        endDate: endDate,
      );
      
      final categoryTransactions = transactions
          .where((t) => t['categoria'] == category && t['tipo'] == 'saida')
          .toList();
      
      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: _getCategoryColor(category),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${categoryTransactions.length} transações',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatCurrency(amount),
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Lista de transações
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: categoryTransactions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final transaction = categoryTransactions[index];
                      final date = DateTime.parse(transaction['data']);
                      final value = (transaction['valor'] as num).toDouble();
                      
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(category).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getCategoryIcon(category),
                                size: 20,
                                color: _getCategoryColor(category),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction['descricao'] ?? 'Sem descrição',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy', 'pt_BR').format(date),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatCurrency(value),
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar detalhes: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  // Método para mostrar filtros avançados
  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.filter_alt, size: 24),
            SizedBox(width: 8),
            Text('Filtros Avançados'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtro de categoria
              const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Todas as categorias',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ...expensesByCategory.keys.map((cat) => 
                    DropdownMenuItem(value: cat, child: Text(cat))
                  ),
                ],
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 16),
              
              // Filtro de período
              const Text('Período', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _startDateFilter != null 
                          ? DateFormat('dd/MM/yyyy').format(_startDateFilter!)
                          : 'Data inicial'
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          locale: const Locale('pt', 'BR'),
                        );
                        if (date != null) {
                          setState(() => _startDateFilter = date);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _endDateFilter != null 
                          ? DateFormat('dd/MM/yyyy').format(_endDateFilter!)
                          : 'Data final'
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          locale: const Locale('pt', 'BR'),
                        );
                        if (date != null) {
                          setState(() => _endDateFilter = date);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Filtro de valor
              const Text('Faixa de Valor', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Valor mínimo',
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _minValueFilter = double.tryParse(value.replaceAll(',', '.'));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Valor máximo',
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _maxValueFilter = double.tryParse(value.replaceAll(',', '.'));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Filtro de descrição
              const Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Buscar por descrição...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => _descriptionFilter = value.isEmpty ? null : value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _startDateFilter = null;
                _endDateFilter = null;
                _minValueFilter = null;
                _maxValueFilter = null;
                _descriptionFilter = null;
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Limpar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
  
  // Método para aplicar filtros
  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);
    
    try {
      // Calcular início e fim do mês
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      
      // Buscar transações com filtros
      final allTransactions = await _transactionService.getTransactionsByPeriod(
        startDate: startDate,
        endDate: endDate,
      );
      
      var filtered = allTransactions.where((t) {
        // Filtro de categoria
        if (_selectedCategory != null && t['categoria'] != _selectedCategory) {
          return false;
        }
        
        // Filtro de período
        final date = DateTime.parse(t['data']);
        if (_startDateFilter != null && date.isBefore(_startDateFilter!)) {
          return false;
        }
        if (_endDateFilter != null && date.isAfter(_endDateFilter!.add(const Duration(days: 1)))) {
          return false;
        }
        
        // Filtro de valor
        final value = (t['valor'] as num).toDouble();
        if (_minValueFilter != null && value < _minValueFilter!) {
          return false;
        }
        if (_maxValueFilter != null && value > _maxValueFilter!) {
          return false;
        }
        
        // Filtro de descrição
        if (_descriptionFilter != null && !(t['descricao'] ?? '').toLowerCase().contains(_descriptionFilter!.toLowerCase())) {
          return false;
        }
        
        return true;
      }).toList();
      
      // Recalcular estatísticas com base nos filtros
      double totalEntradas = 0;
      double totalSaidas = 0;
      
      for (var t in filtered) {
        final value = (t['valor'] as num).toDouble();
        if (t['tipo'] == 'entrada') {
          totalEntradas += value;
        } else {
          totalSaidas += value;
        }
      }
      
      setState(() {
        stats = {
          'total_entradas': totalEntradas,
          'total_saidas': totalSaidas,
          'saldo_mes': totalEntradas - totalSaidas,
          'transacoes_count': filtered.length,
        };
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${filtered.length} transações encontradas'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao aplicar filtros: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Método para exportar para PDF
  Future<void> _exportToPDF() async {
    try {
      final pdf = pw.Document();
      
      // Calcular início e fim do mês
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      
      // Buscar todas as transações do mês
      final transactions = await _transactionService.getTransactionsByPeriod(
        startDate: startDate,
        endDate: endDate,
      );
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Cabeçalho
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Relatório Financeiro',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDate),
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Gerado em ${DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Resumo
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Resumo do Mês',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total de Receitas:'),
                        pw.Text(
                          _formatCurrency(stats['total_entradas']),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total de Despesas:'),
                        pw.Text(
                          _formatCurrency(stats['total_saidas']),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red700,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Saldo do Mês:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          _formatCurrency(stats['saldo_mes']),
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: stats['saldo_mes'] >= 0 
                              ? PdfColors.green700 
                              : PdfColors.red700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Despesas por categoria
              if (expensesByCategory.isNotEmpty) ...[
                pw.Text(
                  'Despesas por Categoria',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Table.fromTextArray(
                  headers: ['Categoria', 'Valor'],
                  data: expensesByCategory.entries.map((entry) => [
                    entry.key,
                    _formatCurrency(entry.value),
                  ]).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellAlignments: {
                    1: pw.Alignment.centerRight,
                  },
                ),
                pw.SizedBox(height: 20),
              ],
              
              // Lista de transações
              pw.Text(
                'Transações (${transactions.length})',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                headers: ['Data', 'Categoria', 'Descrição', 'Valor'],
                data: transactions.map((t) {
                  final date = DateTime.parse(t['data']);
                  final value = (t['valor'] as num).toDouble();
                  final tipo = t['tipo'];
                  
                  return [
                    DateFormat('dd/MM/yyyy').format(date),
                    t['categoria'],
                    t['descricao'] ?? '-',
                    (tipo == 'entrada' ? '+ ' : '- ') + _formatCurrency(value),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  3: pw.Alignment.centerRight,
                },
                cellStyle: const pw.TextStyle(fontSize: 10),
              ),
            ];
          },
        ),
      );
      
      // Salvar e compartilhar PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'relatorio_${DateFormat('yyyy_MM').format(_selectedDate)}.pdf',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF gerado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e')),
        );
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    final iconMap = {
      'Alimentação': Icons.restaurant,
      'Transporte': Icons.directions_car,
      'Moradia': Icons.home,
      'Saúde': Icons.health_and_safety,
      'Educação': Icons.school,
      'Lazer': Icons.sports_esports,
      'Compras': Icons.shopping_bag,
      'Contas': Icons.receipt,
      'Outros': Icons.more_horiz,
    };
    return iconMap[category] ?? Icons.category;
  }

  Color _getCategoryColor(String category) {
    final colorMap = {
      'Alimentação': Colors.orange,
      'Transporte': Colors.blue,
      'Moradia': Colors.brown,
      'Saúde': Colors.red,
      'Educação': Colors.purple,
      'Lazer': Colors.pink,
      'Compras': Colors.teal,
      'Contas': Colors.indigo,
      'Outros': Colors.grey,
    };
    return colorMap[category] ?? Colors.grey;
  }
  
  // ==================== NOVOS WIDGETS ====================
  
  Widget _buildSmartInsights() {
    final totalReceitas = (stats['total_entradas'] as num?)?.toDouble() ?? 0.0;
    final totalDespesas = (stats['total_saidas'] as num?)?.toDouble() ?? 0.0;
    final saldo = totalReceitas - totalDespesas;
    final taxaPoupanca = totalReceitas > 0 ? (saldo / totalReceitas * 100) : 0.0;
    
    // Calcular categoria mais cara
    String categoriaMaisCara = 'Nenhuma';
    double valorMaisCara = 0.0;
    if (expensesByCategory.isNotEmpty) {
      final entrada = expensesByCategory.entries.reduce((a, b) => a.value > b.value ? a : b);
      categoriaMaisCara = entrada.key;
      valorMaisCara = entrada.value;
    }
    
    // Calcular média diária
    final diasNoMes = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final mediaDiaria = totalDespesas / diasNoMes;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Text(
                  'Insights Inteligentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Análises automáticas dos seus hábitos financeiros',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid de insights - 4 colunas como Métricas Avançadas
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    icon: Icons.savings,
                    color: taxaPoupanca > 20 ? Colors.green : Colors.orange,
                    title: 'Taxa de Poupança',
                    value: '${taxaPoupanca.toStringAsFixed(1)}%',
                    subtitle: taxaPoupanca > 20 ? 'Excelente!' : 'Pode melhorar',
                    tooltip: 'Percentual do saldo em relação às receitas. Ideal: acima de 20%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightCard(
                    icon: Icons.calendar_today,
                    color: Colors.blue,
                    title: 'Gasto Médio/Dia',
                    value: _formatCurrency(mediaDiaria),
                    subtitle: '$diasNoMes dias',
                    tooltip: 'Valor médio gasto por dia neste mês. Use para controlar gastos diários',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightCard(
                    icon: Icons.warning_amber,
                    color: Colors.red,
                    title: 'Maior Gasto',
                    value: categoriaMaisCara,
                    subtitle: _formatCurrency(valorMaisCara),
                    tooltip: 'Categoria que mais consumiu seu orçamento. Atenção especial aqui!',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightCard(
                    icon: saldo > 0 ? Icons.trending_up : Icons.trending_down,
                    color: saldo > 0 ? Colors.green : Colors.red,
                    title: 'Status',
                    value: saldo > 0 ? 'Superávit' : 'Déficit',
                    subtitle: _formatCurrency(saldo.abs()),
                    tooltip: saldo > 0 
                        ? 'Superávit: suas receitas superaram as despesas' 
                        : 'Déficit: você gastou mais do que ganhou',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Análises textuais
            _buildTextInsight(
              icon: Icons.lightbulb,
              color: Colors.amber,
              text: taxaPoupanca > 20
                  ? '🎉 Parabéns! Você está poupando ${taxaPoupanca.toStringAsFixed(0)}% das suas receitas.'
                  : '💡 Tente reduzir gastos em $categoriaMaisCara para poupar mais.',
            ),
            const SizedBox(height: 8),
            _buildTextInsight(
              icon: Icons.star,
              color: Colors.purple,
              text: totalDespesas < 5000
                  ? '⭐ Seus gastos estão controlados este mês!'
                  : '⚠️ Seus gastos estão acima da média. Revise $categoriaMaisCara.',
            ),
            const SizedBox(height: 8),
            _buildTextInsight(
              icon: Icons.timeline,
              color: Colors.indigo,
              text: 'Projeção: Se manter este ritmo, terá ${_formatCurrency(saldo)} no final do mês.',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInsightCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 4),
                Icon(Icons.info_outline, color: Colors.grey[400], size: 14),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextInsight({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // NOVO: Gráfico de Pizza das Categorias
  Widget _buildCategoryPieChart() {
    // Criar dados para despesas E receitas
    final List<Map<String, dynamic>> expensesData = [];
    final List<Map<String, dynamic>> incomesData = [];
    
    // Pegar top 5 de despesas
    if (expensesByCategory.isNotEmpty) {
      final sortedExpenses = expensesByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final topExpenses = sortedExpenses.take(5).toList();
      for (var entry in topExpenses) {
        expensesData.add({
          'category': entry.key,
          'value': entry.value,
          'color': _getCategoryColor(entry.key),
        });
      }
    }
    
    // Pegar top 5 de receitas
    if (incomeByCategory.isNotEmpty) {
      final sortedIncomes = incomeByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final topIncomes = sortedIncomes.take(5).toList();
      for (var entry in topIncomes) {
        incomesData.add({
          'category': entry.key,
          'value': entry.value,
          'color': _getCategoryColor(entry.key),
        });
      }
    }
    
    final totalDespesas = expensesByCategory.values.fold(0.0, (a, b) => a + b);
    final totalReceitas = incomeByCategory.values.fold(0.0, (a, b) => a + b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart_rounded, color: Colors.indigo[700]),
                const SizedBox(width: 8),
                const Text(
                  'Distribuição por Categorias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Top 5 categorias de despesas e receitas',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            
            // Tabs: Despesas e Receitas
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.red,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.red,
                    tabs: const [
                      Tab(text: '💸 Despesas'),
                      Tab(text: '💰 Receitas'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 350,
                    child: TabBarView(
                      children: [
                        // Tab de Despesas
                        _buildPieChartTab(
                          data: expensesData,
                          total: totalDespesas,
                          emptyMessage: 'Nenhuma despesa registrada neste mês',
                        ),
                        // Tab de Receitas
                        _buildPieChartTab(
                          data: incomesData,
                          total: totalReceitas,
                          emptyMessage: 'Nenhuma receita registrada neste mês',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPieChartTab({
    required List<Map<String, dynamic>> data,
    required double total,
    required String emptyMessage,
  }) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // Gráfico de Pizza (visual simplificado)
        SizedBox(
          height: 200,
          child: CustomPaint(
            size: const Size(200, 200),
            painter: PieChartPainter(data: data, total: total),
          ),
        ),
        const SizedBox(height: 20),
        
        // Legenda
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final percentage = (item['value'] / total * 100);
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: item['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['category'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCurrency(item['value']),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: item['color'],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAdvancedMetrics() {
    final totalReceitas = (stats['total_entradas'] as num?)?.toDouble() ?? 0.0;
    final totalDespesas = (stats['total_saidas'] as num?)?.toDouble() ?? 0.0;
    final saldo = totalReceitas - totalDespesas;
    
    // Calcular distribuição de gastos
    final totalCategorias = expensesByCategory.length;
    final ticketMedio = totalCategorias > 0 ? totalDespesas / totalCategorias : 0.0;
    
    // ROI simulado (apenas exemplo)
    final roi = totalReceitas > 0 ? ((saldo / totalReceitas) * 100) : 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.teal[700]),
                const SizedBox(width: 8),
                const Text(
                  'Métricas Avançadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Indicadores profissionais para análise detalhada',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            
            // Métricas em linha - 4 cards como Insights Inteligentes
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.pie_chart,
                    title: 'Categorias Ativas',
                    value: totalCategorias.toString(),
                    color: Colors.blue,
                    tooltip: 'Número de categorias onde você teve gastos este mês',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.receipt_long,
                    title: 'Ticket Médio',
                    value: _formatCurrency(ticketMedio),
                    color: Colors.orange,
                    tooltip: 'Valor médio gasto por categoria ativa',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.show_chart,
                    title: 'ROI Mensal',
                    value: '${roi.toStringAsFixed(1)}%',
                    color: roi > 0 ? Colors.green : Colors.red,
                    tooltip: 'Retorno sobre Investimento: eficiência na gestão financeira',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.wallet,
                    title: 'Saldo Líquido',
                    value: _formatCurrency(saldo.abs()),
                    color: saldo > 0 ? Colors.green : Colors.red,
                    tooltip: 'Diferença entre receitas e despesas',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Explicações em texto
            _buildMetricExplanation(
              icon: Icons.lightbulb_outline,
              color: Colors.amber,
              text: roi > 0
                  ? '💰 ROI de ${roi.toStringAsFixed(1)}%: Para cada R\$ 100 que você ganhou, conseguiu poupar R\$ ${(roi).toStringAsFixed(2)}. Excelente gestão!'
                  : '⚠️ ROI de ${roi.toStringAsFixed(1)}%: Você está gastando mais do que ganha. Revise suas despesas para melhorar a eficiência.',
            ),
            const SizedBox(height: 8),
            _buildMetricExplanation(
              icon: Icons.trending_up,
              color: Colors.purple,
              text: totalCategorias > 0
                  ? '📊 Você tem gastos distribuídos em $totalCategorias categorias, com ticket médio de ${_formatCurrency(ticketMedio)}.'
                  : '📊 Nenhuma categoria com gastos registrada neste mês.',
            ),
            const SizedBox(height: 8),
            _buildMetricExplanation(
              icon: Icons.account_balance_wallet,
              color: saldo > 0 ? Colors.green : Colors.red,
              text: saldo > 0
                  ? '✅ Saldo positivo de ${_formatCurrency(saldo)}! Continue assim e suas economias crescerão.'
                  : '⚠️ Saldo negativo de ${_formatCurrency(saldo.abs())}. Ajuste seus gastos no próximo mês.',
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Barra de progresso - Gastos vs Receitas
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Utilização do Orçamento',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${(totalDespesas / totalReceitas * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: totalDespesas / totalReceitas < 0.8 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalReceitas > 0 ? (totalDespesas / totalReceitas).clamp(0.0, 1.0) : 0.0,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      totalDespesas / totalReceitas < 0.8 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalDespesas / totalReceitas < 0.8
                      ? '✅ Orçamento sob controle'
                      : '⚠️ Atenção aos gastos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricExplanation({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 4),
                Icon(Icons.help_outline, color: Colors.grey[400], size: 14),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============== CUSTOM PAINTER PARA GRÁFICO DE PIZZA ==============

class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;

  PieChartPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    double startAngle = -pi / 2; // Começar no topo
    
    for (var item in data) {
      final value = item['value'] as double;
      final percentage = value / total;
      final sweepAngle = 2 * pi * percentage;
      
      final paint = Paint()
        ..color = item['color']
        ..style = PaintingStyle.fill;
      
      // Desenhar fatia
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      // Desenhar borda branca entre as fatias
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );
      
      startAngle += sweepAngle;
    }
    
    // Desenhar círculo branco no centro para efeito "donut"
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
