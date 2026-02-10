import 'package:intl/intl.dart';

class Formatters {
  // Formatar moeda em Real Brasileiro
  static String currency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  // Formatar data
  static String date(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
    return formatter.format(date);
  }

  // Formatar data com hora
  static String dateTime(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return formatter.format(date);
  }

  // Formatar data de forma relativa (hoje, ontem, etc)
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return Formatters.date(date);
    }
  }

  // Formatar porcentagem
  static String percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
}
