class Validators {
  // Validar email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um email';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }
    
    return null;
  }

  // Validar senha
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma senha';
    }
    
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }

  // Validar campo obrigatório
  static String? required(String? value, [String fieldName = 'campo']) {
    if (value == null || value.isEmpty) {
      return 'Por favor, preencha o $fieldName';
    }
    return null;
  }

  // Validar valor monetário
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um valor';
    }
    
    final amount = double.tryParse(value.replaceAll(',', '.'));
    
    if (amount == null) {
      return 'Por favor, insira um valor válido';
    }
    
    if (amount <= 0) {
      return 'O valor deve ser maior que zero';
    }
    
    return null;
  }
}
