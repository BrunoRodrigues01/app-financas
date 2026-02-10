import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // Lista de metas (simulação - futuramente virá do banco de dados)
  List<FinancialGoal> goals = [
    FinancialGoal(
      id: '1',
      title: 'Viagem para Europa',
      targetAmount: 8000.00,
      currentAmount: 4800.00,
      deadline: DateTime(2026, 8, 15),
      color: Colors.blue,
      icon: Icons.flight,
    ),
    FinancialGoal(
      id: '2',
      title: 'Fundo de Emergência',
      targetAmount: 5000.00,
      currentAmount: 3200.00,
      deadline: DateTime(2026, 12, 31),
      color: Colors.orange,
      icon: Icons.health_and_safety,
    ),
    FinancialGoal(
      id: '3',
      title: 'Novo Notebook',
      targetAmount: 4500.00,
      currentAmount: 1500.00,
      deadline: DateTime(2026, 6, 30),
      color: Colors.purple,
      icon: Icons.laptop,
    ),
  ];

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Metas Financeiras'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: goals.isEmpty ? _buildEmptyState() : _buildGoalsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova Meta'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhuma meta criada',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Crie sua primeira meta financeira\ne comece a economizar!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Resumo de Metas
        _buildGoalsSummary(),
        const SizedBox(height: 24),
        
        // Lista de Metas
        Text(
          'Suas Metas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        
        ...goals.map((goal) => _buildGoalCard(goal)).toList(),
        
        const SizedBox(height: 80), // Espaço para o FAB
      ],
    );
  }

  Widget _buildGoalsSummary() {
    final totalTarget = goals.fold<double>(
      0, 
      (sum, goal) => sum + goal.targetAmount,
    );
    final totalCurrent = goals.fold<double>(
      0, 
      (sum, goal) => sum + goal.currentAmount,
    );
    final overallProgress = totalTarget > 0 ? (totalCurrent / totalTarget * 100) : 0;
    final completedGoals = goals.where((g) => g.isCompleted).length;

    return Container(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progresso Geral',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${overallProgress.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Metas Ativas',
                  '${goals.length}',
                  Icons.track_changes,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Concluídas',
                  '$completedGoals',
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(FinancialGoal goal) {
    final daysRemaining = goal.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysRemaining < 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showGoalDetails(goal),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: goal.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        goal.icon,
                        color: goal.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isOverdue 
                              ? 'Prazo expirado há ${-daysRemaining} dias'
                              : 'Faltam $daysRemaining dias',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isOverdue ? Colors.red : Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (goal.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Concluída',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Barra de Progresso
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: goal.progress / 100,
                    minHeight: 12,
                    backgroundColor: goal.color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Valores
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Economizado',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        Text(
                          _formatCurrency(goal.currentAmount),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: goal.color,
                              ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: goal.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${goal.progress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: goal.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Meta',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        Text(
                          _formatCurrency(goal.targetAmount),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Botões de Ação
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddMoneyDialog(goal),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: goal.color,
                          side: BorderSide(color: goal.color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showEditGoalDialog(goal),
                      icon: const Icon(Icons.edit),
                      color: Colors.grey[600],
                    ),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(goal),
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalDetails(FinancialGoal goal) {
    final remaining = goal.targetAmount - goal.currentAmount;
    final daysRemaining = goal.deadline.difference(DateTime.now()).inDays;
    final dailyTarget = (daysRemaining > 0 ? remaining / daysRemaining : 0).toDouble();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Valor Total', _formatCurrency(goal.targetAmount)),
            _buildDetailRow('Economizado', _formatCurrency(goal.currentAmount)),
            _buildDetailRow('Falta Economizar', _formatCurrency(remaining)),
            _buildDetailRow('Prazo', '${goal.deadline.day}/${goal.deadline.month}/${goal.deadline.year}'),
            if (daysRemaining > 0)
              _buildDetailRow('Economia Diária Necessária', _formatCurrency(dailyTarget)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDate;
    Color selectedColor = Colors.blue;
    IconData selectedIcon = Icons.flag;
    
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nova Meta Financeira'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Meta',
                      hintText: 'Ex: Viagem, Carro novo...',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite um nome para a meta';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Valor da Meta',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite um valor';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Digite um valor válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(selectedDate == null 
                      ? 'Selecionar Data Limite' 
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() && selectedDate != null) {
                  setState(() {
                    goals.add(
                      FinancialGoal(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        targetAmount: double.parse(amountController.text),
                        currentAmount: 0,
                        deadline: selectedDate!,
                        color: selectedColor,
                        icon: selectedIcon,
                      ),
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meta criada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, selecione uma data limite'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Criar Meta'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMoneyDialog(FinancialGoal goal) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar a: ${goal.title}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Valor',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Digite um valor';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Digite um valor válido';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                setState(() {
                  goal.currentAmount += amount;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${_formatCurrency(amount)} adicionado à meta!'),
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

  void _showEditGoalDialog(FinancialGoal goal) {
    final titleController = TextEditingController(text: goal.title);
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2);
    final amountController = TextEditingController(
      text: formatter.format(goal.targetAmount).replaceAll('.', '').replaceAll(',', '.'),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Nome da Meta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor da Meta',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
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
              setState(() {
                goal.title = titleController.text;
                goal.targetAmount = double.parse(amountController.text);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meta atualizada!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(FinancialGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Meta'),
        content: Text('Tem certeza que deseja excluir a meta "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                goals.remove(goal);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meta excluída'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Sobre Metas Financeiras'),
          ],
        ),
        content: const Text(
          'As metas financeiras ajudam você a economizar de forma organizada.\n\n'
          '• Defina objetivos claros\n'
          '• Acompanhe seu progresso\n'
          '• Adicione valores regularmente\n'
          '• Alcance seus sonhos!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}

// Modelo de Meta Financeira
class FinancialGoal {
  String id;
  String title;
  double targetAmount;
  double currentAmount;
  DateTime deadline;
  Color color;
  IconData icon;

  FinancialGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.color,
    required this.icon,
  });

  double get progress {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  bool get isCompleted => currentAmount >= targetAmount;
}
