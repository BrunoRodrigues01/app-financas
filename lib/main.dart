import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/supabase_service.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar formatação de data para pt_BR
  await initializeDateFormatting('pt_BR', null);
  
  // Inicializar Supabase
  await SupabaseService.initialize(
    supabaseUrl: SupabaseConfig.supabaseUrl,
    supabaseAnonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(const MinhasFinancasApp());
}

class MinhasFinancasApp extends StatelessWidget {
  const MinhasFinancasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minhas Finanças',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthCheck(),
    );
  }
}

// Verificar se o usuário está autenticado
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = SupabaseService.instance;
    
    // Verificar se há um usuário logado
    if (supabase.currentUser != null) {
      return const HomeScreen();
    }
    
    return const LoginScreen();
  }
}
