import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class SupabaseAuthService {
  final _supabase = SupabaseService.instance.client;

  // Obter usuário atual
  User? get currentUser => _supabase.auth.currentUser;

  // Verificar se está autenticado
  bool get isAuthenticated => currentUser != null;

  // Stream de mudanças de autenticação
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ==================== AUTENTICAÇÃO ====================

  // Fazer login com email e senha
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Registrar novo usuário
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Fazer logout
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Recuperar senha
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar senha
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar perfil do usuário
  Future<UserResponse> updateProfile({
    String? name,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (additionalData != null) data.addAll(additionalData);

      final response = await _supabase.auth.updateUser(
        UserAttributes(data: data),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Obter dados do perfil do usuário
  Map<String, dynamic>? get userMetadata => currentUser?.userMetadata;

  // Obter nome do usuário
  String? get userName => userMetadata?['name'] as String?;

  // Obter email do usuário
  String? get userEmail => currentUser?.email;
}
