import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingsSection { notifications, theme, language }

class SettingsScreen extends StatefulWidget {
  final SettingsSection? initialSection;
  
  const SettingsScreen({super.key, this.initialSection});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _expenseAlerts = true;
  bool _incomeAlerts = true;
  bool _goalAlerts = true;
  String _selectedTheme = 'system';
  String _selectedLanguage = 'pt_BR';
  TabController? _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Define a aba inicial baseado no parâmetro
    if (widget.initialSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final index = widget.initialSection == SettingsSection.notifications ? 0
                    : widget.initialSection == SettingsSection.theme ? 1
                    : 2;
        _tabController?.animateTo(index);
      });
    }
    
    _loadSettings();
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _expenseAlerts = prefs.getBool('expense_alerts') ?? true;
      _incomeAlerts = prefs.getBool('income_alerts') ?? true;
      _goalAlerts = prefs.getBool('goal_alerts') ?? true;
      _selectedTheme = prefs.getString('theme') ?? 'system';
      _selectedLanguage = prefs.getString('language') ?? 'pt_BR';
    });
  }
  
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('expense_alerts', _expenseAlerts);
    await prefs.setBool('income_alerts', _incomeAlerts);
    await prefs.setBool('goal_alerts', _goalAlerts);
    await prefs.setString('theme', _selectedTheme);
    await prefs.setString('language', _selectedLanguage);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Configurações salvas com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.notifications), text: 'Notificações'),
            Tab(icon: Icon(Icons.palette), text: 'Tema'),
            Tab(icon: Icon(Icons.language), text: 'Idioma'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(),
          _buildThemeTab(),
          _buildLanguageTab(),
        ],
      ),
    );
  }
  
  Widget _buildNotificationsTab() {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Ativar Notificações'),
          subtitle: const Text('Receber alertas no aplicativo'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
          },
          secondary: Icon(
            _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
            color: _notificationsEnabled ? Colors.orange : Colors.grey,
          ),
        ),
        if (_notificationsEnabled) ...[
          SwitchListTile(
            title: const Text('Alertas de Despesas'),
            subtitle: const Text('Vencimentos e contas atrasadas'),
            value: _expenseAlerts,
            onChanged: (value) {
              setState(() => _expenseAlerts = value);
            },
          ),
          SwitchListTile(
            title: const Text('Alertas de Receitas'),
            subtitle: const Text('Recebimentos próximos'),
            value: _incomeAlerts,
            onChanged: (value) {
              setState(() => _incomeAlerts = value);
            },
          ),
          SwitchListTile(
            title: const Text('Alertas de Metas'),
            subtitle: const Text('Progresso e conclusão de metas'),
            value: _goalAlerts,
            onChanged: (value) {
              setState(() => _goalAlerts = value);
            },
          ),
        ],
      ],
    );
  }
  
  Widget _buildThemeTab() {
    return ListView(
      children: [
        RadioListTile<String>(
          title: const Text('Claro'),
          subtitle: const Text('Tema claro sempre ativo'),
          value: 'light',
          groupValue: _selectedTheme,
          onChanged: (value) {
            setState(() => _selectedTheme = value!);
            _saveSettings();
          },
          secondary: const Icon(Icons.light_mode, color: Colors.amber),
        ),
        RadioListTile<String>(
          title: const Text('Escuro'),
          subtitle: const Text('Tema escuro sempre ativo'),
          value: 'dark',
          groupValue: _selectedTheme,
          onChanged: (value) {
            setState(() => _selectedTheme = value!);
            _saveSettings();
          },
          secondary: const Icon(Icons.dark_mode, color: Colors.indigo),
        ),
        RadioListTile<String>(
          title: const Text('Automático'),
          subtitle: const Text('Segue as configurações do sistema'),
          value: 'system',
          groupValue: _selectedTheme,
          onChanged: (value) {
            setState(() => _selectedTheme = value!);
            _saveSettings();
          },
          secondary: const Icon(Icons.brightness_auto, color: Colors.purple),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'O tema será aplicado na próxima inicialização do aplicativo.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLanguageTab() {
    return ListView(
      children: [
        RadioListTile<String>(
          title: const Text('Português (Brasil)'),
          value: 'pt_BR',
          groupValue: _selectedLanguage,
          onChanged: (value) {
            setState(() => _selectedLanguage = value!);
            _saveSettings();
          },
          secondary: const Text('🇧🇷', style: TextStyle(fontSize: 24)),
        ),
        RadioListTile<String>(
          title: const Text('English (US)'),
          value: 'en_US',
          groupValue: _selectedLanguage,
          onChanged: (value) {
            setState(() => _selectedLanguage = value!);
            _saveSettings();
          },
          secondary: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
        ),
        RadioListTile<String>(
          title: const Text('Español'),
          value: 'es_ES',
          groupValue: _selectedLanguage,
          onChanged: (value) {
            setState(() => _selectedLanguage = value!);
            _saveSettings();
          },
          secondary: const Text('🇪🇸', style: TextStyle(fontSize: 24)),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'O idioma será aplicado na próxima inicialização do aplicativo.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
