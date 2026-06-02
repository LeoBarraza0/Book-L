-- ============================================================
--  MODELO RELACIONAL PostgreSQL — Book-L
--  Compatible con Supabase (PostgreSQL 15+)
--  Nombres en snake_case minúsculas (convención PostgreSQL)
-- ============================================================

-- ============================================================
-- TIPOS ENUM
-- Envueltos en bloques DO para ser idempotentes (re-ejecutables)
-- ============================================================

DO $$ BEGIN
    CREATE TYPE tipo_programa AS ENUM (
        'Ingenieria de Sistemas',
        'Ingenieria Industrial',
        'Ingenieria Civil',
        'Contaduria Publica',
        'Administracion de Empresas',
        'Derecho',
        'Medicina',
        'Psicologia',
        'Enfermeria',
        'Arquitectura'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE tipo_rol AS ENUM ('Estudiante', 'Profesor', 'Administrador');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE tipo_estado_seguidor AS ENUM ('activo', 'pendiente', 'bloqueado');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE tipo_estado_leccion AS ENUM ('activa', 'inactiva', 'en_revision', 'suspendida');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE tipo_material AS ENUM ('video', 'pdf', 'enlace', 'SCORM');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE tipo_estado_curso AS ENUM ('activo', 'inactivo', 'en_revision', 'suspendido');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE tipo_evento AS ENUM (
        'inicio_leccion', 'fin_leccion', 'comentario',
        'respuesta', 'guardar', 'notificacion_leida'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE tipo_progreso AS ENUM ('no_iniciada', 'en_progreso', 'completada');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE tipo_ejercicio AS ENUM (
        'multiple_choice', 'true_false', 'ordenar',
        'rellenar', 'respuesta_corta'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE tipo_idioma AS ENUM ('es', 'en', 'fr', 'pt');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE tipo_fuente AS ENUM ('pequeno', 'normal', 'grande');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================
-- FUNCIÓN para auto-actualizar updated_at
-- ============================================================

CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- tbl_usuario
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_usuario (
    id_usuario       SERIAL          NOT NULL,
    nombre_completo  VARCHAR(200)    NOT NULL,
    correo           VARCHAR(255)    NOT NULL,
    contrasena       VARCHAR(255)    NOT NULL,   -- Mapeado a password en frontend
    username         VARCHAR(100)    NOT NULL,
    celular          BIGINT          NULL,        -- BIGINT para números de 10 dígitos
    semestre         SMALLINT        NULL,
    nacimiento       DATE            NULL,
    programa         tipo_programa   NULL,
    preferencias     JSONB           NULL,
    rol              tipo_rol        NOT NULL DEFAULT 'Estudiante',
    avatar_url       VARCHAR(2048)   NULL,
    descripcion      TEXT            NULL,
    activo           BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at       TIMESTAMPTZ     NULL,
    PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_correo   UNIQUE (correo),
    CONSTRAINT uq_usuario_username UNIQUE (username)
);

CREATE OR REPLACE TRIGGER trg_usuario_updated_at
BEFORE UPDATE ON tbl_usuario
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_seguidores
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_seguidores (
    id_seguidor  INT                  NOT NULL,
    id_seguido   INT                  NOT NULL,
    estado       tipo_estado_seguidor NOT NULL DEFAULT 'pendiente',
    created_at   TIMESTAMPTZ          NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ          NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_seguidor, id_seguido),
    CONSTRAINT fk_seguidor_usuario
        FOREIGN KEY (id_seguidor) REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_seguido_usuario
        FOREIGN KEY (id_seguido)  REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_seguidores_updated_at
BEFORE UPDATE ON tbl_seguidores
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_leccion
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_leccion (
    id_leccion    SERIAL               NOT NULL,
    id_usuario_fk INT                  NOT NULL,   -- Creador/Dueño de la lección
    nombre        VARCHAR(200)         NOT NULL,
    contenido     JSONB                NULL,        -- Secciones: titulo, cuerpo_delta, imagen_url, video_url
    imagen_url    VARCHAR(2048)        NULL,
    tag_color     INT                  NULL,        -- Mapeado a tagColor en frontend
    es_nuevo      BOOLEAN              NOT NULL DEFAULT TRUE,
    estado        tipo_estado_leccion  NOT NULL DEFAULT 'activa',
    created_at    TIMESTAMPTZ          NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ          NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_leccion),
    CONSTRAINT fk_leccion_usuario
        FOREIGN KEY (id_usuario_fk) REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE OR REPLACE TRIGGER trg_leccion_updated_at
BEFORE UPDATE ON tbl_leccion
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_material
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_material (
    id_material   SERIAL          NOT NULL,
    id_leccion_fk INT             NOT NULL,
    nombre        VARCHAR(200)    NOT NULL,
    url           VARCHAR(2048)   NULL,
    descripcion   TEXT            NULL,
    tipo          tipo_material   NOT NULL,
    tamano_bytes  BIGINT          NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_material),
    CONSTRAINT fk_material_leccion
        FOREIGN KEY (id_leccion_fk) REFERENCES tbl_leccion (id_leccion)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_material_updated_at
BEFORE UPDATE ON tbl_material
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_curso
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_curso (
    id_curso      SERIAL             NOT NULL,
    id_usuario_fk INT                NOT NULL,   -- Creador/Profesor del curso
    nombre        VARCHAR(200)       NOT NULL,
    contenido     JSONB              NULL,        -- Secciones: titulo, cuerpo_delta, imagen_url, video_url
    imagen_url    VARCHAR(2048)      NULL,
    tag_color     INT                NULL,        -- Mapeado a tagColor en frontend
    es_nuevo      BOOLEAN            NOT NULL DEFAULT TRUE,
    estado        tipo_estado_curso  NOT NULL DEFAULT 'activo',
    created_at    TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_curso),
    CONSTRAINT fk_curso_usuario
        FOREIGN KEY (id_usuario_fk) REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE OR REPLACE TRIGGER trg_curso_updated_at
BEFORE UPDATE ON tbl_curso
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_lecciones_cursos  (pivote M:N)
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_lecciones_cursos (
    id_leccion INT         NOT NULL,
    id_curso   INT         NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_leccion, id_curso),
    CONSTRAINT fk_lc_leccion
        FOREIGN KEY (id_leccion) REFERENCES tbl_leccion (id_leccion)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lc_curso
        FOREIGN KEY (id_curso)   REFERENCES tbl_curso   (id_curso)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_lecciones_cursos_updated_at
BEFORE UPDATE ON tbl_lecciones_cursos
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_capitulo
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_capitulo (
    id_capitulo  SERIAL          NOT NULL,
    id_leccion   INT             NOT NULL,
    nombre       VARCHAR(200)    NOT NULL,
    contenido    JSONB           NULL,   -- Secciones: titulo, cuerpo_delta, imagen_url, video_url
    tiempo_total INT             NOT NULL DEFAULT 0,   -- Duración en segundos
    created_at   TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_capitulo),
    CONSTRAINT fk_capitulo_leccion
        FOREIGN KEY (id_leccion) REFERENCES tbl_leccion (id_leccion)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_capitulo_updated_at
BEFORE UPDATE ON tbl_capitulo
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_discusion
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_discusion (
    id_discusion SERIAL NOT NULL,
    id_curso_fk  INT    NULL,
    id_leccion_fk INT   NULL,
    PRIMARY KEY (id_discusion),
    CONSTRAINT fk_discusion_curso
        FOREIGN KEY (id_curso_fk)   REFERENCES tbl_curso   (id_curso)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_discusion_leccion
        FOREIGN KEY (id_leccion_fk) REFERENCES tbl_leccion (id_leccion)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- ============================================================
-- tbl_comentario
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_comentario (
    id_comentario  SERIAL      NOT NULL,
    id_discusion_fk INT        NOT NULL,
    id_usuario_fk  INT         NOT NULL,
    contenido      TEXT        NOT NULL,
    id_padre       INT         NULL,   -- Comentario padre para respuestas anidadas
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_discusion
        FOREIGN KEY (id_discusion_fk) REFERENCES tbl_discusion  (id_discusion)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_comentario_usuario
        FOREIGN KEY (id_usuario_fk)   REFERENCES tbl_usuario    (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_comentario_padre
        FOREIGN KEY (id_padre)        REFERENCES tbl_comentario (id_comentario)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE OR REPLACE TRIGGER trg_comentario_updated_at
BEFORE UPDATE ON tbl_comentario
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_notificacion
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_notificacion (
    id_notificacion  SERIAL          NOT NULL,
    id_usuario_fk    INT             NOT NULL,
    tipo             VARCHAR(50)     NOT NULL,   -- Tipo: follow, comentario, etc.
    id_referencia    INT             NULL,
    mensaje          TEXT            NOT NULL,
    leida            BOOLEAN         NOT NULL DEFAULT FALSE,
    id_curso_fk      INT             NULL,
    id_leccion_fk    INT             NULL,
    id_comentario_fk INT             NULL,
    created_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_notificacion),
    CONSTRAINT fk_notif_usuario
        FOREIGN KEY (id_usuario_fk)    REFERENCES tbl_usuario    (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_notif_curso
        FOREIGN KEY (id_curso_fk)      REFERENCES tbl_curso      (id_curso)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_notif_leccion
        FOREIGN KEY (id_leccion_fk)    REFERENCES tbl_leccion    (id_leccion)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_notif_comentario
        FOREIGN KEY (id_comentario_fk) REFERENCES tbl_comentario (id_comentario)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE OR REPLACE TRIGGER trg_notificacion_updated_at
BEFORE UPDATE ON tbl_notificacion
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_guardado_leccion
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_guardado_leccion (
    id_guardado_leccion SERIAL      NOT NULL,
    id_usuario          INT         NOT NULL,
    id_leccion          INT         NOT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_guardado_leccion),
    CONSTRAINT uq_guardado_leccion UNIQUE (id_usuario, id_leccion),
    CONSTRAINT fk_guardado_leccion_usuario
        FOREIGN KEY (id_usuario) REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_guardado_leccion_leccion
        FOREIGN KEY (id_leccion) REFERENCES tbl_leccion (id_leccion)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- tbl_guardado_curso
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_guardado_curso (
    id_guardado_curso SERIAL      NOT NULL,
    id_usuario        INT         NOT NULL,
    id_curso          INT         NOT NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_guardado_curso),
    CONSTRAINT uq_guardado_curso UNIQUE (id_usuario, id_curso),
    CONSTRAINT fk_guardado_curso_usuario
        FOREIGN KEY (id_usuario) REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_guardado_curso_curso
        FOREIGN KEY (id_curso)   REFERENCES tbl_curso   (id_curso)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- tbl_ejercicio
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_ejercicio (
    id_ejercicio SERIAL          NOT NULL,
    id_capitulo  INT             NOT NULL,
    tipo         tipo_ejercicio  NOT NULL,
    titulo       VARCHAR(200)    NOT NULL,
    descripcion  TEXT            NOT NULL,
    created_at   TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_ejercicio),
    CONSTRAINT fk_ejercicio_capitulo
        FOREIGN KEY (id_capitulo) REFERENCES tbl_capitulo (id_capitulo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_ejercicio_updated_at
BEFORE UPDATE ON tbl_ejercicio
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_pregunta
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_pregunta (
    id_pregunta    SERIAL      NOT NULL,
    id_ejercicio_fk INT        NOT NULL,
    contenido      TEXT        NOT NULL,
    explicacion    TEXT        NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_pregunta),
    CONSTRAINT fk_pregunta_ejercicio
        FOREIGN KEY (id_ejercicio_fk) REFERENCES tbl_ejercicio (id_ejercicio)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_pregunta_updated_at
BEFORE UPDATE ON tbl_pregunta
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_opcion
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_opcion (
    id_opcion     SERIAL      NOT NULL,
    id_pregunta_fk INT        NOT NULL,
    contenido     TEXT        NOT NULL,
    correcta      BOOLEAN     NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id_opcion),
    CONSTRAINT fk_opcion_pregunta
        FOREIGN KEY (id_pregunta_fk) REFERENCES tbl_pregunta (id_pregunta)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- tbl_respuesta_usuario
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_respuesta_usuario (
    id_respuesta INT         NOT NULL GENERATED ALWAYS AS IDENTITY,
    id_usuario   INT         NOT NULL,
    id_pregunta  INT         NOT NULL,
    id_opcion    INT         NULL,
    correcta     BOOLEAN     NOT NULL DEFAULT FALSE,
    fecha        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_respuesta),
    CONSTRAINT fk_resp_usuario
        FOREIGN KEY (id_usuario)  REFERENCES tbl_usuario  (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_resp_pregunta
        FOREIGN KEY (id_pregunta) REFERENCES tbl_pregunta (id_pregunta)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_resp_opcion
        FOREIGN KEY (id_opcion)   REFERENCES tbl_opcion   (id_opcion)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- ============================================================
-- tbl_reporte
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_reporte (
    id_reporte   SERIAL      NOT NULL,
    id_usuario_fk INT        NOT NULL,
    entidad_tipo VARCHAR(60) NOT NULL,   -- Nombre de la tabla reportada
    entidad_id   INT         NOT NULL,
    motivo       TEXT        NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_reporte),
    CONSTRAINT fk_reporte_usuario
        FOREIGN KEY (id_usuario_fk) REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_reporte_updated_at
BEFORE UPDATE ON tbl_reporte
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_configuracion
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_configuracion (
    id_config             SERIAL      NOT NULL,
    id_usuario            INT         NOT NULL,
    tema                  BOOLEAN     NOT NULL DEFAULT FALSE,    -- FALSE = claro | TRUE = oscuro
    idioma                tipo_idioma NOT NULL DEFAULT 'es',
    notificaciones_push   BOOLEAN     NOT NULL DEFAULT TRUE,
    notificaciones_email  BOOLEAN     NOT NULL DEFAULT TRUE,
    notificaciones_racha  BOOLEAN     NOT NULL DEFAULT TRUE,     -- Recordatorio de racha diaria
    tamano_fuente         tipo_fuente NOT NULL DEFAULT 'normal',
    reproduccion_auto     BOOLEAN     NOT NULL DEFAULT TRUE,     -- Autoplay de videos
    perfil_publico        BOOLEAN     NOT NULL DEFAULT TRUE,     -- TRUE = visible para otros usuarios
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_config),
    CONSTRAINT uq_config_usuario UNIQUE (id_usuario),
    CONSTRAINT fk_config_usuario
        FOREIGN KEY (id_usuario) REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_configuracion_updated_at
BEFORE UPDATE ON tbl_configuracion
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_racha
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_racha (
    id_racha            SERIAL      NOT NULL,
    id_usuario          INT         NOT NULL,
    current_streak      INT         NOT NULL DEFAULT 0,
    max_streak          INT         NOT NULL DEFAULT 0,
    last_activity_date  DATE        NULL,
    active              BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_racha),
    CONSTRAINT uq_racha_usuario UNIQUE (id_usuario),
    CONSTRAINT fk_racha_usuario
        FOREIGN KEY (id_usuario) REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- tbl_evento_aprendizaje
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_evento_aprendizaje (
    id_evento    SERIAL      NOT NULL,
    id_usuario   INT         NOT NULL,
    session_id   VARCHAR(100) NULL,
    tipo_evento  tipo_evento NOT NULL,
    entidad_tipo VARCHAR(60) NULL,
    entidad_id   INT         NULL,
    fecha_evento TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    duracion     INT         NULL,   -- Duración en segundos
    extra_data   JSONB       NULL,
    PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_usuario
        FOREIGN KEY (id_usuario) REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- tbl_progreso_usuario
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_progreso_usuario (
    id_progreso         SERIAL          NOT NULL,
    id_usuario_fk       INT             NOT NULL,
    id_capitulo_fk      INT             NOT NULL,
    estado              tipo_progreso   NOT NULL DEFAULT 'no_iniciada',
    porcentaje_capitulo NUMERIC(5,2)    NOT NULL DEFAULT 0.00,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_progreso),
    CONSTRAINT uq_progreso UNIQUE (id_usuario_fk, id_capitulo_fk),
    CONSTRAINT fk_progreso_usuario
        FOREIGN KEY (id_usuario_fk)  REFERENCES tbl_usuario  (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_progreso_capitulo
        FOREIGN KEY (id_capitulo_fk) REFERENCES tbl_capitulo (id_capitulo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_progreso_usuario_updated_at
BEFORE UPDATE ON tbl_progreso_usuario
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_calificacion_leccion  (M:N usuario <-> leccion)
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_calificacion_leccion (
    id_calificacion SERIAL      NOT NULL,
    id_usuario_fk   INT         NOT NULL,
    id_leccion_fk   INT         NOT NULL,
    valor           SMALLINT    NOT NULL,   -- Valor del 1 al 5
    comentario      TEXT        NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_calificacion),
    CONSTRAINT uq_calif_leccion UNIQUE (id_usuario_fk, id_leccion_fk),
    CONSTRAINT fk_calif_lec_usuario
        FOREIGN KEY (id_usuario_fk) REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_calif_lec_leccion
        FOREIGN KEY (id_leccion_fk) REFERENCES tbl_leccion (id_leccion)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_calificacion_leccion_updated_at
BEFORE UPDATE ON tbl_calificacion_leccion
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- tbl_calificacion_curso  (M:N usuario <-> curso)
-- ============================================================
CREATE TABLE IF NOT EXISTS tbl_calificacion_curso (
    id_calificacion SERIAL      NOT NULL,
    id_usuario_fk   INT         NOT NULL,
    id_curso_fk     INT         NOT NULL,
    valor           SMALLINT    NOT NULL,   -- Valor del 1 al 5
    comentario      TEXT        NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_calificacion),
    CONSTRAINT uq_calif_curso UNIQUE (id_usuario_fk, id_curso_fk),
    CONSTRAINT fk_calif_cur_usuario
        FOREIGN KEY (id_usuario_fk) REFERENCES tbl_usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_calif_cur_curso
        FOREIGN KEY (id_curso_fk)   REFERENCES tbl_curso   (id_curso)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER trg_calificacion_curso_updated_at
BEFORE UPDATE ON tbl_calificacion_curso
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();
