-- =============================================================================
-- ESQUEMA SQL OFICIAL PARA SUPABASE (POSTGRESQL GRATUITO)
-- PROYECTO: SIBA - Sistema de Bienestar Animal (UFPSO)
-- Resolución 136 de 2020 & Metodología ICA
-- =============================================================================
-- Instrucciones:
-- 1. Entra a https://supabase.com y crea un proyecto gratuito.
-- 2. Ve a la sección "SQL Editor" en el menú lateral.
-- 3. Pega todo este código y dale clic a "RUN".
-- =============================================================================

-- Habilitar extensión UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. TABLA: Usuarios y Evaluadores de la Granja
CREATE TABLE IF NOT EXISTS usuarios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo VARCHAR(50) UNIQUE NOT NULL,
  nombre VARCHAR(150) NOT NULL,
  rol VARCHAR(50) DEFAULT 'Evaluador Técnico', -- 'Administrador', 'Evaluador Técnico', 'Operario'
  email VARCHAR(150),
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. TABLA: Evaluaciones y Auditorías de Bienestar Animal
CREATE TABLE IF NOT EXISTS evaluaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  evaluador_nombre VARCHAR(150) NOT NULL,
  evaluador_codigo VARCHAR(50) NOT NULL,
  especie VARCHAR(50) NOT NULL,                -- 'Porcinos' o 'Aves'
  lote_codigo VARCHAR(100) NOT NULL,           -- Ej: 'LOTE-PORC-P04'
  ubicacion VARCHAR(150) NOT NULL,             -- Ej: 'Corral 3 - Sector Ceba'
  score_recursos NUMERIC(5, 2) DEFAULT 0,      -- Promedio Recursos (0 - 100%)
  score_animal NUMERIC(5, 2) DEFAULT 0,        -- Promedio Animal (0 - 100%)
  score_gestion NUMERIC(5, 2) DEFAULT 0,       -- Promedio Gestión (0 - 100%)
  puntaje_global NUMERIC(5, 2) NOT NULL,       -- IGBA (0 - 100 puntos)
  nivel_bienestar VARCHAR(50) NOT NULL,        -- 'Excelente', 'Bueno', 'Regular', 'Crítico'
  dictamen TEXT,                               -- Concepto técnico zootécnico
  indicadores_json JSONB DEFAULT '[]'::jsonb,  -- Detalle con fotos y notas de cada indicador
  origen_offline BOOLEAN DEFAULT TRUE,         -- True si fue capturado sin internet
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. TABLA: Alertas Sanitarias Tempranas (Indicadores Críticos)
CREATE TABLE IF NOT EXISTS alertas_bienestar (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  evaluacion_id UUID REFERENCES evaluaciones(id) ON DELETE CASCADE,
  lote_codigo VARCHAR(100) NOT NULL,
  indicador_nombre VARCHAR(200) NOT NULL,
  puntaje_asignado INTEGER NOT NULL,
  severidad VARCHAR(20) DEFAULT 'ALTA',        -- 'MEDIA', 'ALTA', 'CRÍTICA'
  atendida BOOLEAN DEFAULT FALSE,
  fecha_alerta TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- HABILITAR SEGURIDAD POR FILAS (RLS) CON ACCESO PÚBLICO LECTURA/ESCRITURA PARA LA APP
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE alertas_bienestar ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura publica de evaluaciones" ON evaluaciones FOR SELECT USING (true);
CREATE POLICY "Permitir insercion publica de evaluaciones" ON evaluaciones FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir lectura publica de usuarios" ON usuarios FOR SELECT USING (true);
CREATE POLICY "Permitir insercion publica de usuarios" ON usuarios FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir lectura publica de alertas" ON alertas_bienestar FOR SELECT USING (true);
CREATE POLICY "Permitir insercion publica de alertas" ON alertas_bienestar FOR INSERT WITH CHECK (true);

-- DATOS DE PRUEBA INICIALES DE LA GRANJA EXPERIMENTAL UFPSO
INSERT INTO usuarios (codigo, nombre, rol, email) VALUES
('0192546', 'Javier Mauricio Serna Osorio', 'Evaluador Técnico', '0192546@ufpso.edu.co'),
('0192544', 'Juan Manuel Garrido Amaya', 'Evaluador Técnico', '0192544@ufpso.edu.co'),
('ADMIN-01', 'Administrador Granja UFPSO', 'Administrador', 'bienestaranimal@ufpso.edu.co'),
('OP-002', 'Operario Campo Sector Porcinos', 'Operario', 'operarioporcinos@ufpso.edu.co')
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO evaluaciones (
  evaluador_nombre, evaluador_codigo, especie, lote_codigo, ubicacion,
  score_recursos, score_animal, score_gestion, puntaje_global, nivel_bienestar, dictamen, indicadores_json
) VALUES (
  'Javier Serna (0192546)', '0192546', 'Porcinos', 'LOTE-PORC-P04', 'Corral 3 - Sector Ceba',
  55.0, 77.5, 80.0, 52.5, 'Regular',
  'Nivel Regular (52.5 puntos). Cumple parcialmente la Resolución 136. Requiere cambio de chupones en bebedero #2 y limpieza profunda de comederos.',
  '[
    {"name": "Acceso al Agua (flujo)", "score": 55, "category": "Recursos", "photo": "https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400", "obs": "Flujo reducido en bebedero #2."},
    {"name": "Estado de los Comederos", "score": 0, "category": "Recursos", "photo": "https://images.unsplash.com/photo-1594489428504-5c0c480a15fd?w=400", "obs": "Comedero con alimento húmedo fermentado."},
    {"name": "Condición Corporal", "score": 100, "category": "Animal", "photo": "", "obs": "Peso y conformación muscular óptima."},
    {"name": "Heces sobre el cuerpo", "score": 55, "category": "Animal", "photo": "", "obs": "Leve suciedad en tren posterior."}
  ]'::jsonb
),
(
  'Juan Garrido (0192544)', '0192544', 'Aves', 'LOTE-PON-01', 'Galpón 1 - Aves de Postura',
  88.0, 92.0, 90.0, 90.0, 'Excelente',
  'Nivel Excelente (90.0 puntos). Cumplimiento pleno de bienestar avícola según Resolución 253 de 2020.',
  '[
    {"name": "Disponibilidad de Nidos", "score": 100, "category": "Recursos", "photo": "https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=400", "obs": "Nidos limpios con cama seca."},
    {"name": "Estado del Plumaje", "score": 90, "category": "Animal", "photo": "", "obs": "Plumaje íntegro y sin canibalismo."}
  ]'::jsonb
);
