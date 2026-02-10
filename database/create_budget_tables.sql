-- ============================================================
-- TABELAS DE ORÇAMENTO
-- ============================================================
-- Criado em: 09/02/2026
-- Descrição: Tabelas para gerenciar orçamentos mensais por categoria
-- ============================================================

-- Tabela principal de orçamentos (um por mês/ano/usuário)
CREATE TABLE IF NOT EXISTS budgets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    mes INTEGER NOT NULL CHECK (mes >= 1 AND mes <= 12),
    ano INTEGER NOT NULL CHECK (ano >= 2020 AND ano <= 2100),
    receita_planejada NUMERIC(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Garantir um orçamento único por mês/ano/usuário
    UNIQUE(user_id, mes, ano)
);

-- Tabela de categorias do orçamento
CREATE TABLE IF NOT EXISTS budget_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    budget_id UUID NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
    categoria TEXT NOT NULL,
    valor_orcado NUMERIC(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Garantir uma categoria única por orçamento
    UNIQUE(budget_id, categoria)
);

-- ============================================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_budgets_user_id ON budgets(user_id);
CREATE INDEX IF NOT EXISTS idx_budgets_mes_ano ON budgets(mes, ano);
CREATE INDEX IF NOT EXISTS idx_budget_categories_budget_id ON budget_categories(budget_id);
CREATE INDEX IF NOT EXISTS idx_budget_categories_categoria ON budget_categories(categoria);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

-- Habilitar RLS nas tabelas
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget_categories ENABLE ROW LEVEL SECURITY;

-- Políticas para budgets
DROP POLICY IF EXISTS "Usuários podem ver seus próprios orçamentos" ON budgets;
CREATE POLICY "Usuários podem ver seus próprios orçamentos"
    ON budgets FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem criar seus próprios orçamentos" ON budgets;
CREATE POLICY "Usuários podem criar seus próprios orçamentos"
    ON budgets FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios orçamentos" ON budgets;
CREATE POLICY "Usuários podem atualizar seus próprios orçamentos"
    ON budgets FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem deletar seus próprios orçamentos" ON budgets;
CREATE POLICY "Usuários podem deletar seus próprios orçamentos"
    ON budgets FOR DELETE
    USING (auth.uid() = user_id);

-- Políticas para budget_categories
DROP POLICY IF EXISTS "Usuários podem ver categorias de seus orçamentos" ON budget_categories;
CREATE POLICY "Usuários podem ver categorias de seus orçamentos"
    ON budget_categories FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM budgets
            WHERE budgets.id = budget_categories.budget_id
            AND budgets.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Usuários podem criar categorias em seus orçamentos" ON budget_categories;
CREATE POLICY "Usuários podem criar categorias em seus orçamentos"
    ON budget_categories FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM budgets
            WHERE budgets.id = budget_categories.budget_id
            AND budgets.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Usuários podem atualizar categorias de seus orçamentos" ON budget_categories;
CREATE POLICY "Usuários podem atualizar categorias de seus orçamentos"
    ON budget_categories FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM budgets
            WHERE budgets.id = budget_categories.budget_id
            AND budgets.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Usuários podem deletar categorias de seus orçamentos" ON budget_categories;
CREATE POLICY "Usuários podem deletar categorias de seus orçamentos"
    ON budget_categories FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM budgets
            WHERE budgets.id = budget_categories.budget_id
            AND budgets.user_id = auth.uid()
        )
    );

-- ============================================================
-- FUNÇÃO PARA ATUALIZAR updated_at AUTOMATICAMENTE
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para atualizar updated_at
DROP TRIGGER IF EXISTS update_budgets_updated_at ON budgets;
CREATE TRIGGER update_budgets_updated_at
    BEFORE UPDATE ON budgets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_budget_categories_updated_at ON budget_categories;
CREATE TRIGGER update_budget_categories_updated_at
    BEFORE UPDATE ON budget_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- COMENTÁRIOS DAS TABELAS
-- ============================================================

COMMENT ON TABLE budgets IS 'Orçamentos mensais dos usuários';
COMMENT ON COLUMN budgets.user_id IS 'ID do usuário (referência para auth.users)';
COMMENT ON COLUMN budgets.mes IS 'Mês do orçamento (1-12)';
COMMENT ON COLUMN budgets.ano IS 'Ano do orçamento';
COMMENT ON COLUMN budgets.receita_planejada IS 'Receita mensal planejada pelo usuário';

COMMENT ON TABLE budget_categories IS 'Categorias de despesas do orçamento';
COMMENT ON COLUMN budget_categories.budget_id IS 'ID do orçamento (referência para budgets)';
COMMENT ON COLUMN budget_categories.categoria IS 'Nome da categoria (Alimentação, Transporte, etc.)';
COMMENT ON COLUMN budget_categories.valor_orcado IS 'Valor orçado para esta categoria';

-- ============================================================
-- CONCLUÍDO!
-- ============================================================
-- Execute este script no SQL Editor do Supabase
-- Acesse: https://supabase.com/dashboard/project/[seu-projeto]/editor
-- ============================================================
