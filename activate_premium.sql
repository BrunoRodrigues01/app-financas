-- ====================================================================
-- Script SQL para Ativar Premium - Minhas Finanças
-- Execute este script no SQL Editor do Supabase
-- ====================================================================

-- IMPORTANTE: Substitua o email pelo email do usuário que deseja ativar o premium
-- Ou descomente a opção de ativar para TODOS os usuários

-- ==================== OPÇÃO 1: Ativar Premium para um usuário específico ====================
-- Substitua 'bruno.rodrigues01@hotmail.com' pelo email do usuário
UPDATE public.usuarios
SET 
    is_premium = TRUE,
    premium_expiry = NOW() + INTERVAL '1 year',  -- Premium válido por 1 ano
    updated_at = NOW()
WHERE email = 'bruno.rodrigues01@hotmail.com';

-- ==================== OPÇÃO 2: Ativar Premium para TODOS os usuários ====================
-- CUIDADO: Isso vai ativar premium para todos os usuários cadastrados!
-- Descomente as linhas abaixo se quiser ativar para todos:

/*
UPDATE public.usuarios
SET 
    is_premium = TRUE,
    premium_expiry = NOW() + INTERVAL '1 year',
    updated_at = NOW();
*/

-- ==================== OPÇÃO 3: Ativar Premium por ID do usuário ====================
-- Se você souber o ID do usuário, pode usar:

/*
UPDATE public.usuarios
SET 
    is_premium = TRUE,
    premium_expiry = NOW() + INTERVAL '1 year',
    updated_at = NOW()
WHERE id = 'SEU-UUID-AQUI';
*/

-- ==================== VERIFICAR STATUS PREMIUM ====================
-- Execute esta query para ver todos os usuários e seu status premium:
SELECT 
    id,
    email,
    nome,
    is_premium,
    premium_expiry,
    CASE 
        WHEN is_premium = TRUE AND (premium_expiry IS NULL OR premium_expiry > NOW()) 
        THEN '✅ Premium Ativo'
        WHEN is_premium = TRUE AND premium_expiry < NOW() 
        THEN '⚠️ Premium Expirado'
        ELSE '❌ Gratuito'
    END as status
FROM public.usuarios
ORDER BY created_at DESC;

-- ==================== DESATIVAR PREMIUM ====================
-- Se precisar remover o premium de um usuário:

/*
UPDATE public.usuarios
SET 
    is_premium = FALSE,
    premium_expiry = NULL,
    updated_at = NOW()
WHERE email = 'usuario@email.com';
*/

-- ==================== EXTENDER VALIDADE DO PREMIUM ====================
-- Adicionar mais tempo ao premium existente:

/*
UPDATE public.usuarios
SET 
    premium_expiry = premium_expiry + INTERVAL '1 month',  -- Adiciona 1 mês
    updated_at = NOW()
WHERE email = 'usuario@email.com';
*/

-- ==================== NOTAS ====================
-- * is_premium = TRUE/FALSE (ativa/desativa o premium)
-- * premium_expiry = Data de expiração (NULL = sem expiração)
-- * Intervalos disponíveis: '1 day', '1 week', '1 month', '1 year'
-- * O aplicativo verifica automaticamente se o premium está ativo
