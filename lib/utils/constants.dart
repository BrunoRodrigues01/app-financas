class Constants {
  // Categorias de despesas
  static const List<String> expenseCategories = [
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

  // Categorias de receitas
  static const List<String> incomeCategories = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Presente',
    'Outros',
  ];

  // Cores para categorias (em hex)
  static const Map<String, String> categoryColors = {
    'Alimentação': '#FF6B6B',
    'Transporte': '#4ECDC4',
    'Moradia': '#45B7D1',
    'Saúde': '#FFA07A',
    'Educação': '#98D8C8',
    'Lazer': '#F7DC6F',
    'Compras': '#BB8FCE',
    'Contas': '#85C1E9',
    'Salário': '#52C41A',
    'Freelance': '#1890FF',
    'Investimentos': '#722ED1',
    'Presente': '#EB2F96',
    'Outros': '#8C8C8C',
  };

  // Limites padrão
  static const double defaultBudgetLimit = 5000.0;
  static const int maxTransactionsPerPage = 20;
}
