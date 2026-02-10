# 🔗 INTEGRAÇÃO COM DADOS REAIS DO SUPABASE

## Status Atual:
- ✅ Supabase configurado
- ✅ Schema SQL executado  
- ✅ Credenciais adicionadas
- ⚠️ **Dados ainda são fictícios/mockados**

---

## 🎯 Próximos Passos para Usar Dados Reais:

### 1️⃣ **Adicionar Autenticação**

Primeiro, você precisa fazer login no app para ter um usuário autenticado.

Vou criar uma tela de login funcional:

```dart
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/supabase_auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = SupabaseAuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (result['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Minhas Finanças', style: TextStyle(fontSize: 32)),
              SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              SizedBox(height: 24),
              _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text('Entrar'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 2️⃣ **Modificar Home Screen para Buscar Dados Reais**

Substitua os dados fictícios por chamadas ao Supabase:

```dart
// lib/screens/home_screen.dart (VERSÃO COM DADOS REAIS)
import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../services/supabase_service.dart';
import 'add_transaction_screen.dart';
import 'goals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Serviços
  final _transactionService = TransactionService();
  final _supabaseService = SupabaseService();
  
  // Dados reais do Supabase
  double saldoAtual = 0.0;
  double receitasMes = 0.0;
  double despesasMes = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // 1. Buscar saldo atual do usuário
      final userId = _supabaseService.currentUserId;
      if (userId != null) {
        final userData = await _supabaseService.client
            .from('usuarios')
            .select('saldo_atual')
            .eq('id', userId)
            .single();
        
        // 2. Buscar estatísticas do mês
        final stats = await _transactionService.getMonthlyStats();
        
        setState(() {
          saldoAtual = userData['saldo_atual'] ?? 0.0;
          receitasMes = stats['total_entradas'] ?? 0.0;
          despesasMes = stats['total_saidas'] ?? 0.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // ... resto do código da tela
  }
}
```

---

### 3️⃣ **Modificar main.dart para Iniciar no Login**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await SupabaseService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minhas Finanças',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Verificar se usuário está logado
      home: FutureBuilder(
        future: _checkAuthentication(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.data == true) {
            return HomeScreen();
          }
          
          return LoginScreen();
        },
      ),
    );
  }
  
  Future<bool> _checkAuthentication() async {
    final supabase = SupabaseService();
    return supabase.currentUser != null;
  }
}
```

---

## 📝 Resumo:

### **Estado Atual:**
✅ Interface bonita funcionando  
✅ Supabase configurado  
⚠️ Dados são fictícios (hardcoded)

### **Para usar dados reais, você precisa:**

1. **Implementar login** → O usuário precisa estar autenticado
2. **Modificar Home Screen** → Buscar dados do Supabase em vez de usar valores fixos
3. **Adicionar transações** → Usar o `TransactionService` que já criamos
4. **Ver dados atualizarem** → Em tempo real no Supabase!

---

## 🚀 Quer que eu implemente isso agora?

Posso modificar o código para:
- ✅ Criar tela de login funcional
- ✅ Conectar Home Screen com dados reais
- ✅ Permitir criar transações de verdade
- ✅ Ver tudo sincronizando com Supabase

**É só confirmar e eu implemento tudo!** 🎯
