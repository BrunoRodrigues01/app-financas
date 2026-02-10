# 🎯 Sistema de Orçamento Mensal

## 📋 Funcionalidades Implementadas

### 1. ✅ Tela de Orçamento (`budget_screen.dart`)
- Definir receita mensal planejada
- Definir orçamento para cada categoria de despesa
- Visualizar resumo (total orçado, saldo disponível, % utilizado)
- Salvar e carregar orçamento do banco de dados
- Selector de mês/ano

### 2. ✅ Service de Orçamento (`budget_service.dart`)
- `getBudgetForMonth()` - Buscar orçamento do mês
- `saveBudget()` - Salvar/atualizar orçamento
- `getBudgetCategories()` - Buscar categorias do orçamento
- `getBudgetProgress()` - Calcular progresso de cada categoria
- `getBudgetSummary()` - Resumo completo do orçamento
- `deleteBudget()` - Deletar orçamento

### 3. ✅ Navegação
- Botão "Orçamento" adicionado nas Ações Rápidas da tela inicial
- Ícone: 💳 (account_balance_wallet)
- Cor: Verde

---

## 🗄️ PASSO OBRIGATÓRIO: Criar Tabelas no Banco de Dados

### 📍 Execute o Script SQL no Supabase:

1. **Acesse o Supabase Dashboard:**
   ```
   https://supabase.com/dashboard/project/qknworthkomsailivgba
   ```

2. **Vá para o SQL Editor:**
   - Menu lateral → **SQL Editor**
   - Ou acesse diretamente:
   ```
   https://supabase.com/dashboard/project/qknworthkomsailivgba/sql
   ```

3. **Execute o Script:**
   - Clique em "**New Query**"
   - Copie todo o conteúdo do arquivo:
     ```
     database/create_budget_tables.sql
     ```
   - Cole no editor
   - Clique em "**Run**" (ou pressione Ctrl+Enter)

4. **Verifique se foi criado com sucesso:**
   - Vá em **Table Editor** no menu lateral
   - Você deve ver as novas tabelas:
     - ✅ `budgets`
     - ✅ `budget_categories`

---

## 📊 Estrutura do Banco de Dados

### Tabela: `budgets`
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| id | UUID | ID único do orçamento |
| user_id | UUID | ID do usuário (FK para auth.users) |
| mes | INTEGER | Mês do orçamento (1-12) |
| ano | INTEGER | Ano do orçamento |
| receita_planejada | NUMERIC | Receita mensal planejada |
| created_at | TIMESTAMP | Data de criação |
| updated_at | TIMESTAMP | Data de atualização |

**Constraint Único:** (user_id, mes, ano) - Um orçamento por mês/ano/usuário

### Tabela: `budget_categories`
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| id | UUID | ID único da categoria |
| budget_id | UUID | ID do orçamento (FK para budgets) |
| categoria | TEXT | Nome da categoria |
| valor_orcado | NUMERIC | Valor orçado para categoria |
| created_at | TIMESTAMP | Data de criação |
| updated_at | TIMESTAMP | Data de atualização |

**Constraint Único:** (budget_id, categoria) - Uma categoria por orçamento

---

## 🚀 Como Usar

### 1. Acessar a Tela de Orçamento:
- Abra o app
- Na tela inicial, clique em "**Orçamento**" (botão verde)

### 2. Definir Orçamento:
1. Selecione o mês/ano (padrão: mês atual)
2. Informe a **Receita Mensal Planejada** (ex: R$ 5.000,00)
3. Defina valores para cada categoria:
   - Alimentação: R$ 800,00
   - Transporte: R$ 400,00
   - Moradia: R$ 1.200,00
   - etc.
4. O sistema mostra automaticamente:
   - **Total Orçado** (soma das categorias)
   - **Saldo Disponível** (receita - total orçado)
   - **% Orçamento Utilizado**
5. Clique em "**Salvar Orçamento**"

### 3. Visualizar na Tela de Categorias:
⚠️ **PRÓXIMO PASSO** (ainda não implementado):
- Ir para Categorias
- Ver comparativo: Orçado vs Gasto
- Barras de progresso por categoria
- Indicadores de status (verde/amarelo/vermelho)

---

## 🎨 Visual da Tela de Orçamento

```
┌──────────────────────────────────────┐
│ Orçamento Mensal              [💾]   │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ 📅 Janeiro 2026              [▼]     │
│ Clique para alterar                  │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ 💰 Receita Mensal Planejada          │
│                                      │
│ R$ [_____5000.00_________________]   │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ 📊 Resumo do Orçamento               │
│                                      │
│ Total Orçado        R$ 3.200,00      │
│ Saldo Disponível    R$ 1.800,00      │
│ ──────────────────────────────       │
│ Orçamento utilizado      64%         │
│ ▓▓▓▓▓▓▓▓░░░░░░░░                    │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ 📁 Orçamento por Categoria           │
│ Defina quanto quer gastar            │
│                                      │
│ Alimentação                          │
│ R$ [____800.00___________________]   │
│                                      │
│ Transporte                           │
│ R$ [____400.00___________________]   │
│                                      │
│ Moradia                              │
│ R$ [___1200.00___________________]   │
│                                      │
│ ... (mais categorias)                │
└──────────────────────────────────────┘

         [💾 Salvar Orçamento]
```

---

## ✅ Checklist de Implementação

- [x] Criar script SQL (`create_budget_tables.sql`)
- [x] Criar service (`budget_service.dart`)
- [x] Criar tela de orçamento (`budget_screen.dart`)
- [x] Adicionar navegação no `home_screen.dart`
- [x] Validações e tratamento de erros
- [x] Interface responsiva
- [x] Formatação de moeda (pt_BR)
- [x] Cálculos automáticos (total, saldo, %)
- [ ] **PENDENTE**: Integrar na tela de categorias
- [ ] **PENDENTE**: Mostrar comparativo orçado vs gasto
- [ ] **PENDENTE**: Barras de progresso
- [ ] **PENDENTE**: Alertas quando estourar orçamento

---

## 🔒 Segurança (RLS)

✅ **Row Level Security (RLS) Configurado:**
- Usuários só veem seus próprios orçamentos
- Políticas para SELECT, INSERT, UPDATE, DELETE
- Proteção em nível de banco de dados

---

## 📝 Próximos Passos

### Etapa 2: Integração com Tela de Categorias

Modificar `categories_screen.dart` para mostrar:

```dart
Widget _buildCategoryCard(String category, double spent) {
  final budget = budgetCategories[category] ?? 0.0;
  final percentage = budget > 0 ? (spent / budget * 100) : 0.0;
  final status = percentage > 100 ? 'exceeded' 
                : percentage > 80 ? 'warning'
                : 'ok';
  
  return Card(
    child: Column(
      children: [
        Text('$category: ${_formatCurrency(spent)}'),
        Text('Orçado: ${_formatCurrency(budget)}'),
        LinearProgressIndicator(
          value: (percentage / 100).clamp(0.0, 1.0),
          color: status == 'ok' ? Colors.green
                : status == 'warning' ? Colors.yellow
                : Colors.red,
        ),
        Text('${percentage.toStringAsFixed(0)}%'),
      ],
    ),
  );
}
```

---

## 🎯 Exemplo de Uso Completo

1. **Usuário define orçamento:**
   - Receita: R$ 5.000
   - Alimentação: R$ 800
   - Transporte: R$ 400
   - Moradia: R$ 1.200
   - Lazer: R$ 300

2. **Durante o mês, registra despesas:**
   - Alimentação: R$ 650 ✅ (81% - dentro do orçamento)
   - Transporte: R$ 450 ⚠️ (113% - estourou!)
   - Moradia: R$ 1.200 ✅ (100% - no limite)
   - Lazer: R$ 150 ✅ (50% - sobrando)

3. **Na tela de categorias vê:**
   ```
   🍔 Alimentação
   Gasto: R$ 650  |  Orçado: R$ 800
   ▓▓▓▓▓▓▓▓░░ 81% ✅
   Sobra: R$ 150
   
   🚗 Transporte  
   Gasto: R$ 450  |  Orçado: R$ 400
   ▓▓▓▓▓▓▓▓▓▓▓ 113% ⚠️
   Excedeu: R$ 50
   ```

---

## 🐛 Troubleshooting

### Erro: "Tabelas não encontradas"
✅ **Solução:** Execute o script SQL no Supabase

### Erro: "Permission denied"
✅ **Solução:** Verifique se o RLS está configurado corretamente

### Erro: "Failed to load budget"
✅ **Solução:** Verifique se o usuário está autenticado

---

## 📚 Documentação Técnica

- **Service:** `lib/services/budget_service.dart`
- **Screen:** `lib/screens/budget_screen.dart`
- **SQL:** `database/create_budget_tables.sql`

---

**Desenvolvido em:** Fevereiro de 2026  
**Status:** ✅ Funcional (aguardando integração com categorias)  
**Tecnologia:** Flutter + Supabase PostgreSQL
