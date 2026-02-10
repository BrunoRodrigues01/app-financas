# Minhas Finanças

Um aplicativo de gerenciamento financeiro pessoal desenvolvido em Flutter.

## 📱 Sobre o Projeto

O **Minhas Finanças** é um aplicativo que ajuda você a gerenciar suas finanças pessoais de forma simples e eficiente. Com ele, você pode:

- Registrar suas receitas e despesas
- Acompanhar suas transações
- Definir e acompanhar metas financeiras
- Visualizar relatórios e estatísticas

## 📁 Estrutura do Projeto

```
lib/
├── main.dart              # Arquivo principal do app
├── screens/               # Telas do aplicativo
│   ├── home_screen.dart
│   ├── transactions_screen.dart
│   └── goals_screen.dart
├── models/                # Modelos de dados
│   ├── transaction.dart
│   ├── user.dart
│   └── goal.dart
├── services/              # Serviços (auth, database, etc)
│   ├── auth_service.dart
│   └── database_service.dart
└── utils/                 # Utilitários e funções auxiliares
    ├── formatters.dart
    ├── validators.dart
    └── constants.dart

assets/                    # Recursos do app
├── images/               # Imagens
└── fonts/                # Fontes customizadas
```

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK instalado ([Guia de instalação](https://flutter.dev/docs/get-started/install))
- Editor de código (VS Code, Android Studio, etc)
- Emulador ou dispositivo físico

### Passos

1. Clone o repositório ou navegue até a pasta do projeto

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
flutter run
```

## 🛠️ Tecnologias

- **Flutter** - Framework de desenvolvimento
- **Dart** - Linguagem de programação
- **Material Design 3** - Design system

## 📦 Dependências

- `supabase_flutter` - Cliente Supabase para Flutter
- `provider` - Gerenciamento de estado
- `http` - Requisições HTTP
- `shared_preferences` - Armazenamento local
- `uuid` - Geração de IDs únicos
- `intl` - Formatação de datas e valores monetários

## 📝 Próximos Passos

- [x] Criar estrutura base do projeto
- [x] Implementar telas principais (Home, Transações, Metas)
- [x] **Integrar com Supabase** ✨
- [x] **Implementar autenticação** ✨
- [x] **Sistema de login/registro** ✨
- [x] **Sincronização em nuvem** ✨
- [ ] Adicionar gráficos e relatórios avançados
- [ ] Implementar notificações push
- [ ] Adicionar suporte para múltiplas moedas
- [ ] Criar sistema de categorias personalizadas
- [ ] Exportar relatórios em PDF
- [ ] Implementar modo offline com sincronização

## 👨‍💻 Desenvolvedor

Bruno - Hygicare

## 📄 Licença

Este projeto é de uso pessoal.
