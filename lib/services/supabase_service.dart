import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  // Cliente Supabase
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase não foi inicializado. Chame initialize() primeiro.');
    }
    return _client!;
  }

  // Inicializar Supabase
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _client = Supabase.instance.client;
  }

  // Verificar se está inicializado
  bool get isInitialized => _client != null;

  // Obter usuário atual
  User? get currentUser => client.auth.currentUser;
  
  // Obter ID do usuário atual
  String? get currentUserId => currentUser?.id;

  // Verificar se está autenticado
  bool get isAuthenticated => currentUser != null;

  // Stream de mudanças de autenticação
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  // Fazer logout
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
