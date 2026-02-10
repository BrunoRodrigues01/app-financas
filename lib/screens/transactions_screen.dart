import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _transactionService = TransactionService();
  
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filtros
  DateTime _selectedDate = DateTime.now();
  String _filterType = 'todos'; // 'todos', 'entrada', 'saida'
  String _paymentFilter = 'todos'; // 'todos', 'pagas', 'pendentes', 'atrasadas'
  
  // Estatísticas do período
  double _totalEntradas = 0.0;
  double _totalSaidas = 0.0;
  double _saldoPeriodo = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
  
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Buscar transações do mês selecionado
      final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      
      final transactions = await _transactionService.getTransactionsByPeriod(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
      
      // Calcular estatísticas
      double entradas = 0.0;
      double saidas = 0.0;
      
      for (var transaction in transactions) {
        final valor = (transaction['valor'] as num).toDouble();
        if (transaction['tipo'] == 'entrada') {
          entradas += valor;
        } else {
          saidas += valor;
        }
      }
      
      setState(() {
        _transactions = transactions;
        _totalEntradas = entradas;
        _totalSaidas = saidas;
        _saldoPeriodo = entradas - saidas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar transações: $e';
        _isLoading = false;
      });
    }
  }
  
  List<Map<String, dynamic>> get _filteredTransactions {
    var filtered = _transactions;
    
    // Filtro por tipo (entrada/saída)
    if (_filterType != 'todos') {
      filtered = filtered.where((t) => t['tipo'] == _filterType).toList();
    }
    
    // Filtro por status de pagamento (apenas para despesas)
    if (_paymentFilter != 'todos') {
      filtered = filtered.where((t) {
        if (t['tipo'] != 'saida') return false; // Apenas despesas
        
        final pago = t['pago'] as bool? ?? false;
        final dataVencimento = t['data_vencimento'] != null 
            ? DateTime.parse(t['data_vencimento']) 
            : null;
        
        switch (_paymentFilter) {
          case 'pagas':
            return pago;
          case 'pendentes':
            if (pago) return false;
            if (dataVencimento == null) return true;
            return !dataVencimento.isBefore(DateTime.now());
          case 'atrasadas':
            if (pago) return false;
            if (dataVencimento == null) return false;
            return dataVencimento.isBefore(DateTime.now());
          default:
            return true;
        }
      }).toList();
    }
    
    return filtered;
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Transações'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Cabeçalho com filtros e estatísticas
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Seletor de mês/ano
                _buildMonthYearSelector(),
                const SizedBox(height: 16),
                
                // Estatísticas do período
                _buildPeriodStats(),
                const SizedBox(height: 16),
                
                // Filtros de tipo
                _buildTypeFilter(),
                const SizedBox(height: 8),
                
                // Filtros de pagamento (apenas para despesas)
                if (_filterType == 'saida' || _filterType == 'todos')
                  _buildPaymentFilter(),
                const SizedBox(height: 8),
              ],
            ),
          ),
          
          // Lista de transações
          Expanded(
            child: _buildTransactionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          _loadTransactions();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildMonthYearSelector() {
    final monthName = DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDate);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              _loadTransactions();
            },
          ),
          InkWell(
            onTap: _showMonthYearPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    monthName.substring(0, 1).toUpperCase() + monthName.substring(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
              _loadTransactions();
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
      _loadTransactions();
    }
  }
  
  Widget _buildPeriodStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Entradas',
              _totalEntradas,
              Colors.green,
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Saídas',
              _totalSaidas,
              Colors.red,
              Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Saldo',
              _saldoPeriodo,
              _saldoPeriodo >= 0 ? Colors.blue : Colors.orange,
              Icons.account_balance_wallet,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypeFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip('Todas', 'todos'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip('Receitas', 'entrada'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip('Despesas', 'saida'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildPaymentFilterChip('Todas', 'todos', Icons.list),
            const SizedBox(width: 8),
            _buildPaymentFilterChip('Pagas', 'pagas', Icons.check_circle),
            const SizedBox(width: 8),
            _buildPaymentFilterChip('Pendentes', 'pendentes', Icons.schedule),
            const SizedBox(width: 8),
            _buildPaymentFilterChip('Atrasadas', 'atrasadas', Icons.warning),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentFilterChip(String label, String type, IconData icon) {
    final isSelected = _paymentFilter == type;
    Color chipColor = Colors.white;
    Color iconColor = Theme.of(context).colorScheme.primary;
    
    if (isSelected) {
      switch (type) {
        case 'pagas':
          chipColor = Colors.green.shade50;
          iconColor = Colors.green;
          break;
        case 'pendentes':
          chipColor = Colors.orange.shade50;
          iconColor = Colors.orange;
          break;
        case 'atrasadas':
          chipColor = Colors.red.shade50;
          iconColor = Colors.red;
          break;
        default:
          chipColor = Colors.white;
      }
    }
    
    return InkWell(
      onTap: () {
        setState(() {
          _paymentFilter = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: iconColor.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? iconColor : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? iconColor : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String type) {
    final isSelected = _filterType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _filterType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
  
  Widget _buildTransactionsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransactions,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }
    
    final filtered = _filteredTransactions;
    
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma transação encontrada',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _filterType == 'todos' 
                ? 'Adicione sua primeira transação'
                : 'Nenhuma ${_filterType == 'entrada' ? 'receita' : 'despesa'} neste período',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    
    // Agrupar por data
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var transaction in filtered) {
      final data = DateTime.parse(transaction['data'] as String);
      final key = DateFormat('dd/MM/yyyy', 'pt_BR').format(data);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(transaction);
    }
    
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('dd/MM/yyyy', 'pt_BR').parse(a);
        final dateB = DateFormat('dd/MM/yyyy', 'pt_BR').parse(b);
        return dateB.compareTo(dateA);
      });
    
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final dateKey = sortedKeys[index];
          final transactions = grouped[dateKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da data
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  dateKey,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              
              // Lista de transações do dia
              ...transactions.map((transaction) => _buildTransactionCard(transaction)),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final tipo = transaction['tipo'] as String;
    final categoria = transaction['categoria'] as String;
    final valor = (transaction['valor'] as num).toDouble();
    final descricao = transaction['descricao'] as String?;
    final data = DateTime.parse(transaction['data'] as String);
    final id = transaction['id'] as String;
    
    // Dados de pagamento
    final pago = transaction['pago'] as bool? ?? false;
    final dataVencimento = transaction['data_vencimento'] != null 
        ? DateTime.parse(transaction['data_vencimento']) 
        : null;
    final dataPagamento = transaction['data_pagamento'] != null 
        ? DateTime.parse(transaction['data_pagamento']) 
        : null;
    
    final isEntrada = tipo == 'entrada';
    final cor = isEntrada ? Colors.green : Colors.red;
    final icone = _getCategoryIcon(categoria);
    
    // Status de pagamento (apenas para despesas)
    String? paymentStatus;
    Color? statusColor;
    IconData? statusIcon;
    
    if (!isEntrada) {
      if (pago) {
        paymentStatus = 'Paga';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      } else if (dataVencimento != null && dataVencimento.isBefore(DateTime.now())) {
        paymentStatus = 'Atrasada';
        statusColor = Colors.red;
        statusIcon = Icons.warning;
      } else if (dataVencimento != null) {
        final diasRestantes = dataVencimento.difference(DateTime.now()).inDays;
        if (diasRestantes == 0) {
          paymentStatus = 'Vence hoje';
          statusColor = Colors.orange;
          statusIcon = Icons.today;
        } else if (diasRestantes <= 3) {
          paymentStatus = 'Vence em $diasRestantes dia${diasRestantes > 1 ? 's' : ''}';
          statusColor = Colors.orange;
          statusIcon = Icons.schedule;
        } else {
          paymentStatus = 'Pendente';
          statusColor = Colors.blue;
          statusIcon = Icons.schedule;
        }
      }
    }
    
    return Dismissible(
      key: Key(id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: const Text('Deseja realmente excluir esta transação?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await _transactionService.deleteTransaction(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação excluída com sucesso!')),
        );
        _loadTransactions();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 24),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      categoria,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  // Badge de status de pagamento
                  if (paymentStatus != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            paymentStatus,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (descricao != null && descricao.isNotEmpty) ...[
                    Text(
                      descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Row(
                    children: [
                      Text(
                        DateFormat('HH:mm', 'pt_BR').format(data),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      if (dataVencimento != null) ...[
                        Text(' • ', style: TextStyle(color: Colors.grey[500])),
                        Icon(Icons.event, size: 11, color: Colors.grey[500]),
                        const SizedBox(width: 2),
                        Text(
                          'Vence: ${DateFormat('dd/MM', 'pt_BR').format(dataVencimento)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isEntrada ? '+' : '-'} ${_formatCurrency(valor)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: cor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Botão de ação rápida (para transações não pagas/recebidas)
            if (!pago) ...[
              const Divider(height: 1),
              InkWell(
                onTap: () => _markAsPaid(id, isEntrada),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        isEntrada ? 'Marcar como recebida' : 'Marcar como paga',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Future<void> _markAsPaid(String transactionId, bool isIncome) async {
    final result = await _transactionService.markAsPaid(transactionId);
    
    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(isIncome ? 'Receita marcada como recebida!' : 'Despesa marcada como paga!')),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadTransactions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
