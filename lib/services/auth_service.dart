import '../models/user.dart';

class AuthService {
  User? _currentUser;

  // Obter usuário atual
  User? get currentUser => _currentUser;

  // Verificar se o usuário está autenticado
  bool get isAuthenticated => _currentUser != null;

  // Fazer login (simulação)
  Future<User?> login(String email, String password) async {
    try {
      // TODO: Implementar lógica de autenticação real
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = User(
        id: '1',
        name: 'Usuário Teste',
        email: email,
        createdAt: DateTime.now(),
      );
      
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  // Fazer logout
  Future<void> logout() async {
    // TODO: Implementar lógica de logout real
    _currentUser = null;
  }

  // Registrar novo usuário (simulação)
  Future<User?> register(String name, String email, String password) async {
    try {
      // TODO: Implementar lógica de registro real
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      
      return _currentUser;
    } catch (e) {
      return null;
    }
  }
}
