import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
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
                  Colors.indigo,
                  Colors.indigo.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.privacy_tip,
                  size: 64,
                  color: Colors.white,
                ),
                SizedBox(height: 12),
                Text(
                  'Sua Privacidade é Importante',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Última atualização: Janeiro 2025',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            '1. Informações que Coletamos',
            'Coletamos apenas as informações necessárias para fornecer nossos serviços:\n\n'
            '• Email e senha para autenticação\n'
            '• Transações financeiras que você registra\n'
            '• Categorias e orçamentos personalizados\n'
            '• Preferências de configuração do app',
            Icons.info_outline,
          ),
          
          _buildSection(
            '2. Como Usamos suas Informações',
            'Suas informações são usadas exclusivamente para:\n\n'
            '• Fornecer e melhorar nossos serviços\n'
            '• Sincronizar seus dados entre dispositivos\n'
            '• Enviar notificações importantes (se habilitado)\n'
            '• Gerar relatórios e análises financeiras',
            Icons.settings,
          ),
          
          _buildSection(
            '3. Armazenamento e Segurança',
            'Levamos a segurança dos seus dados muito a sério:\n\n'
            '• Todos os dados são criptografados em trânsito e em repouso\n'
            '• Armazenados em servidores seguros do Supabase\n'
            '• Acesso protegido por autenticação forte\n'
            '• Backups regulares para prevenir perda de dados',
            Icons.security,
          ),
          
          _buildSection(
            '4. Compartilhamento de Dados',
            'Nós NÃO compartilhamos, vendemos ou alugamos suas informações pessoais:\n\n'
            '• Seus dados financeiros são privados e confidenciais\n'
            '• Não enviamos publicidade direcionada\n'
            '• Não rastreamos sua atividade fora do app\n'
            '• Não compartilhamos com terceiros sem seu consentimento',
            Icons.block,
          ),
          
          _buildSection(
            '5. Seus Direitos',
            'Você tem total controle sobre seus dados:\n\n'
            '• Acessar todos os seus dados a qualquer momento\n'
            '• Exportar suas informações em formato legível\n'
            '• Solicitar correção de dados incorretos\n'
            '• Excluir sua conta e todos os dados associados',
            Icons.verified_user,
          ),
          
          _buildSection(
            '6. Cookies e Tecnologias',
            'Usamos tecnologias padrão para melhorar sua experiência:\n\n'
            '• Cookies de sessão para manter você conectado\n'
            '• Armazenamento local para preferências do app\n'
            '• Analytics para entender uso e melhorar recursos\n'
            '• Você pode desabilitar cookies nas configurações',
            Icons.cookie,
          ),
          
          _buildSection(
            '7. Alterações nesta Política',
            'Podemos atualizar esta política periodicamente:\n\n'
            '• Notificaremos sobre mudanças significativas\n'
            '• A data da última atualização será sempre visível\n'
            '• Continuar usando o app indica aceitação das mudanças',
            Icons.update,
          ),
          
          _buildSection(
            '8. Contato',
            'Para questões sobre privacidade, entre em contato:\n\n'
            '• Email: suporte@minhasfinancas.com\n'
            '• Tempo de resposta: até 48 horas úteis\n'
            '• Estamos à disposição para esclarecer dúvidas',
            Icons.contact_mail,
          ),
          
          const SizedBox(height: 24),
          
          // Footer
          Card(
            elevation: 2,
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Seus dados financeiros estão seguros e protegidos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
  
  Widget _buildSection(String title, String content, IconData icon) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.indigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
