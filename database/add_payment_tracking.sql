-- ============================================================
-- SISTEMA DE CONTROLE DE PAGAMENTOS
-- ============================================================
-- Criado em: 09/02/2026
-- Descrição: Adiciona campos para rastrear status de pagamento
--            e data de vencimento das transações
-- ============================================================

-- Adicionar novas colunas na tabela transacoes
ALTER TABLE transacoes 
ADD COLUMN IF NOT EXISTS pago BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS data_vencimento DATE,
ADD COLUMN IF NOT EXISTS data_pagamento DATE;

-- Criar índices para melhor performance nas consultas
CREATE INDEX IF NOT EXISTS idx_transacoes_pago ON transacoes(pago);
CREATE INDEX IF NOT EXISTS idx_transacoes_data_vencimento ON transacoes(data_vencimento);
CREATE INDEX IF NOT EXISTS idx_transacoes_pago_vencimento ON transacoes(pago, data_vencimento) WHERE tipo = 'saida';

-- Comentários das novas colunas
COMMENT ON COLUMN transacoes.pago IS 'Indica se a despesa foi paga (true) ou está pendente (false)';
COMMENT ON COLUMN transacoes.data_vencimento IS 'Data de vencimento da despesa (opcional)';
COMMENT ON COLUMN transacoes.data_pagamento IS 'Data em que a despesa foi efetivamente paga (opcional)';

-- ============================================================
-- ATUALIZAÇÃO DE DADOS EXISTENTES
-- ============================================================

-- Marcar todas as transações existentes como pagas por padrão
-- (assumindo que transações já registradas foram pagas)
UPDATE transacoes 
SET pago = true, 
    data_pagamento = data 
WHERE pago IS NULL;

-- ============================================================
-- FUNÇÃO PARA BUSCAR DESPESAS PENDENTES
-- ============================================================

-- View para despesas pendentes (facilitará as consultas)
CREATE OR REPLACE VIEW despesas_pendentes AS
SELECT 
    t.*,
    CASE 
        WHEN t.data_vencimento IS NULL THEN 'sem_vencimento'
        WHEN t.data_vencimento < CURRENT_DATE THEN 'atrasada'
        WHEN t.data_vencimento = CURRENT_DATE THEN 'vence_hoje'
        WHEN t.data_vencimento <= CURRENT_DATE + INTERVAL '3 days' THEN 'vence_em_breve'
        ELSE 'no_prazo'
    END AS status_vencimento,
    CASE 
        WHEN t.data_vencimento IS NOT NULL THEN 
            t.data_vencimento - CURRENT_DATE
        ELSE NULL
    END AS dias_ate_vencimento
FROM transacoes t
WHERE t.tipo = 'saida' 
  AND t.pago = false
ORDER BY 
    CASE 
        WHEN t.data_vencimento IS NULL THEN 9999
        ELSE (t.data_vencimento - CURRENT_DATE)
    END;

-- Comentário da view
COMMENT ON VIEW despesas_pendentes IS 'Lista todas as despesas não pagas com status de vencimento calculado';

-- ============================================================
-- FUNÇÃO PARA MARCAR COMO PAGO
-- ============================================================

CREATE OR REPLACE FUNCTION marcar_como_pago(
    transaction_id UUID,
    payment_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- Verificar se a transação existe e é uma despesa
    IF NOT EXISTS (
        SELECT 1 FROM transacoes 
        WHERE id = transaction_id 
        AND tipo = 'saida'
    ) THEN
        RETURN QUERY SELECT false, 'Transação não encontrada ou não é uma despesa'::TEXT;
        RETURN;
    END IF;
    
    -- Atualizar o status de pagamento
    UPDATE transacoes 
    SET pago = true,
        data_pagamento = payment_date,
        updated_at = NOW()
    WHERE id = transaction_id;
    
    RETURN QUERY SELECT true, 'Despesa marcada como paga com sucesso'::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION marcar_como_pago IS 'Marca uma despesa como paga e registra a data de pagamento';

-- ============================================================
-- FUNÇÃO PARA DESMARCAR PAGAMENTO
-- ============================================================

CREATE OR REPLACE FUNCTION desmarcar_pagamento(
    transaction_id UUID
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- Verificar se a transação existe
    IF NOT EXISTS (
        SELECT 1 FROM transacoes 
        WHERE id = transaction_id
    ) THEN
        RETURN QUERY SELECT false, 'Transação não encontrada'::TEXT;
        RETURN;
    END IF;
    
    -- Reverter o status de pagamento
    UPDATE transacoes 
    SET pago = false,
        data_pagamento = NULL,
        updated_at = NOW()
    WHERE id = transaction_id;
    
    RETURN QUERY SELECT true, 'Status de pagamento revertido'::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION desmarcar_pagamento IS 'Remove a marcação de pago de uma transação';

-- ============================================================
-- ESTATÍSTICAS DE PAGAMENTO
-- ============================================================

CREATE OR REPLACE FUNCTION get_payment_statistics(
    user_uuid UUID,
    target_month INTEGER,
    target_year INTEGER
)
RETURNS TABLE (
    total_despesas NUMERIC,
    despesas_pagas NUMERIC,
    despesas_pendentes NUMERIC,
    despesas_atrasadas NUMERIC,
    quantidade_total INTEGER,
    quantidade_pagas INTEGER,
    quantidade_pendentes INTEGER,
    quantidade_atrasadas INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(SUM(valor), 0) as total_despesas,
        COALESCE(SUM(CASE WHEN pago = true THEN valor ELSE 0 END), 0) as despesas_pagas,
        COALESCE(SUM(CASE WHEN pago = false THEN valor ELSE 0 END), 0) as despesas_pendentes,
        COALESCE(SUM(CASE WHEN pago = false AND data_vencimento < CURRENT_DATE THEN valor ELSE 0 END), 0) as despesas_atrasadas,
        COUNT(*)::INTEGER as quantidade_total,
        COUNT(*) FILTER (WHERE pago = true)::INTEGER as quantidade_pagas,
        COUNT(*) FILTER (WHERE pago = false)::INTEGER as quantidade_pendentes,
        COUNT(*) FILTER (WHERE pago = false AND data_vencimento < CURRENT_DATE)::INTEGER as quantidade_atrasadas
    FROM transacoes
    WHERE user_id = user_uuid
      AND tipo = 'saida'
      AND EXTRACT(MONTH FROM data) = target_month
      AND EXTRACT(YEAR FROM data) = target_year;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_payment_statistics IS 'Retorna estatísticas completas sobre pagamentos do mês';

-- ============================================================
-- REGRAS DE SEGURANÇA (RLS)
-- ============================================================

-- As políticas RLS já existentes na tabela transacoes automaticamente
-- aplicam-se às novas colunas. Não é necessário criar novas políticas.

-- ============================================================
-- CONCLUÍDO!
-- ============================================================
-- Execute este script no SQL Editor do Supabase
-- As transações existentes serão marcadas como pagas por padrão
-- Novas despesas poderão ter status de pagamento e data de vencimento
-- ============================================================
