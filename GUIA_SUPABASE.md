# 🚀 Guia Completo de Configuração do Supabase

Este guia mostrará como configurar o Supabase para o app **Minhas Finanças**.

---

## 📋 Pré-requisitos

- Conta no Supabase (gratuita)
- Flutter instalado
- Editor de código (VS Code recomendado)

---

## 1️⃣ Criar Conta no Supabase

1. Acesse: https://supabase.com
2. Clique em **"Start your project"**
3. Faça login com GitHub, Google ou Email
4. É **totalmente gratuito** para começar!

---

## 2️⃣ Criar um Novo Projeto

1. No dashboard do Supabase, clique em **"New Project"**
2. Preencha:
   - **Name**: `minhas-financas` (ou o nome que preferir)
   - **Database Password**: Crie uma senha forte (guarde-a!)
   - **Region**: Escolha a mais próxima (ex: South America - São Paulo)
3. Clique em **"Create new project"**
4. Aguarde alguns minutos enquanto o projeto é criado ☕

---

## 3️⃣ Obter as Credenciais do Projeto

1. No menu lateral, vá em **Settings** (⚙️)
2. Clique em **API**
3. Você verá:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

4. **COPIE ESSAS DUAS INFORMAÇÕES!** 📋

---

## 4️⃣ Configurar o App Flutter

### Passo 1: Editar o arquivo de configuração

Abra o arquivo: `lib/config/supabase_config.dart`

```dart
class SupabaseConfig {
  // Cole suas credenciais aqui
  static const String supabaseUrl = 'https://xxxxx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
```

### Passo 2: Instalar as dependências

Execute no terminal:
```bash
flutter pub get
```

---

## 5️⃣ Criar as Tabelas no Banco de Dados

1. No Supabase, vá em **SQL Editor** (ícone de código no menu lateral)
2. Clique em **"New query"**
3. Copie TODO o conteúdo do arquivo `supabase_schema.sql`
4. Cole no editor SQL
5. Clique em **"Run"** (ou pressione Ctrl+Enter)
6. Aguarde a confirmação ✅

### O que foi criado:
- ✅ Tabela `profiles` (perfis de usuários)
- ✅ Tabela `transactions` (transações financeiras)
- ✅ Tabela `goals` (metas financeiras)
- ✅ Políticas de segurança (RLS)
- ✅ Índices para performance
- ✅ Triggers automáticos

---

## 6️⃣ Configurar Autenticação por Email

1. No Supabase, vá em **Authentication** → **Settings**
2. Em **Email Auth**, certifique-se que está **habilitado**
3. Configure:
   - ✅ Enable email confirmations (opcional)
   - ✅ Enable email change confirmations (opcional)

---

## 7️⃣ Testar a Conexão

Execute o app:

### Opção 1: Windows Desktop
```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

### Opção 2: Chrome
```bash
flutter run -d chrome
```

### Opção 3: Emulador Android/iOS
```bash
flutter run
```

---

## 8️⃣ Estrutura das Tabelas

### 📊 Tabela: `transactions`
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | UUID | ID único da transação |
| `user_id` | UUID | ID do usuário |
| `title` | TEXT | Título da transação |
| `amount` | DECIMAL | Valor |
| `date` | TIMESTAMP | Data da transação |
| `type` | TEXT | "income" ou "expense" |
| `category` | TEXT | Categoria |
| `description` | TEXT | Descrição opcional |

### 🎯 Tabela: `goals`
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | UUID | ID único da meta |
| `user_id` | UUID | ID do usuário |
| `title` | TEXT | Nome da meta |
| `target_amount` | DECIMAL | Valor alvo |
| `current_amount` | DECIMAL | Valor atual |
| `deadline` | TIMESTAMP | Data limite |
| `description` | TEXT | Descrição opcional |

### 👤 Tabela: `profiles`
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | UUID | ID do usuário |
| `name` | TEXT | Nome do usuário |
| `avatar_url` | TEXT | URL do avatar |

---

## 9️⃣ Segurança (RLS - Row Level Security)

O Supabase usa **Row Level Security** para proteger os dados:

- ✅ Usuários só podem ver **suas próprias** transações
- ✅ Usuários só podem editar **suas próprias** metas
- ✅ Ninguém pode acessar dados de outros usuários
- ✅ Tudo é gerenciado automaticamente!

---

## 🔟 Testando o App

### Criar uma conta:
1. Execute o app
2. Clique em **"Registre-se"**
3. Preencha nome, email e senha
4. Clique em **"Criar Conta"**

### Fazer login:
1. Use o email e senha cadastrados
2. Clique em **"Entrar"**

### Adicionar transações:
1. Na tela inicial, clique em **"Nova Transação"**
2. Preencha os dados
3. Salve!

### Criar metas:
1. Navegue até **"Metas Financeiras"**
2. Clique em **"Nova Meta"**
3. Defina valor e prazo
4. Acompanhe o progresso!

---

## 🛠️ Serviços Disponíveis

O app já vem com serviços prontos:

### `SupabaseAuthService`
- Login/Logout
- Registro de usuário
- Recuperação de senha
- Atualização de perfil

### `SupabaseTransactionService`
- Adicionar/Editar/Deletar transações
- Listar transações
- Filtrar por período/categoria
- Calcular saldo e estatísticas
- Stream em tempo real

### `SupabaseGoalService`
- Adicionar/Editar/Deletar metas
- Listar metas
- Adicionar valores às metas
- Calcular progresso
- Stream em tempo real

---

## 📊 Dashboard do Supabase

No dashboard você pode:

- **Table Editor**: Ver e editar dados manualmente
- **SQL Editor**: Executar queries SQL
- **Authentication**: Ver usuários cadastrados
- **Database**: Ver estrutura das tabelas
- **Storage**: Upload de arquivos (para avatares)
- **Logs**: Ver logs de requisições

---

## 🎯 Próximos Passos

1. ✅ Configurar o Supabase ← **Você está aqui!**
2. ⬜ Personalizar temas e cores
3. ⬜ Adicionar gráficos avançados
4. ⬜ Implementar notificações
5. ⬜ Adicionar backup automático
6. ⬜ Criar relatórios em PDF
7. ⬜ Implementar categorias customizadas

---

## ❓ Problemas Comuns

### Erro: "Invalid API key"
- Verifique se copiou a chave correta
- Confira se não há espaços extras

### Erro: "Row Level Security"
- Execute o script SQL completo
- Verifique se as políticas foram criadas

### App não conecta
- Verifique sua conexão com internet
- Confirme se o projeto do Supabase está ativo
- Veja os logs no console

---

## 📚 Documentação Útil

- [Supabase Docs](https://supabase.com/docs)
- [Flutter & Supabase](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

---

## 🎉 Pronto!

Seu app agora está conectado ao Supabase e pronto para uso!

**Dica**: O plano gratuito do Supabase oferece:
- ✅ 500MB de armazenamento
- ✅ 2GB de transferência
- ✅ 50.000 usuários ativos mensais
- ✅ **Totalmente suficiente para começar!**

---

**Desenvolvido com ❤️ para ajudar você a gerenciar suas finanças!**
