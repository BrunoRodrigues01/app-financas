import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import '../services/supabase_service.dart';
import 'add_transaction_screen.dart';
import 'goals_screen.dart';
import 'reports_screen.dart';
import 'categories_screen.dart';
import 'transactions_screen.dart';
import 'budget_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Serviços
  final _transactionService = TransactionService();
  final _supabaseService = SupabaseService.instance;
  
  // Dados reais do Supabase
  double saldoAtual = 0.0;
  double receitasMes = 0.0;
  double despesasMes = 0.0;
  double saldoMesAnterior = 0.0;
  double variacaoPercentual = 0.0;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Data selecionada (padrão: mês e ano atual)
  DateTime _selectedDate = DateTime.now();
  
  // Lista das últimas transações
  List<Map<String, dynamic>> _recentTransactions = [];
  
  // Flag para alternar entre saldo do mês e saldo acumulado
  bool _showAccumulatedBalance = false;
  double saldoAcumulado = 0.0;
  
  // Dados de contas a pagar
  Map<String, dynamic>? _paymentStats;
  int _overdueCount = 0;
  int _upcomingCount = 0;
  
  // Alertas de vencimento
  List<Map<String, dynamic>> _upcomingTransactions = [];
  List<Map<String, dynamic>> _overdueTransactions = [];
  
  // Função para formatar valores em moeda brasileira
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 1. Buscar saldo atual do usuário (saldo total acumulado)
      final userId = _supabaseService.currentUserId;
      
      if (userId == null) {
        setState(() {
          _errorMessage = 'Usuário não autenticado';
          _isLoading = false;
        });
        return;
      }
      
      // 2. Buscar estatísticas do mês selecionado
      final stats = await _transactionService.getMonthlyStats(
        month: _selectedDate.month,
        year: _selectedDate.year,
      );
      
      // 3. Buscar estatísticas do mês anterior para calcular variação
      final mesAnterior = DateTime(_selectedDate.year, _selectedDate.month - 1);
      final statsAnterior = await _transactionService.getMonthlyStats(
        month: mesAnterior.month,
        year: mesAnterior.year,
      );
      
      // 4. Calcular valores
      final receitasMesAtual = (stats['total_entradas'] as num?)?.toDouble() ?? 0.0;
      final despesasMesAtual = (stats['total_saidas'] as num?)?.toDouble() ?? 0.0;
      final saldoMesAtual = receitasMesAtual - despesasMesAtual;
      
      final receitasMesAnt = (statsAnterior['total_entradas'] as num?)?.toDouble() ?? 0.0;
      final despesasMesAnt = (statsAnterior['total_saidas'] as num?)?.toDouble() ?? 0.0;
      final saldoMesAnt = receitasMesAnt - despesasMesAnt;
      
      // 5. Calcular variação percentual
      double variacao = 0.0;
      if (saldoMesAnt != 0) {
        variacao = ((saldoMesAtual - saldoMesAnt) / saldoMesAnt.abs()) * 100;
      }
      
      // 6. Buscar saldo acumulado total do banco de dados
      final userDataResponse = await _supabaseService.client
          .from('usuarios')
          .select('saldo_atual')
          .eq('id', userId)
          .single();
      final saldoTotal = (userDataResponse['saldo_atual'] as num?)?.toDouble() ?? 0.0;
      
      // 7. Buscar as últimas 10 transações (todas, independente do mês)
      final recentTransactions = await _transactionService.getTransactions(limit: 10);
      
      // 8. Buscar estatísticas de pagamento
      final paymentStatsResult = await _transactionService.getPaymentStatistics(
        month: _selectedDate.month,
        year: _selectedDate.year,
      );
      
      // 9. Buscar contas atrasadas e próximas (despesas e receitas)
      final overdueExpenses = await _transactionService.getOverdueExpenses();
      final upcomingExpenses = await _transactionService.getUpcomingDueExpenses(days: 7);
      
      // 10. Buscar TODAS as transações (receitas + despesas) com vencimento próximo
      final allUpcoming = await _transactionService.getTransactions();
      final today = DateTime.now();
      final futureDate = today.add(const Duration(days: 7));
      
      final upcomingFiltered = allUpcoming.where((t) {
        final pago = t['pago'] as bool? ?? false;
        if (pago) return false; // Ignora já pagas/recebidas
        
        if (t['data_vencimento'] == null) return false;
        final vencimento = DateTime.parse(t['data_vencimento']);
        
        return vencimento.isAfter(today) && vencimento.isBefore(futureDate);
      }).toList();
      
      final overdueFiltered = allUpcoming.where((t) {
        final pago = t['pago'] as bool? ?? false;
        if (pago) return false;
        
        if (t['data_vencimento'] == null) return false;
        final vencimento = DateTime.parse(t['data_vencimento']);
        
        return vencimento.isBefore(today);
      }).toList();
      
      setState(() {
        saldoAtual = saldoMesAtual; // Saldo do mês selecionado (não acumulado)
        saldoAcumulado = saldoTotal; // Saldo total acumulado
        receitasMes = receitasMesAtual;
        despesasMes = despesasMesAtual;
        saldoMesAnterior = saldoMesAnt;
        variacaoPercentual = variacao;
        _recentTransactions = recentTransactions;
        _paymentStats = paymentStatsResult['success'] == true ? paymentStatsResult['data'] : null;
        _overdueCount = overdueExpenses.length;
        _upcomingCount = upcomingExpenses.length;
        _upcomingTransactions = upcomingFiltered;
        _overdueTransactions = overdueFiltered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Exibir loading
    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando dados...'),
            ],
          ),
        ),
      );
    }
    
    // Exibir erro
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(_errorMessage!),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  _buildHeader(context),
                  const SizedBox(height: 30),
                  
                  // Card de Saldo Atual
                  _buildBalanceCard(context),
                  const SizedBox(height: 25),
                  
                  // Resumo de Receitas e Despesas
                  _buildIncomeExpenseSummary(context),
                  const SizedBox(height: 25),
                  
                  // Card de Contas a Pagar
                  _buildPaymentSummaryCard(context),
                  const SizedBox(height: 25),
                  
                  // Card de Alertas de Vencimento
                  _buildUpcomingAlertsCard(context),
                  const SizedBox(height: 30),
                  
                  // Ações Rápidas
                  _buildQuickActions(context),
                  const SizedBox(height: 30),
                  
                  // Lista de Últimas Transações
                  _buildRecentTransactions(context),
                  const SizedBox(height: 80), // Espaço extra para o FAB
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          // Recarregar dados após voltar (sempre)
          if (mounted) {
            await _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Transação'),
        backgroundColor: colorScheme.primary,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minhas Finanças',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bem-vindo de volta! 👋',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(25),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Seletor de Mês/Ano
        _buildMonthYearSelector(context),
      ],
    );
  }

  Widget _buildMonthYearSelector(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDate);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              onTap: () => _showMonthYearPicker(context),
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

  Future<void> _showMonthYearPicker(BuildContext context) async {
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

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white.withOpacity(0.9),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showAccumulatedBalance ? 'Saldo Acumulado' : 'Saldo do Mês',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              // Botão para alternar entre saldo do mês e acumulado
              InkWell(
                onTap: () {
                  setState(() {
                    _showAccumulatedBalance = !_showAccumulatedBalance;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _showAccumulatedBalance ? Icons.calendar_month : Icons.all_inclusive,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatCurrency(_showAccumulatedBalance ? saldoAcumulado : saldoAtual),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _showAccumulatedBalance 
                  ? Icons.savings
                  : (variacaoPercentual >= 0 ? Icons.trending_up : Icons.trending_down),
                color: _showAccumulatedBalance 
                  ? Colors.amberAccent
                  : (variacaoPercentual >= 0 ? Colors.greenAccent : Colors.redAccent),
                size: 18,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _showAccumulatedBalance
                    ? 'Total de todas as suas transações'
                    : (variacaoPercentual == 0 
                      ? 'Saldo do mês atual'
                      : '${variacaoPercentual >= 0 ? '+' : ''}${variacaoPercentual.toStringAsFixed(1)}% em relação ao mês anterior'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseSummary(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Receitas',
            amount: receitasMes,
            icon: Icons.arrow_downward,
            color: Colors.green,
            isIncome: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Despesas',
            amount: despesasMes,
            icon: Icons.arrow_upward,
            color: Colors.red,
            isIncome: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required bool isIncome,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM yyyy', 'pt_BR').format(_selectedDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(BuildContext context) {
    if (_paymentStats == null) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final totalDespesas = (_paymentStats!['total_despesas'] as num?)?.toDouble() ?? 0.0;
    final despesasPagas = (_paymentStats!['despesas_pagas'] as num?)?.toDouble() ?? 0.0;
    final despesasPendentes = (_paymentStats!['despesas_pendentes'] as num?)?.toDouble() ?? 0.0;
    final despesasAtrasadas = (_paymentStats!['despesas_atrasadas'] as num?)?.toDouble() ?? 0.0;
    
    final qtdPagas = _paymentStats!['quantidade_pagas'] as int? ?? 0;
    final qtdPendentes = _paymentStats!['quantidade_pendentes'] as int? ?? 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contas a Pagar',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${DateFormat.MMMM('pt_BR').format(_selectedDate)} ${_selectedDate.year}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Estatísticas em grid 2x2
            Row(
              children: [
                Expanded(
                  child: _buildPaymentStatItem(
                    context,
                    'Total',
                    _formatCurrency(totalDespesas),
                    '$qtdPagas + $qtdPendentes contas',
                    Colors.blue,
                    Icons.receipt_long,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPaymentStatItem(
                    context,
                    'Pagas',
                    _formatCurrency(despesasPagas),
                    '$qtdPagas contas',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentStatItem(
                    context,
                    'Pendentes',
                    _formatCurrency(despesasPendentes),
                    '$qtdPendentes contas',
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPaymentStatItem(
                    context,
                    'Atrasadas',
                    _formatCurrency(despesasAtrasadas),
                    '${_overdueCount} contas',
                    Colors.red,
                    Icons.warning,
                  ),
                ),
              ],
            ),
            
            // Alertas
            if (_overdueCount > 0 || _upcomingCount > 0) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              if (_overdueCount > 0)
                _buildAlert(
                  context,
                  '⚠️ Você tem $_overdueCount conta(s) atrasada(s)!',
                  Colors.red,
                ),
              if (_upcomingCount > 0)
                _buildAlert(
                  context,
                  '📅 $_upcomingCount conta(s) vencem nos próximos 7 dias',
                  Colors.orange,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatItem(
    BuildContext context,
    String label,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlert(BuildContext context, String message, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAlertsCard(BuildContext context) {
    // Se não houver nenhum alerta, não mostrar o card
    if (_overdueTransactions.isEmpty && _upcomingTransactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade50,
              Colors.red.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: Colors.orange.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚠️ Alertas de Vencimento',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                        ),
                        Text(
                          'Fique atento às datas!',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange.shade700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Transações Atrasadas
              if (_overdueTransactions.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '🔴 ATRASADAS (${_overdueTransactions.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._overdueTransactions.take(3).map((transaction) {
                        return _buildAlertItem(
                          context,
                          transaction,
                          Colors.red.shade700,
                          isOverdue: true,
                        );
                      }).toList(),
                      if (_overdueTransactions.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+ ${_overdueTransactions.length - 3} mais atrasada(s)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Transações Próximas do Vencimento
              if (_upcomingTransactions.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '🟠 PRÓXIMAS A VENCER (${_upcomingTransactions.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._upcomingTransactions.take(3).map((transaction) {
                        return _buildAlertItem(
                          context,
                          transaction,
                          Colors.orange.shade700,
                          isOverdue: false,
                        );
                      }).toList(),
                      if (_upcomingTransactions.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+ ${_upcomingTransactions.length - 3} mais próxima(s)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              
              // Botão para ver todas
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.list_alt, size: 18),
                  label: Text('Ver todas as transações'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertItem(
    BuildContext context,
    Map<String, dynamic> transaction,
    Color color, {
    required bool isOverdue,
  }) {
    final tipo = transaction['tipo'] as String;
    final categoria = transaction['categoria'] as String;
    final valor = (transaction['valor'] as num).toDouble();
    final dataVencimento = DateTime.parse(transaction['data_vencimento']);
    final isReceita = tipo == 'entrada';
    
    final diasDiferenca = dataVencimento.difference(DateTime.now()).inDays;
    String statusText;
    
    if (isOverdue) {
      final diasAtrasados = DateTime.now().difference(dataVencimento).inDays;
      statusText = diasAtrasados == 0 
          ? 'Vence hoje!' 
          : 'Atrasado há $diasAtrasados dia${diasAtrasados > 1 ? 's' : ''}';
    } else {
      statusText = diasDiferenca == 0
          ? 'Vence hoje!'
          : 'Vence em $diasDiferenca dia${diasDiferenca > 1 ? 's' : ''}';
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isReceita ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isReceita ? Icons.arrow_downward : Icons.arrow_upward,
              color: isReceita ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoria,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  '${DateFormat('dd/MM/yyyy').format(dataVencimento)} • $statusText',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(valor),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isReceita ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        // Primeira linha com 4 botões
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              context,
              icon: Icons.add_circle_outline,
              label: 'Adicionar',
              color: Colors.blue,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
                if (mounted) {
                  await _loadData();
                }
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.account_balance_wallet,
              label: 'Orçamento',
              color: Colors.green,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BudgetScreen(),
                  ),
                );
                if (mounted) {
                  await _loadData();
                }
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.flag_outlined,
              label: 'Metas',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GoalsScreen(),
                  ),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.bar_chart,
              label: 'Relatórios',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Segunda linha com 3 botões
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              icon: Icons.list_alt,
              label: 'Transações',
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsScreen(),
                  ),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.category_outlined,
              label: 'Categorias',
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.person,
              label: 'Perfil',
              color: Colors.pink,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Column(
      children: [
        _buildNavigationCard(
          context,
          icon: Icons.flag,
          title: 'Metas Financeiras',
          subtitle: 'Defina e acompanhe suas metas',
          color: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GoalsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildNavigationCard(
          context,
          icon: Icons.bar_chart,
          title: 'Relatórios',
          subtitle: 'Visualize gráficos e estatísticas',
          color: Colors.purple,
          onTap: () {
            // TODO: Navegar para tela de relatórios
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navegando para Relatórios...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Últimas Transações',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsScreen(),
                  ),
                );
              },
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma transação encontrada',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adicione sua primeira transação',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _recentTransactions[index];
              final tipo = transaction['tipo'] as String;
              final categoria = transaction['categoria'] as String;
              final valor = (transaction['valor'] as num).toDouble();
              final descricao = transaction['descricao'] as String?;
              final data = DateTime.parse(transaction['data'] as String);
              
              final isEntrada = tipo == 'entrada';
              final cor = isEntrada ? Colors.green : Colors.red;
              final icone = _getCategoryIcon(categoria);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icone,
                      color: cor,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    categoria,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (descricao != null && descricao.isNotEmpty)
                        Text(
                          descricao,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      Text(
                        DateFormat('dd/MM/yyyy • HH:mm', 'pt_BR').format(data),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${isEntrada ? '+' : '-'} ${_formatCurrency(valor)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: cor,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  IconData _getCategoryIcon(String categoria) {
    final icons = {
      // Receitas
      'Salário': Icons.work,
      'Freelance': Icons.laptop,
      'Investimentos': Icons.trending_up,
      'Prêmios': Icons.emoji_events,
      'Vendas': Icons.shopping_bag,
      'Outros Ganhos': Icons.attach_money,
      
      // Despesas
      'Alimentação': Icons.restaurant,
      'Transporte': Icons.directions_car,
      'Moradia': Icons.home,
      'Saúde': Icons.local_hospital,
      'Educação': Icons.school,
      'Lazer': Icons.movie,
      'Compras': Icons.shopping_cart,
      'Contas': Icons.receipt,
      'Outros Gastos': Icons.more_horiz,
    };
    return icons[categoria] ?? Icons.attach_money;
  }
}
