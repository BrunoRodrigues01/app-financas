# 💰 Sistema de Controle de Pagamentos

## 📋 Visão Geral

Sistema completo para rastrear despesas pagas e pendentes, com alertas de vencimento e dashboard de contas a pagar.

---

## 🗄️ Banco de Dados

### Novos Campos na Tabela `transactions`:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `pago` | BOOLEAN | Se a despesa foi paga (true) ou está pendente (false) |
| `data_vencimento` | DATE | Data de vencimento da despesa (opcional) |
| `data_pagamento` | DATE | Data em que foi efetivamente paga (opcional) |

### Instalação:

```sql
-- Execute o script no Supabase SQL Editor:
database/add_payment_tracking.sql
```

---

## ✨ Funcionalidades

### 1. **Status Visual das Despesas**

- 🟢 **Paga**: Despesa quitada
- 🟡 **Pendente**: Aguardando pagamento (no prazo)
- 🔴 **Atrasada**: Vencimento passou e não foi paga
- ⚪ **Sem Vencimento**: Despesa sem data definida

### 2. **Classificação por Urgência**

- 🔥 **Vence Hoje**: Data de vencimento = hoje
- ⏰ **Vence em Breve**: Vencimento em até 3 dias
- ✅ **No Prazo**: Vencimento em mais de 3 dias
- 📅 **Sem Vencimento**: Não tem data definida

### 3. **Ações Rápidas**

- ✔️ Marcar como paga
- ↩️ Desmarcar pagamento
- 📅 Editar data de vencimento
- 💳 Registrar data de pagamento

### 4. **Filtros na Home**

- Todas as despesas
- Apenas pendentes
- Apenas pagas
- Apenas atrasadas

### 5. **Dashboard de Pagamentos**

Card especial mostrando:
- Total de despesas do mês
- Valor pago
- Valor pendente
- Valor atrasado
- Quantidade de contas pendentes
- Próximos vencimentos

### 6. **Notificações (Futuro)**

- 🔔 Alerta 3 dias antes do vencimento
- 🔔 Alerta no dia do vencimento
- 🔔 Alerta de despesa atrasada

---

## 💻 Implementação no App

### Fluxo de Uso:

1. **Adicionar Despesa**:
   ```
   - Usuário preenche formulário
   - Define se é despesa recorrente
   - Pode marcar como "Paga" ou deixar "Pendente"
   - Se pendente, pode definir data de vencimento
   ```

2. **Visualizar Despesas**:
   ```
   - Home mostra todas as transações
   - Ícone de status ao lado de cada despesa
   - Cores indicam urgência
   - Badge com "dias até vencimento"
   ```

3. **Marcar como Paga**:
   ```
   - Toque rápido no ícone de status
   - Ou swipe na transação
   - Sistema registra data de pagamento
   - Status atualiza instantaneamente
   ```

4. **Dashboard**:
   ```
   - Card "Contas a Pagar" na home
   - Mostra resumo do mês
   - Lista próximos vencimentos
   - Acesso rápido para pagar
   ```

---

## 🎨 Design da Interface

### Card de Despesa:

```
┌─────────────────────────────────────────┐
│ 🍔 Alimentação            🔴 Atrasada   │
│ Restaurante XYZ            R$ 150,00    │
│ 15/02/2026                               │
│ Venceu há 2 dias  ❌ Não paga           │
│ [Marcar como Paga]                      │
└─────────────────────────────────────────┘
```

### Dashboard de Pagamentos:

```
┌─────────────────────────────────────────┐
│ 💳 Contas a Pagar - Fevereiro 2026      │
├─────────────────────────────────────────┤
│ Total:     R$ 3.500,00  ━━━━━━━━━━ 100% │
│ Pagas:     R$ 2.000,00  ━━━━━━     57%  │
│ Pendentes: R$ 1.200,00  ━━━━       34%  │
│ Atrasadas: R$   300,00  ━          9%   │
├─────────────────────────────────────────┤
│ 📅 Próximos Vencimentos:                │
│ • Hoje: Aluguel - R$ 1.000,00           │
│ • Amanhã: Internet - R$ 100,00          │
│ • Em 2 dias: Energia - R$ 200,00        │
└─────────────────────────────────────────┘
```

---

## 🔧 Arquivos a Criar/Modificar:

### Backend:
- ✅ `database/add_payment_tracking.sql` (CRIADO)

### Services:
- 📝 Atualizar `transaction_service.dart`:
  - Adicionar campos pago, data_vencimento, data_pagamento
  - Método `markAsPaid()`
  - Método `unmarkPaid()`
  - Método `getPaymentStatistics()`
  - Método `getPendingExpenses()`
  - Método `getOverdueExpenses()`

### Screens:
- 📝 Atualizar `home_screen.dart`:
  - Adicionar card "Contas a Pagar"
  - Adicionar filtros (Todas/Pendentes/Pagas/Atrasadas)
  - Mostrar status visual nas despesas

- 📝 Atualizar `add_transaction_screen.dart`:
  - Checkbox "Marcar como paga"
  - Campo "Data de Vencimento" (DatePicker)
  - Campo "Data de Pagamento" (se marcada como paga)

- 📝 Criar `payment_dashboard_screen.dart`:
  - Tela dedicada para gerenciar pagamentos
  - Lista de pendentes
  - Calendário de vencimentos
  - Estatísticas detalhadas

### Widgets:
- 📝 Criar `payment_status_badge.dart`:
  - Widget para mostrar status (Paga/Pendente/Atrasada)
  - Cores dinâmicas

- 📝 Criar `payment_card.dart`:
  - Card resumo de pagamentos

---

## 🚀 Próximos Passos:

1. ✅ Executar SQL no Supabase
2. Atualizar TransactionService
3. Modificar formulário de adição
4. Adicionar filtros na home
5. Criar dashboard de pagamentos
6. Implementar notificações

---

## 📊 Estatísticas Disponíveis:

```dart
// Exemplo de uso da função SQL:
final stats = await getPaymentStatistics(
  userId: 'uuid',
  month: 2,
  year: 2026,
);

print('Total: R\$ ${stats.totalDespesas}');
print('Pagas: R\$ ${stats.despesasPagas}');
print('Pendentes: R\$ ${stats.despesasPendentes}');
print('Atrasadas: R\$ ${stats.despesasAtrasadas}');
```

---

## 🎯 Benefícios:

✅ Controle total sobre contas a pagar
✅ Nunca esquecer vencimentos
✅ Visualização clara do status financeiro
✅ Planejamento de caixa
✅ Evitar juros e multas por atraso
✅ Dashboard intuitivo e visual
✅ Filtros para foco no que importa

---

**Status**: ⏳ Aguardando execução do SQL e implementação no Flutter
