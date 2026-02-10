import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Ajuda'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Como podemos ajudar?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tire suas dúvidas sobre o app',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Perguntas Frequentes
          const Text(
            'Perguntas Frequentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFaqItem(
            context,
            'Como adicionar uma transação?',
            'Toque no botão "+" na tela inicial. Selecione o tipo (Receita ou Despesa), preencha os dados e salve.',
            Icons.add_circle,
          ),
          
          _buildFaqItem(
            context,
            'Como funcionam as categorias?',
            'As categorias ajudam a organizar suas transações. Você pode usar as categorias padrão ou criar suas próprias na tela de Categorias.',
            Icons.category,
          ),
          
          _buildFaqItem(
            context,
            'Como acompanhar meu orçamento?',
            'Na tela de Orçamento, defina valores anuais para cada categoria. O app calcula automaticamente o limite mensal e mostra seu progresso.',
            Icons.account_balance_wallet,
          ),
          
          _buildFaqItem(
            context,
            'Como controlar contas a pagar?',
            'Ao adicionar uma despesa, marque a data de vencimento. O app mostrará alertas de vencimento na tela inicial e você pode marcar como paga diretamente.',
            Icons.payment,
          ),
          
          _buildFaqItem(
            context,
            'Como ver relatórios detalhados?',
            'Na tela de Relatórios, você pode visualizar gráficos de pizza, barras e linha. Filtre por período e tipo de transação para análises mais específicas.',
            Icons.bar_chart,
          ),
          
          _buildFaqItem(
            context,
            'O que é a conta Premium?',
            'A conta Premium desbloqueia recursos avançados como relatórios ilimitados, backup automático, análises preditivas e muito mais.',
            Icons.workspace_premium,
          ),
          
          _buildFaqItem(
            context,
            'Meus dados estão seguros?',
            'Sim! Todos os dados são armazenados de forma segura no Supabase com criptografia. Suas informações financeiras são privadas e protegidas.',
            Icons.security,
          ),
          
          _buildFaqItem(
            context,
            'Como exportar meus dados?',
            'Na tela de Relatórios, toque no botão de compartilhar. Você pode exportar seus dados em formato de imagem ou PDF (Premium).',
            Icons.file_download,
          ),
          
          const SizedBox(height: 24),
          
          // Contato
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ainda precisa de ajuda?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Entre em contato com nosso suporte',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Em breve você poderá nos contatar diretamente pelo app!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Enviar Email'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildFaqItem(BuildContext context, String question, String answer, IconData icon) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
