-- ====================================================================
-- Script SQL para criar as tabelas no Supabase - Minhas Finanças
-- Execute este script no SQL Editor do Supabase
-- ====================================================================

-- ==================== TABELA DE USUÁRIOS (PERFIS) ====================
-- Esta tabela estende a tabela auth.users do Supabase
CREATE TABLE IF NOT EXISTS public.usuarios (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    nome TEXT NOT NULL,
    avatar_url TEXT,
    saldo_atual DECIMAL(10, 2) DEFAULT 0 NOT NULL,
    is_premium BOOLEAN DEFAULT FALSE NOT NULL,
    premium_expiry TIMESTAMP WITH TIME ZONE,
    notificacoes_ativadas BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==================== TABELA DE TRANSAÇÕES ====================
CREATE TABLE IF NOT EXISTS public.transacoes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES public.usuarios(id) ON DELETE CASCADE NOT NULL,
    tipo TEXT NOT NULL CHECK (tipo IN ('entrada', 'saida')),
    categoria TEXT NOT NULL,
    valor DECIMAL(10, 2) NOT NULL CHECK (valor > 0),
    descricao TEXT,
    data TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==================== TABELA DE METAS ====================
CREATE TABLE IF NOT EXISTS public.metas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES public.usuarios(id) ON DELETE CASCADE NOT NULL,
    tipo TEXT NOT NULL, -- 'economia', 'orcamento', etc
    titulo TEXT NOT NULL,
    valor DECIMAL(10, 2) NOT NULL CHECK (valor > 0),
    valor_atual DECIMAL(10, 2) DEFAULT 0 NOT NULL,
    data_conclusao TIMESTAMP WITH TIME ZONE NOT NULL,
    progresso DECIMAL(5, 2) DEFAULT 0 NOT NULL CHECK (progresso >= 0 AND progresso <= 100),
    status TEXT DEFAULT 'ativa' CHECK (status IN ('ativa', 'concluida', 'cancelada')),
    descricao TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==================== TABELA DE NOTIFICAÇÕES ====================
CREATE TABLE IF NOT EXISTS public.notificacoes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES public.usuarios(id) ON DELETE CASCADE NOT NULL,
    tipo TEXT NOT NULL, -- 'alerta', 'lembrete', 'meta_atingida', etc
    titulo TEXT NOT NULL,
    mensagem TEXT NOT NULL,
    lida BOOLEAN DEFAULT FALSE NOT NULL,
    data TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==================== TABELA DE LIMITES DE GASTOS POR CATEGORIA ====================
CREATE TABLE IF NOT EXISTS public.limites_categoria (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES public.usuarios(id) ON DELETE CASCADE NOT NULL,
    categoria TEXT NOT NULL,
    limite DECIMAL(10, 2) NOT NULL CHECK (limite > 0),
    mes INTEGER NOT NULL CHECK (mes >= 1 AND mes <= 12),
    ano INTEGER NOT NULL CHECK (ano >= 2020),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(usuario_id, categoria, mes, ano)
);

-- ==================== TABELA DE ASSINATURAS PREMIUM ====================
CREATE TABLE IF NOT EXISTS public.assinaturas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES public.usuarios(id) ON DELETE CASCADE NOT NULL,
    tipo TEXT NOT NULL CHECK (tipo IN ('mensal', 'anual')),
    valor DECIMAL(10, 2) NOT NULL,
    data_inicio TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    data_fim TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT DEFAULT 'ativa' CHECK (status IN ('ativa', 'cancelada', 'expirada')),
    payment_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==================== ÍNDICES PARA PERFORMANCE ====================
-- Índices para tabela de transações
CREATE INDEX IF NOT EXISTS transacoes_usuario_id_idx ON public.transacoes(usuario_id);
CREATE INDEX IF NOT EXISTS transacoes_data_idx ON public.transacoes(data DESC);
CREATE INDEX IF NOT EXISTS transacoes_tipo_idx ON public.transacoes(tipo);
CREATE INDEX IF NOT EXISTS transacoes_categoria_idx ON public.transacoes(categoria);
CREATE INDEX IF NOT EXISTS transacoes_usuario_data_idx ON public.transacoes(usuario_id, data DESC);

-- Índices para tabela de metas
CREATE INDEX IF NOT EXISTS metas_usuario_id_idx ON public.metas(usuario_id);
CREATE INDEX IF NOT EXISTS metas_status_idx ON public.metas(status);
CREATE INDEX IF NOT EXISTS metas_data_conclusao_idx ON public.metas(data_conclusao);

-- Índices para tabela de notificações
CREATE INDEX IF NOT EXISTS notificacoes_usuario_id_idx ON public.notificacoes(usuario_id);
CREATE INDEX IF NOT EXISTS notificacoes_lida_idx ON public.notificacoes(lida);
CREATE INDEX IF NOT EXISTS notificacoes_data_idx ON public.notificacoes(data DESC);

-- Índices para tabela de limites
CREATE INDEX IF NOT EXISTS limites_usuario_id_idx ON public.limites_categoria(usuario_id);

-- Índices para tabela de assinaturas
CREATE INDEX IF NOT EXISTS assinaturas_usuario_id_idx ON public.assinaturas(usuario_id);
CREATE INDEX IF NOT EXISTS assinaturas_status_idx ON public.assinaturas(status);

-- ==================== ROW LEVEL SECURITY (RLS) ====================
-- Garantir que cada usuário acesse apenas seus próprios dados

-- Habilitar RLS em todas as tabelas
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.metas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notificacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.limites_categoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assinaturas ENABLE ROW LEVEL SECURITY;

-- ==================== POLÍTICAS DE SEGURANÇA (RLS) ====================

-- Políticas para USUARIOS
CREATE POLICY "Usuários podem ver seu próprio perfil"
    ON public.usuarios FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Usuários podem atualizar seu próprio perfil"
    ON public.usuarios FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Usuários podem inserir seu próprio perfil"
    ON public.usuarios FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Políticas para TRANSACOES
CREATE POLICY "Usuários podem ver suas próprias transações"
    ON public.transacoes FOR SELECT
    USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar suas próprias transações"
    ON public.transacoes FOR INSERT
    WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar suas próprias transações"
    ON public.transacoes FOR UPDATE
    USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem deletar suas próprias transações"
    ON public.transacoes FOR DELETE
    USING (auth.uid() = usuario_id);

-- Políticas para METAS
CREATE POLICY "Usuários podem ver suas próprias metas"
    ON public.metas FOR SELECT
    USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar suas próprias metas"
    ON public.metas FOR INSERT
    WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar suas próprias metas"
    ON public.metas FOR UPDATE
    USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem deletar suas próprias metas"
    ON public.metas FOR DELETE
    USING (auth.uid() = usuario_id);

-- Políticas para NOTIFICACOES
CREATE POLICY "Usuários podem ver suas próprias notificações"
    ON public.notificacoes FOR SELECT
    USING (auth.uid() = usuario_id);

CREATE POLICY "Sistema pode criar notificações"
    ON public.notificacoes FOR INSERT
    WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar suas notificações"
    ON public.notificacoes FOR UPDATE
    USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem deletar suas notificações"
    ON public.notificacoes FOR DELETE
    USING (auth.uid() = usuario_id);

-- Políticas para LIMITES_CATEGORIA
CREATE POLICY "Usuários podem ver seus próprios limites"
    ON public.limites_categoria FOR SELECT
    USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar seus próprios limites"
    ON public.limites_categoria FOR INSERT
    WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar seus próprios limites"
    ON public.limites_categoria FOR UPDATE
    USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem deletar seus próprios limites"
    ON public.limites_categoria FOR DELETE
    USING (auth.uid() = usuario_id);

-- Políticas para ASSINATURAS
CREATE POLICY "Usuários podem ver suas próprias assinaturas"
    ON public.assinaturas FOR SELECT
    USING (auth.uid() = usuario_id);

CREATE POLICY "Sistema pode criar assinaturas"
    ON public.assinaturas FOR INSERT
    WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Sistema pode atualizar assinaturas"
    ON public.assinaturas FOR UPDATE
    USING (auth.uid() = usuario_id);

-- ==================== FUNÇÕES E TRIGGERS ====================

-- Função para atualizar o campo updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para atualizar o saldo do usuário após transação
CREATE OR REPLACE FUNCTION public.atualizar_saldo_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.tipo = 'entrada' THEN
            UPDATE public.usuarios 
            SET saldo_atual = saldo_atual + NEW.valor
            WHERE id = NEW.usuario_id;
        ELSIF NEW.tipo = 'saida' THEN
            UPDATE public.usuarios 
            SET saldo_atual = saldo_atual - NEW.valor
            WHERE id = NEW.usuario_id;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Reverter transação antiga
        IF OLD.tipo = 'entrada' THEN
            UPDATE public.usuarios 
            SET saldo_atual = saldo_atual - OLD.valor
            WHERE id = OLD.usuario_id;
        ELSIF OLD.tipo = 'saida' THEN
            UPDATE public.usuarios 
            SET saldo_atual = saldo_atual + OLD.valor
            WHERE id = OLD.usuario_id;
        END IF;
        -- Aplicar nova transação
        IF NEW.tipo = 'entrada' THEN
            UPDATE public.usuarios 
            SET saldo_atual = saldo_atual + NEW.valor
            WHERE id = NEW.usuario_id;
        ELSIF NEW.tipo = 'saida' THEN
            UPDATE public.usuarios 
            SET saldo_atual = saldo_atual - NEW.valor
            WHERE id = NEW.usuario_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        -- Reverter transação deletada
        IF OLD.tipo = 'entrada' THEN
            UPDATE public.usuarios 
            SET saldo_atual = saldo_atual - OLD.valor
            WHERE id = OLD.usuario_id;
        ELSIF OLD.tipo = 'saida' THEN
            UPDATE public.usuarios 
            SET saldo_atual = saldo_atual + OLD.valor
            WHERE id = OLD.usuario_id;
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Função para atualizar progresso da meta
CREATE OR REPLACE FUNCTION public.atualizar_progresso_meta()
RETURNS TRIGGER AS $$
BEGIN
    NEW.progresso = LEAST(100, (NEW.valor_atual / NEW.valor * 100));
    
    -- Atualizar status se atingiu a meta
    IF NEW.progresso >= 100 THEN
        NEW.status = 'concluida';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para verificar limites de categoria
CREATE OR REPLACE FUNCTION public.verificar_limite_categoria()
RETURNS TRIGGER AS $$
DECLARE
    limite_valor DECIMAL(10, 2);
    gasto_atual DECIMAL(10, 2);
    mes_atual INTEGER;
    ano_atual INTEGER;
BEGIN
    IF NEW.tipo = 'saida' THEN
        mes_atual := EXTRACT(MONTH FROM NEW.data);
        ano_atual := EXTRACT(YEAR FROM NEW.data);
        
        -- Buscar limite da categoria
        SELECT limite INTO limite_valor
        FROM public.limites_categoria
        WHERE usuario_id = NEW.usuario_id 
        AND categoria = NEW.categoria
        AND mes = mes_atual
        AND ano = ano_atual;
        
        IF limite_valor IS NOT NULL THEN
            -- Calcular gasto atual
            SELECT COALESCE(SUM(valor), 0) INTO gasto_atual
            FROM public.transacoes
            WHERE usuario_id = NEW.usuario_id
            AND categoria = NEW.categoria
            AND tipo = 'saida'
            AND EXTRACT(MONTH FROM data) = mes_atual
            AND EXTRACT(YEAR FROM data) = ano_atual;
            
            -- Adicionar novo valor
            gasto_atual := gasto_atual + NEW.valor;
            
            -- Verificar se ultrapassou 80% do limite
            IF gasto_atual >= (limite_valor * 0.8) THEN
                INSERT INTO public.notificacoes (usuario_id, tipo, titulo, mensagem)
                VALUES (
                    NEW.usuario_id,
                    'alerta',
                    'Alerta de Gasto',
                    format('Você atingiu %.0f%% do limite de R$ %.2f em %s!', 
                           (gasto_atual / limite_valor * 100), 
                           limite_valor, 
                           NEW.categoria)
                );
            END IF;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para atualizar updated_at automaticamente
CREATE TRIGGER set_updated_at_usuarios
    BEFORE UPDATE ON public.usuarios
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_transacoes
    BEFORE UPDATE ON public.transacoes
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_metas
    BEFORE UPDATE ON public.metas
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_limites
    BEFORE UPDATE ON public.limites_categoria
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_assinaturas
    BEFORE UPDATE ON public.assinaturas
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Trigger para atualizar saldo automaticamente
CREATE TRIGGER trigger_atualizar_saldo
    AFTER INSERT OR UPDATE OR DELETE ON public.transacoes
    FOR EACH ROW
    EXECUTE FUNCTION public.atualizar_saldo_usuario();

-- Trigger para atualizar progresso da meta
CREATE TRIGGER trigger_atualizar_progresso
    BEFORE UPDATE ON public.metas
    FOR EACH ROW
    EXECUTE FUNCTION public.atualizar_progresso_meta();

-- Trigger para verificar limites de categoria
CREATE TRIGGER trigger_verificar_limite
    AFTER INSERT ON public.transacoes
    FOR EACH ROW
    EXECUTE FUNCTION public.verificar_limite_categoria();

-- ==================== FUNÇÃO PARA CRIAR USUÁRIO AUTOMATICAMENTE ====================

-- Função que cria um perfil quando um novo usuário se registra
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.usuarios (id, email, nome, saldo_atual)
    VALUES (
        NEW.id, 
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', 'Usuário'),
        0
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar perfil automaticamente
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ==================== FUNÇÕES ÚTEIS ====================

-- Função para obter estatísticas do mês
CREATE OR REPLACE FUNCTION public.get_estatisticas_mes(
    p_usuario_id UUID,
    p_mes INTEGER DEFAULT NULL,
    p_ano INTEGER DEFAULT NULL
)
RETURNS TABLE(
    total_entradas DECIMAL(10, 2),
    total_saidas DECIMAL(10, 2),
    saldo_mes DECIMAL(10, 2),
    transacoes_count INTEGER
) AS $$
DECLARE
    v_mes INTEGER := COALESCE(p_mes, EXTRACT(MONTH FROM NOW()));
    v_ano INTEGER := COALESCE(p_ano, EXTRACT(YEAR FROM NOW()));
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(SUM(CASE WHEN tipo = 'entrada' THEN valor ELSE 0 END), 0) as total_entradas,
        COALESCE(SUM(CASE WHEN tipo = 'saida' THEN valor ELSE 0 END), 0) as total_saidas,
        COALESCE(SUM(CASE WHEN tipo = 'entrada' THEN valor ELSE -valor END), 0) as saldo_mes,
        COUNT(*)::INTEGER as transacoes_count
    FROM public.transacoes
    WHERE usuario_id = p_usuario_id
    AND EXTRACT(MONTH FROM data) = v_mes
    AND EXTRACT(YEAR FROM data) = v_ano;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar se usuário é premium
CREATE OR REPLACE FUNCTION public.is_usuario_premium(p_usuario_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_is_premium BOOLEAN;
    v_premium_expiry TIMESTAMP WITH TIME ZONE;
BEGIN
    SELECT is_premium, premium_expiry INTO v_is_premium, v_premium_expiry
    FROM public.usuarios
    WHERE id = p_usuario_id;
    
    -- Verificar se é premium e se não expirou
    IF v_is_premium AND (v_premium_expiry IS NULL OR v_premium_expiry > NOW()) THEN
        RETURN TRUE;
    ELSE
        -- Atualizar status se expirou
        IF v_is_premium AND v_premium_expiry <= NOW() THEN
            UPDATE public.usuarios
            SET is_premium = FALSE
            WHERE id = p_usuario_id;
        END IF;
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==================== DADOS DE EXEMPLO (OPCIONAL) ====================
-- Descomente as linhas abaixo se quiser inserir categorias padrão

-- INSERT INTO public.categorias_padrao (nome, tipo, icone) VALUES
-- ('Alimentação', 'saida', 'restaurant'),
-- ('Transporte', 'saida', 'directions_car'),
-- ('Moradia', 'saida', 'home'),
-- ('Saúde', 'saida', 'local_hospital'),
-- ('Educação', 'saida', 'school'),
-- ('Lazer', 'saida', 'movie'),
-- ('Compras', 'saida', 'shopping_bag'),
-- ('Contas', 'saida', 'receipt'),
-- ('Salário', 'entrada', 'work'),
-- ('Freelance', 'entrada', 'laptop'),
-- ('Investimentos', 'entrada', 'trending_up'),
-- ('Presente', 'entrada', 'card_giftcard'),
-- ('Outros', 'both', 'more_horiz')
-- ON CONFLICT DO NOTHING;

-- ==================== FIM DO SCRIPT ====================
-- Execute este script completo no SQL Editor do Supabase
-- Todas as tabelas, índices, políticas e triggers serão criados automaticamente!
