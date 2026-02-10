import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/transaction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _transactionService = TransactionService();
  
  // Tipo de transação: true = Entrada, false = Saída
  bool isIncome = true;
  String? selectedCategory;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  
  // Controle de pagamento (apenas para despesas)
  bool _isPaid = false;
  DateTime? _dueDate;
  DateTime? _paymentDate;
  
  // Categorias
  final List<String> incomeCategories = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Presente',
    'Outros',
  ];
  
  final List<String> expenseCategories = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Saúde',
    'Educação',
    'Lazer',
    'Compras',
    'Contas',
    'Outros',
  ];

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get currentCategories => 
      isIncome ? incomeCategories : expenseCategories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Nova Transação'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seletor de Tipo de Transação
                _buildTransactionTypeSelector(),
                const SizedBox(height: 30),
                
                // Campo de Valor
                _buildValueField(),
                const SizedBox(height: 24),
                
                // Seletor de Categoria
                _buildCategorySelector(),
                const SizedBox(height: 24),
                
                // Campo de Descrição
                _buildDescriptionField(),
                const SizedBox(height: 24),
                
                // Data da Transação
                _buildDateSelector(),
                const SizedBox(height: 24),
                
                // Campos de Pagamento (para receitas e despesas)
                _buildPaymentFields(),
                const SizedBox(height: 24),
                
                // Botão de Salvar
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Transação',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  label: '💰 Entrada',
                  isSelected: isIncome,
                  color: Colors.green,
                  onTap: () {
                    setState(() {
                      isIncome = true;
                      selectedCategory = null; // Reset categoria ao mudar tipo
                      _isPaid = false;
                      _dueDate = null;
                      _paymentDate = null;
                    });
                  },
                ),
              ),
              Expanded(
                child: _buildTypeOption(
                  label: '💸 Saída',
                  isSelected: !isIncome,
                  color: Colors.red,
                  onTap: () {
                    setState(() {
                      isIncome = false;
                      selectedCategory = null; // Reset categoria ao mudar tipo
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valor',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isIncome ? Colors.green : Colors.red).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: TextFormField(
            controller: _valueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green[700] : Colors.red[700],
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 20, top: 12),
                child: Text(
                  'R\$',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
              hintText: '0,00',
              hintStyle: TextStyle(
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira um valor';
              }
              final amount = double.tryParse(value.replaceAll(',', '.'));
              if (amount == null || amount <= 0) {
                return 'Por favor, insira um valor válido';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.category),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            hint: const Text('Selecione uma categoria'),
            isExpanded: true,
            borderRadius: BorderRadius.circular(12),
            items: currentCategories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Row(
                  children: [
                    _getCategoryIcon(category),
                    const SizedBox(width: 12),
                    Text(category),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione uma categoria';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descrição (opcional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Icon(Icons.notes),
              ),
              hintText: 'Adicione uma descrição para esta transação...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final formattedDate = '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[700]),
                const SizedBox(width: 16),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                isIncome ? 'Controle de Recebimento' : 'Controle de Pagamento',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Checkbox - Marcar como paga/recebida
          InkWell(
            onTap: () {
              setState(() {
                _isPaid = !_isPaid;
                if (_isPaid) {
                  _paymentDate = DateTime.now();
                } else {
                  _paymentDate = null;
                }
              });
            },
            child: Row(
              children: [
                Checkbox(
                  value: _isPaid,
                  onChanged: (value) {
                    setState(() {
                      _isPaid = value ?? false;
                      if (_isPaid) {
                        _paymentDate = DateTime.now();
                      } else {
                        _paymentDate = null;
                      }
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    isIncome ? 'Marcar como recebida' : 'Marcar como paga',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Data de Vencimento / Previsão
          Text(
            isIncome ? 'Data Prevista de Recebimento (opcional)' : 'Data de Vencimento (opcional)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _dueDate = date;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.event, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? 'Selecione uma data'
                          : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                      style: TextStyle(
                        color: _dueDate == null ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      icon: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
          
          // Data de Pagamento/Recebimento (somente se marcado como pago/recebido)
          if (_isPaid) ...[
            const SizedBox(height: 12),
            Text(
              isIncome ? 'Data de Recebimento' : 'Data de Pagamento',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _paymentDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _paymentDate = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _paymentDate == null
                          ? 'Hoje'
                          : '${_paymentDate!.day}/${_paymentDate!.month}/${_paymentDate!.year}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: isIncome ? Colors.green : Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Salvar Transação',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    final iconMap = {
      // Receitas
      'Salário': Icons.work,
      'Freelance': Icons.laptop,
      'Investimentos': Icons.trending_up,
      'Presente': Icons.card_giftcard,
      // Despesas
      'Alimentação': Icons.restaurant,
      'Transporte': Icons.directions_car,
      'Moradia': Icons.home,
      'Saúde': Icons.local_hospital,
      'Educação': Icons.school,
      'Lazer': Icons.movie,
      'Compras': Icons.shopping_bag,
      'Contas': Icons.receipt,
      'Outros': Icons.more_horiz,
    };
    
    return Icon(
      iconMap[category] ?? Icons.category,
      size: 20,
      color: isIncome ? Colors.green[700] : Colors.red[700],
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma categoria'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final value = double.parse(_valueController.text.replaceAll(',', '.'));
      final description = _descriptionController.text;
      
      // Salvar transação no Supabase
      final result = await _transactionService.addTransaction(
        tipo: isIncome ? 'entrada' : 'saida',
        categoria: selectedCategory!,
        valor: value,
        descricao: description.isEmpty ? null : description,
        data: _selectedDate,
        pago: _isPaid,
        dataVencimento: _dueDate,
        dataPagamento: _isPaid ? _paymentDate : null,
      );
      
      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(result['message'] ?? 'Transação salva!'),
                  ),
                ],
              ),
              backgroundColor: isIncome ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Voltar para a tela anterior
          Navigator.pop(context, true); // true indica que houve mudança
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Erro ao salvar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
