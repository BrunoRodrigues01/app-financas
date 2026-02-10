import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/transaction_service.dart';
import 'package:intl/intl.dart';
import 'settings_screen.dart';
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabaseService = SupabaseService.instance;
  final _transactionService = TransactionService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _statistics;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = _supabaseService.currentUser;
      if (user == null) return;
      
      // Buscar dados do usuário
      final userData = await _supabaseService.client
          .from('usuarios')
          .select()
          .eq('id', user.id)
          .single();
      
      // Buscar estatísticas gerais
      final transactions = await _transactionService.getTransactions();
      
      final totalTransactions = transactions.length;
      final totalReceitas = transactions
          .where((t) => t['tipo'] == 'entrada')
          .fold<double>(0, (sum, t) => sum + (t['valor'] as num).toDouble());
      final totalDespesas = transactions
          .where((t) => t['tipo'] == 'saida')
          .fold<double>(0, (sum, t) => sum + (t['valor'] as num).toDouble());
      
      // Data de criação da conta
      final createdAt = DateTime.parse(userData['created_at']);
      
      setState(() {
        _userData = userData;
        _statistics = {
          'total_transactions': totalTransactions,
          'total_receitas': totalReceitas,
          'total_despesas': totalDespesas,
          'membro_desde': createdAt,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }
  
  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
  
  Future<void> _showPremiumDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber[700], size: 32),
              const SizedBox(width: 12),
              const Text('Premium'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Desbloqueie recursos exclusivos:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildPremiumFeature(Icons.bar_chart, 'Relatórios avançados ilimitados'),
                _buildPremiumFeature(Icons.category, 'Categorias personalizadas ilimitadas'),
                _buildPremiumFeature(Icons.cloud_upload, 'Backup automático na nuvem'),
                _buildPremiumFeature(Icons.analytics, 'Análises preditivas de gastos'),
                _buildPremiumFeature(Icons.notifications_active, 'Alertas personalizados'),
                _buildPremiumFeature(Icons.pie_chart, 'Gráficos premium'),
                _buildPremiumFeature(Icons.file_download, 'Exportar dados em PDF/Excel'),
                _buildPremiumFeature(Icons.support_agent, 'Suporte prioritário'),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'R\$ 9,90/mês',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cancele quando quiser',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Agora Não'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                // Aqui você implementaria a integração com sistema de pagamento
                // Por enquanto, vamos apenas ativar o premium localmente
                final user = _supabaseService.currentUser;
                if (user != null) {
                  await _supabaseService.client
                      .from('usuarios')
                      .update({'premium': true})
                      .eq('id', user.id);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Premium ativado com sucesso! 🎉'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadUserData(); // Recarregar dados
                  }
                }
              },
              child: const Text('Ativar Premium'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildPremiumFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = _supabaseService.currentUser;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar com gradiente
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            _getInitials(user?.email ?? ''),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Email
                      Text(
                        user?.email ?? 'Usuário',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Conteúdo
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Estatísticas
                        _buildStatisticsCard(),
                        const SizedBox(height: 20),
                        
                        // Informações da Conta
                        _buildSectionTitle('Informações da Conta'),
                        const SizedBox(height: 12),
                        _buildAccountInfoCard(),
                        const SizedBox(height: 20),
                        
                        // Preferências
                        _buildSectionTitle('Preferências'),
                        const SizedBox(height: 12),
                        _buildPreferencesCard(),
                        const SizedBox(height: 20),
                        
                        // Sobre
                        _buildSectionTitle('Sobre'),
                        const SizedBox(height: 12),
                        _buildAboutCard(),
                        const SizedBox(height: 20),
                        
                        // Botão de Logout
                        _buildLogoutButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  String _getInitials(String email) {
    if (email.isEmpty) return 'U';
    final parts = email.split('@')[0].split('.');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return email[0].toUpperCase();
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
  
  Widget _buildStatisticsCard() {
    if (_statistics == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Suas Estatísticas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Grid de estatísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Transações',
                    '${_statistics!['total_transactions']}',
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Membro desde',
                    DateFormat('MM/yyyy').format(_statistics!['membro_desde']),
                    Icons.calendar_today,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Receitas',
                    _formatCurrency(_statistics!['total_receitas']),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Total Despesas',
                    _formatCurrency(_statistics!['total_despesas']),
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccountInfoCard() {
    final user = _supabaseService.currentUser;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.email,
            title: 'Email',
            subtitle: user?.email ?? 'Não disponível',
            color: Colors.blue,
          ),
          const Divider(height: 1),
          _buildInfoTile(
            icon: Icons.account_balance_wallet,
            title: 'Saldo Atual',
            subtitle: _formatCurrency(_userData?['saldo_atual'] ?? 0.0),
            color: Colors.green,
          ),
          const Divider(height: 1),
          _buildInfoTile(
            icon: Icons.verified_user,
            title: 'Conta Premium',
            subtitle: _userData?['premium'] == true ? 'Ativa ✓' : 'Inativa',
            color: _userData?['premium'] == true ? Colors.amber : Colors.grey,
            trailing: _userData?['premium'] != true
                ? TextButton(
                    onPressed: () {
                      _showPremiumDialog();
                    },
                    child: const Text('Ativar'),
                  )
                : null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreferencesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.notifications,
            title: 'Notificações',
            subtitle: 'Alertas de vencimento e metas',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(initialSection: SettingsSection.notifications),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildActionTile(
            icon: Icons.dark_mode,
            title: 'Tema',
            subtitle: 'Claro, Escuro ou Automático',
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(initialSection: SettingsSection.theme),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildActionTile(
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Português (Brasil)',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(initialSection: SettingsSection.language),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.help_outline,
            title: 'Central de Ajuda',
            subtitle: 'Tire suas dúvidas',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildActionTile(
            icon: Icons.privacy_tip,
            title: 'Privacidade',
            subtitle: 'Política de privacidade',
            color: Colors.indigo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildActionTile(
            icon: Icons.info_outline,
            title: 'Sobre o App',
            subtitle: 'Versão 1.0.0',
            color: Colors.teal,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Minhas Finanças',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(Icons.account_balance_wallet, size: 48),
                children: [
                  const Text('Aplicativo de controle financeiro pessoal.'),
                  const SizedBox(height: 8),
                  const Text('Desenvolvido com Flutter e Supabase.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
  
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
  
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sair da Conta'),
              content: const Text('Tem certeza que deseja sair?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Sair'),
                ),
              ],
            ),
          );
          
          if (confirm == true && mounted) {
            await _supabaseService.signOut();
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Sair da Conta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
