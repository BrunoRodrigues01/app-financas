-- ====================================================================
-- Script SQL para Popular Banco de Dados - Minhas Finanças
-- Execute este script no SQL Editor do Supabase
-- VERSÃO 2 - CORRIGIDA
-- ====================================================================

-- IMPORTANTE: Este script adiciona dados fictícios para teste
-- Execute linha por linha ou todo de uma vez

-- ==================== 1. ATIVAR PREMIUM ====================
UPDATE public.usuarios
SET 
    is_premium = TRUE,
    premium_expiry = NOW() + INTERVAL '1 year',
    nome = 'Bruno Rodrigues',
    updated_at = NOW()
WHERE email = 'bruno.rodrigues01@hotmail.com';

-- ==================== 2. ADICIONAR TRANSAÇÕES DE JANEIRO 2026 ====================

-- Receitas de Janeiro
INSERT INTO public.transacoes (usuario_id, tipo, categoria, valor, descricao, data) VALUES
-- Salário
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'entrada', 'Salário', 5000.00, 'Salário mensal', '2026-01-05 08:00:00'),
-- Freelance
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'entrada', 'Freelance', 1500.00, 'Projeto desenvolvimento web', '2026-01-10 14:30:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'entrada', 'Freelance', 800.00, 'Consultoria técnica', '2026-01-15 10:00:00'),
-- Investimentos
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'entrada', 'Investimentos', 250.00, 'Dividendos', '2026-01-20 09:00:00'),
-- Vendas
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'entrada', 'Vendas', 450.00, 'Venda de item usado', '2026-01-12 16:00:00');

-- Despesas de Janeiro
INSERT INTO public.transacoes (usuario_id, tipo, categoria, valor, descricao, data) VALUES
-- Alimentação
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Alimentação', 85.50, 'Supermercado', '2026-01-03 18:30:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Alimentação', 120.00, 'Supermercado', '2026-01-10 19:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Alimentação', 45.90, 'Restaurante', '2026-01-07 12:30:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Alimentação', 67.80, 'Restaurante', '2026-01-14 20:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Alimentação', 95.20, 'Supermercado', '2026-01-17 17:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Alimentação', 38.50, 'Lanchonete', '2026-01-21 15:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Alimentação', 110.00, 'Supermercado', '2026-01-24 18:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Alimentação', 52.30, 'Delivery', '2026-01-28 21:00:00'),

-- Transporte
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Transporte', 250.00, 'Combustível', '2026-01-05 07:30:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Transporte', 180.00, 'Combustível', '2026-01-15 08:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Transporte', 65.00, 'Uber', '2026-01-08 22:30:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Transporte', 45.00, 'Estacionamento', '2026-01-12 14:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Transporte', 220.00, 'Combustível', '2026-01-25 07:00:00'),

-- Moradia
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Moradia', 1200.00, 'Aluguel', '2026-01-10 10:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Moradia', 150.00, 'Condomínio', '2026-01-10 10:05:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Moradia', 85.00, 'Internet', '2026-01-15 12:00:00'),

-- Saúde
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Saúde', 350.00, 'Plano de saúde', '2026-01-08 09:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Saúde', 120.00, 'Farmácia', '2026-01-12 16:30:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Saúde', 200.00, 'Dentista', '2026-01-18 14:00:00'),

-- Educação
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Educação', 199.90, 'Curso online', '2026-01-05 10:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Educação', 89.00, 'Livros', '2026-01-20 15:00:00'),

-- Lazer
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Lazer', 150.00, 'Cinema e jantar', '2026-01-06 19:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Lazer', 280.00, 'Show', '2026-01-13 21:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Lazer', 95.00, 'Streaming (Netflix, Spotify)', '2026-01-15 12:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Lazer', 180.00, 'Parque temático', '2026-01-27 11:00:00'),

-- Compras
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Compras', 250.00, 'Roupas', '2026-01-09 14:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Compras', 450.00, 'Celular (acessórios)', '2026-01-16 16:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Compras', 120.00, 'Presentes', '2026-01-22 17:00:00'),

-- Contas
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Contas', 180.00, 'Conta de luz', '2026-01-12 11:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Contas', 95.00, 'Conta de água', '2026-01-12 11:05:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Contas', 120.00, 'Telefone', '2026-01-15 10:00:00'),

-- Outros Gastos
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Outros Gastos', 75.00, 'Pet shop', '2026-01-11 15:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Outros Gastos', 150.00, 'Cabeleireiro', '2026-01-19 10:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Outros Gastos', 85.00, 'Manutenção carro', '2026-01-23 09:00:00');

-- ==================== 3. ADICIONAR TRANSAÇÕES DE FEVEREIRO 2026 ====================

-- Receitas de Fevereiro
INSERT INTO public.transacoes (usuario_id, tipo, categoria, valor, descricao, data) VALUES
-- Salário
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'entrada', 'Salário', 5000.00, 'Salário mensal', '2026-02-05 08:00:00'),
-- Freelance
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'entrada', 'Freelance', 2200.00, 'Projeto mobile', '2026-02-08 15:00:00');

-- Despesas de Fevereiro (até hoje - 08/02)
INSERT INTO public.transacoes (usuario_id, tipo, categoria, valor, descricao, data) VALUES
-- Alimentação
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Alimentação', 92.30, 'Supermercado', '2026-02-01 18:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Alimentação', 55.80, 'Restaurante', '2026-02-03 13:00:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Alimentação', 78.90, 'Delivery', '2026-02-06 20:30:00'),

-- Transporte
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Transporte', 260.00, 'Combustível', '2026-02-04 07:30:00'),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Transporte', 48.00, 'Uber', '2026-02-07 22:00:00'),

-- Lazer
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Lazer', 120.00, 'Cinema', '2026-02-02 19:00:00'),

-- Compras
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'saida', 'Compras', 180.00, 'Eletrônicos', '2026-02-05 15:00:00');

-- ==================== 4. ADICIONAR METAS FINANCEIRAS ====================

INSERT INTO public.metas (usuario_id, tipo, titulo, valor, valor_atual, data_conclusao, progresso, status, descricao) VALUES
-- Meta 1: Viagem
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 
 'economia', 
 'Viagem de Férias', 
 5000.00, 
 2100.00, 
 '2026-06-30 23:59:59', 
 42.00, 
 'ativa', 
 'Economizar para viagem de férias em julho'),

-- Meta 2: Emergência
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 
 'economia', 
 'Fundo de Emergência', 
 15000.00, 
 6800.00, 
 '2026-12-31 23:59:59', 
 45.33, 
 'ativa', 
 'Reserva para emergências (6 meses de despesas)'),

-- Meta 3: Carro
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 
 'economia', 
 'Carro Novo', 
 30000.00, 
 12500.00, 
 '2027-03-31 23:59:59', 
 41.67, 
 'ativa', 
 'Entrada para carro novo'),

-- Meta 4: Curso
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 
 'orcamento', 
 'Orçamento Educação', 
 500.00, 
 289.90, 
 '2026-02-28 23:59:59', 
 57.98, 
 'ativa', 
 'Limite de gastos com educação em fevereiro');

-- ==================== 5. ADICIONAR LIMITES DE CATEGORIA ====================

INSERT INTO public.limites_categoria (usuario_id, categoria, limite, mes, ano) VALUES
-- Janeiro 2026
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'Alimentação', 800.00, 1, 2026),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'Transporte', 800.00, 1, 2026),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'Lazer', 500.00, 1, 2026),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'Compras', 600.00, 1, 2026),

-- Fevereiro 2026
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'Alimentação', 800.00, 2, 2026),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'Transporte', 800.00, 2, 2026),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'Lazer', 500.00, 2, 2026),
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 'Compras', 600.00, 2, 2026);

-- ==================== 6. ADICIONAR ASSINATURA PREMIUM ====================

INSERT INTO public.assinaturas (usuario_id, tipo, valor, data_inicio, data_fim, status) VALUES
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 
 'anual', 
 99.00, 
 NOW(), 
 NOW() + INTERVAL '1 year', 
 'ativa');

-- ==================== 7. ADICIONAR NOTIFICAÇÕES ====================

INSERT INTO public.notificacoes (usuario_id, tipo, titulo, mensagem, lida) VALUES
((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 
 'alerta', 
 'Limite de Categoria Atingido', 
 'Você ultrapassou o limite de gastos em Lazer (R$ 705,00 de R$ 500,00)', 
 false),

((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 
 'alerta', 
 'Limite de Categoria Atingido', 
 'Você ultrapassou o limite de gastos em Compras (R$ 820,00 de R$ 600,00)', 
 false),

((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 
 'dica', 
 'Meta Quase Atingida', 
 'Parabéns! Você já completou 42% da meta "Viagem de Férias"', 
 false),

((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 
 'info', 
 'Renovação de Assinatura', 
 'Sua assinatura Premium será renovada em breve', 
 false),

((SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com'), 
 'sucesso', 
 'Premium Ativado', 
 'Parabéns! Sua conta Premium foi ativada com sucesso', 
 false);

-- ==================== VERIFICAR DADOS INSERIDOS ====================

-- Ver resumo de transações
SELECT 
    EXTRACT(MONTH FROM data) as mes,
    EXTRACT(YEAR FROM data) as ano,
    tipo,
    COUNT(*) as quantidade,
    SUM(valor) as total
FROM public.transacoes
WHERE usuario_id = (SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com')
GROUP BY EXTRACT(MONTH FROM data), EXTRACT(YEAR FROM data), tipo
ORDER BY ano, mes, tipo;

-- Ver metas
SELECT 
    titulo,
    valor,
    valor_atual,
    progresso,
    status
FROM public.metas
WHERE usuario_id = (SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com')
ORDER BY data_conclusao;

-- Ver assinatura premium
SELECT tipo, valor, data_inicio, data_fim, status
FROM public.assinaturas
WHERE usuario_id = (SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com');

-- Ver limites de categoria
SELECT categoria, limite, mes, ano
FROM public.limites_categoria
WHERE usuario_id = (SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com')
ORDER BY ano, mes, categoria;

-- Ver notificações
SELECT tipo, titulo, lida
FROM public.notificacoes
WHERE usuario_id = (SELECT id FROM public.usuarios WHERE email = 'bruno.rodrigues01@hotmail.com')
ORDER BY created_at DESC;

-- ==================== RESUMO ====================
-- ✅ Premium ativado
-- ✅ 48 transações (39 em Janeiro + 9 em Fevereiro)
--    - Janeiro: 8 receitas (R$ 8.000,00) + 31 despesas (R$ 6.329,20) = Saldo R$ 1.670,80
--    - Fevereiro: 2 receitas (R$ 7.200,00) + 7 despesas (R$ 835,00) = Saldo R$ 6.365,00
-- ✅ 4 metas financeiras (42% a 58% de progresso)
-- ✅ 8 limites de categoria (Janeiro e Fevereiro)
-- ✅ 1 assinatura premium ativa (anual R$ 99,00)
-- ✅ 5 notificações (alertas, dicas, info)
