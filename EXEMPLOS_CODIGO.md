# 💻 EXEMPLOS PRÁTICOS DE CÓDIGO

## Como usar os serviços no seu app Flutter

---

## 1️⃣ TRANSAÇÕES

### Importar o serviço:
```dart
import 'package:minhas_financas/services/transaction_service.dart';
```

### Exemplo 1: Adicionar Receita
```dart
Future<void> adicionarSalario() async {
  final service = TransactionService();
  
  final result = await service.addTransaction(
    tipo: 'entrada',
    categoria: 'Salário',
    valor: 5000.00,
    descricao: 'Salário mensal de Janeiro',
    data: DateTime.now(),
  );
  
  if (result['success']) {
    print('✅ ${result['message']}');
    // Mostrar notificação de sucesso
  } else {
    print('❌ ${result['message']}');
    // Mostrar erro
  }
}
```

### Exemplo 2: Adicionar Despesa
```dart
Future<void> registrarCompra() async {
  final service = TransactionService();
  
  final result = await service.addTransaction(
    tipo: 'saida',
    categoria: 'Alimentação',
    valor: 250.75,
    descricao: 'Compras do supermercado',
  );
  
  if (result['success']) {
    // Saldo foi atualizado automaticamente!
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
  }
}
```

### Exemplo 3: Listar Transações do Mês
```dart
Future<void> listarTransacoesMes() async {
  final service = TransactionService();
  
  try {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    final transactions = await service.getTransactionsByPeriod(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
    
    print('Total de transações: ${transactions.length}');
    
    for (var transaction in transactions) {
      print('${transaction['tipo']}: R\$ ${transaction['valor']} - ${transaction['categoria']}');
    }
  } catch (e) {
    print('Erro: $e');
  }
}
```

### Exemplo 4: Obter Estatísticas
```dart
Future<void> mostrarEstatisticas() async {
  final service = TransactionService();
  
  try {
    final stats = await service.getMonthlyStats();
    
    print('📊 Estatísticas do Mês:');
    print('💰 Receitas: R\$ ${stats['total_entradas']}');
    print('💸 Despesas: R\$ ${stats['total_saidas']}');
    print('📈 Saldo: R\$ ${stats['saldo_mes']}');
    print('🔢 Transações: ${stats['transacoes_count']}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### Exemplo 5: Gastos por Categoria
```dart
Future<void> analisarGastos() async {
  final service = TransactionService();
  
  try {
    final gastos = await service.getExpensesByCategory();
    
    print('📊 Gastos por Categoria:');
    gastos.forEach((categoria, valor) {
      print('$categoria: R\$ ${valor.toStringAsFixed(2)}');
    });
    
    // Exemplo de saída:
    // Alimentação: R\$ 850.50
    // Transporte: R\$ 320.00
    // Lazer: R\$ 150.00
  } catch (e) {
    print('Erro: $e');
  }
}
```

### Exemplo 6: Stream em Tempo Real
```dart
class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final service = TransactionService();
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: service.watchTransactions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }
        
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        
        final transactions = snapshot.data!;
        
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return ListTile(
              title: Text(transaction['descricao'] ?? 'Sem descrição'),
              subtitle: Text(transaction['categoria']),
              trailing: Text(
                'R\$ ${transaction['valor'].toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction['tipo'] == 'entrada' 
                    ? Colors.green 
                    : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
```

---

## 2️⃣ METAS

### Importar o serviço:
```dart
import 'package:minhas_financas/services/goal_service.dart';
```

### Exemplo 1: Criar Meta
```dart
Future<void> criarMetaViagem() async {
  final goalService = GoalService();
  
  final result = await goalService.addGoal(
    tipo: 'economia',
    titulo: 'Viagem para Europa',
    valor: 10000.00,
    dataConclusao: DateTime(2026, 12, 31),
    descricao: 'Economizar para viagem de férias',
  );
  
  if (result['success']) {
    print('✅ ${result['message']}');
    final meta = result['data'];
    print('Meta ID: ${meta['id']}');
    print('Progresso inicial: ${meta['progresso']}%');
  } else {
    print('❌ ${result['message']}');
  }
}
```

### Exemplo 2: Adicionar Valor à Meta
```dart
Future<void> contribuirParaMeta(String goalId) async {
  final goalService = GoalService();
  
  final result = await goalService.addAmountToGoal(
    goalId: goalId,
    amount: 500.00,
  );
  
  if (result['success']) {
    if (result['completed']) {
      // Meta concluída! 🎉
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('🎉 Parabéns!'),
          content: Text('Você atingiu sua meta!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fechar'),
            ),
          ],
        ),
      );
    } else {
      // Apenas atualizado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }
}
```

### Exemplo 3: Listar Metas Ativas
```dart
Future<void> mostrarMetasAtivas() async {
  final goalService = GoalService();
  
  try {
    final metas = await goalService.getActiveGoals();
    
    print('🎯 Metas Ativas (${metas.length}):');
    
    for (var meta in metas) {
      print('\n📌 ${meta['titulo']}');
      print('   Valor: R\$ ${meta['valor']}');
      print('   Atual: R\$ ${meta['valor_atual']}');
      print('   Progresso: ${meta['progresso']}%');
      print('   Prazo: ${meta['data_conclusao']}');
    }
  } catch (e) {
    print('Erro: $e');
  }
}
```

### Exemplo 4: Progresso Geral
```dart
Future<void> mostrarProgressoGeral() async {
  final goalService = GoalService();
  
  try {
    final progresso = await goalService.getOverallProgress();
    
    print('📊 Progresso Geral das Metas:');
    print('Total de metas: ${progresso['total_metas']}');
    print('Progresso médio: ${progresso['progresso_medio'].toStringAsFixed(1)}%');
    print('Valor total: R\$ ${progresso['valor_total']}');
    print('Valor atual: R\$ ${progresso['valor_atual']}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### Exemplo 5: Widget de Meta com Barra de Progresso
```dart
class GoalCard extends StatelessWidget {
  final Map<String, dynamic> goal;
  
  const GoalCard({required this.goal});
  
  @override
  Widget build(BuildContext context) {
    final progress = (goal['progresso'] as num).toDouble();
    final current = (goal['valor_atual'] as num).toDouble();
    final target = (goal['valor'] as num).toDouble();
    final isCompleted = goal['status'] == 'concluida';
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.flag,
                  color: isCompleted ? Colors.green : Colors.blue,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal['titulo'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Barra de Progresso
            LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Colors.blue,
              ),
            ),
            SizedBox(height: 8),
            
            // Valores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('R\$ ${current.toStringAsFixed(2)}'),
                Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('R\$ ${target.toStringAsFixed(2)}'),
              ],
            ),
            
            // Botão de adicionar valor
            if (!isCompleted)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddAmountDialog(context, goal['id']),
                  icon: Icon(Icons.add),
                  label: Text('Adicionar Valor'),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showAddAmountDialog(BuildContext context, String goalId) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar Valor'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Valor',
            prefixText: 'R\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                await contribuirParaMeta(goalId);
              }
            },
            child: Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
```

---

## 3️⃣ INTEGRAÇÃO COMPLETA

### Exemplo: Tela de Dashboard Completa
```dart
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final transactionService = TransactionService();
  final goalService = GoalService();
  
  Map<String, dynamic>? stats;
  Map<String, dynamic>? goalProgress;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    loadData();
  }
  
  Future<void> loadData() async {
    setState(() => isLoading = true);
    
    try {
      final statsData = await transactionService.getMonthlyStats();
      final progressData = await goalService.getOverallProgress();
      
      setState(() {
        stats = statsData;
        goalProgress = progressData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Card de Saldo
          _buildBalanceCard(),
          SizedBox(height: 16),
          
          // Card de Receitas e Despesas
          Row(
            children: [
              Expanded(child: _buildIncomeCard()),
              SizedBox(width: 16),
              Expanded(child: _buildExpenseCard()),
            ],
          ),
          SizedBox(height: 16),
          
          // Card de Progresso das Metas
          _buildGoalsProgressCard(),
          SizedBox(height: 16),
          
          // Botões de Ação
          _buildActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildBalanceCard() {
    final saldo = stats?['saldo_mes'] ?? 0.0;
    
    return Card(
      color: Colors.blue,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo do Mês',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              'R\$ ${saldo.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIncomeCard() {
    final receitas = stats?['total_entradas'] ?? 0.0;
    
    return Card(
      color: Colors.green[100],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.arrow_downward, color: Colors.green, size: 32),
            SizedBox(height: 8),
            Text('Receitas', style: TextStyle(color: Colors.green[800])),
            Text(
              'R\$ ${receitas.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExpenseCard() {
    final despesas = stats?['total_saidas'] ?? 0.0;
    
    return Card(
      color: Colors.red[100],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.arrow_upward, color: Colors.red, size: 32),
            SizedBox(height: 8),
            Text('Despesas', style: TextStyle(color: Colors.red[800])),
            Text(
              'R\$ ${despesas.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGoalsProgressCard() {
    final totalMetas = goalProgress?['total_metas'] ?? 0;
    final progressoMedio = goalProgress?['progresso_medio'] ?? 0.0;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso das Metas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: progressoMedio / 100,
              minHeight: 10,
            ),
            SizedBox(height: 8),
            Text(
              '$totalMetas metas ativas - ${progressoMedio.toStringAsFixed(1)}% concluído',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Navegar para adicionar transação
            },
            icon: Icon(Icons.add),
            label: Text('Nova Transação'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(16),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Navegar para metas
            },
            icon: Icon(Icons.flag),
            label: Text('Ver Metas'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## 🎯 DICAS IMPORTANTES:

### 1. Sempre trate erros:
```dart
try {
  final result = await service.addTransaction(...);
  if (result['success']) {
    // Sucesso
  } else {
    // Erro com mensagem amigável
    print(result['message']);
  }
} catch (e) {
  // Erro inesperado
  print('Erro: $e');
}
```

### 2. Use loading states:
```dart
bool isLoading = false;

Future<void> saveTransaction() async {
  setState(() => isLoading = true);
  
  try {
    await service.addTransaction(...);
  } finally {
    setState(() => isLoading = false);
  }
}
```

### 3. Aproveite os streams:
```dart
// Dados atualizados em tempo real!
StreamBuilder<List<Map<String, dynamic>>>(
  stream: service.watchTransactions(),
  builder: (context, snapshot) {
    // UI atualiza automaticamente
  },
)
```

---

**Estes exemplos estão prontos para uso!** 🚀

Copie e cole no seu código Flutter e adapte conforme necessário.
