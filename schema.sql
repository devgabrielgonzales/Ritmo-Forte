-- Ritmo Forte · Schema Supabase
-- Execute no SQL Editor: https://supabase.com/dashboard/project/mgioptzpohfhpvxlbmua/sql

-- ─── Tabelas ─────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.athletes (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at            timestamptz DEFAULT now(),
  nome                  text NOT NULL,
  email                 text NOT NULL,
  idade                 int  NOT NULL,
  genero                text NOT NULL,
  curso                 text NOT NULL,
  anamnese              jsonb DEFAULT '{}',
  anamnese_obs          text DEFAULT '',
  term_responsabilidade bool DEFAULT false,
  term_imagem           bool DEFAULT false,
  term_regulamento      bool DEFAULT false,
  assinatura_nome       text DEFAULT '',
  assinatura_data       text DEFAULT '',
  status                text DEFAULT 'pendente'  -- pendente | confirmado | cancelado
);

CREATE TABLE IF NOT EXISTS public.heats (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  nome       text NOT NULL,
  categoria  text NOT NULL,   -- Masculino | Feminino
  numero     int  NOT NULL,
  status     text DEFAULT 'pendente'  -- pendente | em_andamento | finalizado
);

CREATE TABLE IF NOT EXISTS public.heat_athletes (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  heat_id    uuid REFERENCES public.heats(id)    ON DELETE CASCADE,
  athlete_id uuid REFERENCES public.athletes(id) ON DELETE CASCADE,
  raia       int  NOT NULL,
  tempo      text,      -- ex: "12.45"
  tempo_ms   int,       -- milissegundos para ordenação
  posicao    int,
  UNIQUE(heat_id, raia),
  UNIQUE(heat_id, athlete_id)
);

-- ─── Row Level Security ───────────────────────────────────────────────────────

ALTER TABLE public.athletes      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.heats         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.heat_athletes ENABLE ROW LEVEL SECURITY;

-- Qualquer pessoa pode se inscrever
CREATE POLICY "public_insert_athletes"
  ON public.athletes FOR INSERT WITH CHECK (true);

-- Leitura pública de baterias e resultados (ranking)
CREATE POLICY "public_read_heats"
  ON public.heats FOR SELECT USING (true);

CREATE POLICY "public_read_heat_athletes"
  ON public.heat_athletes FOR SELECT USING (true);

-- Admin (autenticado): acesso total
CREATE POLICY "auth_all_athletes"
  ON public.athletes FOR ALL TO authenticated
  USING (true) WITH CHECK (true);

CREATE POLICY "auth_all_heats"
  ON public.heats FOR ALL TO authenticated
  USING (true) WITH CHECK (true);

CREATE POLICY "auth_all_heat_athletes"
  ON public.heat_athletes FOR ALL TO authenticated
  USING (true) WITH CHECK (true);

-- ─── Baterias padrão ─────────────────────────────────────────────────────────

INSERT INTO public.heats (nome, categoria, numero) VALUES
  ('Bateria 1 · 100m Feminino',  'Feminino',  1),
  ('Bateria 2 · 100m Feminino',  'Feminino',  2),
  ('Bateria 3 · 100m Feminino',  'Feminino',  3),
  ('Bateria 1 · 100m Masculino', 'Masculino', 1),
  ('Bateria 2 · 100m Masculino', 'Masculino', 2),
  ('Bateria 3 · 100m Masculino', 'Masculino', 3);
