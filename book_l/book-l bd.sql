-- ============================================================
--  MODELO RELACIONAL MySQL — Book-L
--  Compatible con HeidiSQL
-- ============================================================

-- 1. Crear y seleccionar la base de datos
CREATE DATABASE IF NOT EXISTS bookl
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE bookl;

-- 2. Desactivar chequeo de claves foráneas durante la creación
SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- ============================================================
-- Tbl_usuario
-- ============================================================
DROP TABLE IF EXISTS Tbl_usuario;
CREATE TABLE Tbl_usuario (
    IdUsuario       INT          NOT NULL AUTO_INCREMENT,
    NombreCompleto  VARCHAR(200) NOT NULL,
    Correo          VARCHAR(255) NOT NULL,
    Password        VARCHAR(255) NOT NULL,
    Username        VARCHAR(100) NOT NULL,
    Celular         INT(10)      NULL COMMENT 'Máximo 10 dígitos',
    Semestre        TINYINT      NULL,
    nacimiento      DATE         NULL,
    Programa        ENUM(
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
                    ) NULL COMMENT 'Programa académico del usuario',
    Preferencias    JSON         NULL,
    Activo          TINYINT(1)   NOT NULL DEFAULT 1,
    Created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Deleted_at      DATETIME     NULL,
    PRIMARY KEY (IdUsuario),
    UNIQUE KEY uq_usuario_correo   (Correo),
    UNIQUE KEY uq_usuario_username (Username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_seguidores
-- ============================================================
DROP TABLE IF EXISTS Tbl_seguidores;
CREATE TABLE Tbl_seguidores (
    IdSeguidor  INT      NOT NULL,
    IdSeguido   INT      NOT NULL,
    Estado      ENUM('activo','pendiente','bloqueado') NOT NULL DEFAULT 'pendiente',
    Created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdSeguidor, IdSeguido),
    CONSTRAINT fk_seguidor_usuario
        FOREIGN KEY (IdSeguidor) REFERENCES Tbl_usuario (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_seguido_usuario
        FOREIGN KEY (IdSeguido)  REFERENCES Tbl_usuario (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_leccion
-- ============================================================
DROP TABLE IF EXISTS Tbl_leccion;
CREATE TABLE Tbl_leccion (
    IdLeccion    INT          NOT NULL AUTO_INCREMENT,
    IdUsuarioFk  INT          NOT NULL,
    Nombre       VARCHAR(200) NOT NULL,
    Contenido    JSON         NULL COMMENT 'Arreglo de secciones con titulo, cuerpo_delta, imagen_url y video_url',
    Estado       ENUM('activa','inactiva','en_revision','suspendida') NOT NULL DEFAULT 'activa' COMMENT 'activa=visible | en_revision=reportada | suspendida=desactivada por admin',
    Created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdLeccion),
    CONSTRAINT fk_leccion_usuario
        FOREIGN KEY (IdUsuarioFk) REFERENCES Tbl_usuario (IdUsuario)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_material
-- ============================================================
DROP TABLE IF EXISTS Tbl_material;
CREATE TABLE Tbl_material (
    IdMaterial    INT           NOT NULL AUTO_INCREMENT,
    IdLeccionFk   INT           NOT NULL,
    Nombre        VARCHAR(200)  NOT NULL,
    Url           VARCHAR(2048) NULL,
    Descripcion   TEXT          NULL,
    Tipo          ENUM('video','pdf','enlace','SCORM') NOT NULL,
    Tamano_bytes  BIGINT        NOT NULL DEFAULT 0,
    Created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdMaterial),
    CONSTRAINT fk_material_leccion
        FOREIGN KEY (IdLeccionFk) REFERENCES Tbl_leccion (IdLeccion)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_curso
-- ============================================================
DROP TABLE IF EXISTS Tbl_curso;
CREATE TABLE Tbl_curso (
    IdCurso      INT          NOT NULL AUTO_INCREMENT,
    Nombre       VARCHAR(200) NOT NULL,
    Contenido    JSON         NULL COMMENT 'Arreglo de secciones con titulo, cuerpo_delta, imagen_url y video_url',
    Estado       ENUM('activo','inactivo','en_revision','suspendido') NOT NULL DEFAULT 'activo' COMMENT 'activo=visible | en_revision=reportado | suspendido=desactivado por admin',
    Created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdCurso)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_lecciones_cursos  (pivote M:N)
-- ============================================================
DROP TABLE IF EXISTS Tbl_lecciones_cursos;
CREATE TABLE Tbl_lecciones_cursos (
    IdLeccion  INT      NOT NULL,
    IdCurso    INT      NOT NULL,
    Created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdLeccion, IdCurso),
    CONSTRAINT fk_lc_leccion
        FOREIGN KEY (IdLeccion) REFERENCES Tbl_leccion (IdLeccion)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lc_curso
        FOREIGN KEY (IdCurso)   REFERENCES Tbl_curso   (IdCurso)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_capitulo
-- ============================================================
DROP TABLE IF EXISTS Tbl_capitulo;
CREATE TABLE Tbl_capitulo (
    IdCapitulo   INT          NOT NULL AUTO_INCREMENT,
    IdLeccion    INT          NOT NULL,
    Nombre       VARCHAR(200) NOT NULL,
    Contenido    JSON         NULL COMMENT 'Arreglo de secciones con titulo, cuerpo_delta, imagen_url y video_url',
    Tiempo_total INT          NOT NULL DEFAULT 0 COMMENT 'Duración en segundos',
    Created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdCapitulo),
    CONSTRAINT fk_capitulo_leccion
        FOREIGN KEY (IdLeccion) REFERENCES Tbl_leccion (IdLeccion)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_discusion
-- ============================================================
DROP TABLE IF EXISTS Tbl_discusion;
CREATE TABLE Tbl_discusion (
    Id_discusion INT NULL,
    Id_cursoFk   INT NULL,
    Id_leccionFk INT NULL,
    PRIMARY KEY (Id_discusion),
    CONSTRAINT fk_discusion_curso
        FOREIGN KEY (Id_cursoFk)   REFERENCES Tbl_curso   (IdCurso)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_discusion_leccion
        FOREIGN KEY (Id_leccionFk) REFERENCES Tbl_leccion (IdLeccion)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE Tbl_discusion MODIFY Id_discusion INT NOT NULL AUTO_INCREMENT;

-- ============================================================
-- Tbl_comentario
-- ============================================================
DROP TABLE IF EXISTS Tbl_comentario;
CREATE TABLE Tbl_comentario (
    Id_comentario  INT      NOT NULL AUTO_INCREMENT,
    Id_discusionFk INT      NOT NULL,
    Id_usuarioFk   INT      NOT NULL,
    Contenido      TEXT     NOT NULL,
    Id_padre       INT      NULL COMMENT 'Referencia al comentario padre para respuestas anidadas',
    Created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Id_comentario),
    CONSTRAINT fk_comentario_discusion
        FOREIGN KEY (Id_discusionFk) REFERENCES Tbl_discusion  (Id_discusion)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_comentario_usuario
        FOREIGN KEY (Id_usuarioFk)   REFERENCES Tbl_usuario    (IdUsuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_comentario_padre
        FOREIGN KEY (Id_padre)       REFERENCES Tbl_comentario (Id_comentario)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_notificacion
-- ============================================================
DROP TABLE IF EXISTS Tbl_notificacion;
CREATE TABLE Tbl_notificacion (
    IdNotificacion  INT           NOT NULL AUTO_INCREMENT,
    IdUserFk        INT           NOT NULL,
    Titulo          VARCHAR(255)  NOT NULL,
    Contenido       TEXT          NULL,
    Link_contenido  VARCHAR(2048) NULL,
    Id_cursoFk      INT           NULL,
    Id_leccionFk    INT           NULL,
    Id_comentarioFk INT           NULL,
    Created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdNotificacion),
    CONSTRAINT fk_notif_usuario
        FOREIGN KEY (IdUserFk)        REFERENCES Tbl_usuario    (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_notif_curso
        FOREIGN KEY (Id_cursoFk)      REFERENCES Tbl_curso      (IdCurso)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_notif_leccion
        FOREIGN KEY (Id_leccionFk)    REFERENCES Tbl_leccion    (IdLeccion)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_notif_comentario
        FOREIGN KEY (Id_comentarioFk) REFERENCES Tbl_comentario (Id_comentario)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_guardado
-- ============================================================
DROP TABLE IF EXISTS Tbl_guardado;
CREATE TABLE Tbl_guardado (
    IdGuardado INT      NOT NULL AUTO_INCREMENT,
    IdUsuario  INT      NOT NULL,
    IdLeccion  INT      NOT NULL,
    Created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (IdGuardado),
    UNIQUE KEY uq_guardado (IdUsuario, IdLeccion),
    CONSTRAINT fk_guardado_usuario
        FOREIGN KEY (IdUsuario) REFERENCES Tbl_usuario (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_guardado_leccion
        FOREIGN KEY (IdLeccion) REFERENCES Tbl_leccion (IdLeccion)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_ejercicio
-- ============================================================
DROP TABLE IF EXISTS Tbl_ejercicio;
CREATE TABLE Tbl_ejercicio (
    IdEjercicio INT      NOT NULL AUTO_INCREMENT,
    IdCapitulo  INT      NOT NULL,
    Tipo        ENUM('multiple_choice','true_false','ordenar','rellenar','respuesta_corta') NOT NULL,
    Created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdEjercicio),
    CONSTRAINT fk_ejercicio_capitulo
        FOREIGN KEY (IdCapitulo) REFERENCES Tbl_capitulo (IdCapitulo)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_pregunta
-- ============================================================
DROP TABLE IF EXISTS Tbl_pregunta;
CREATE TABLE Tbl_pregunta (
    IdPregunta    INT      NOT NULL AUTO_INCREMENT,
    IdEjercicioFk INT      NOT NULL,
    Contenido     TEXT     NOT NULL,
    Explicacion   TEXT     NULL,
    Created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdPregunta),
    CONSTRAINT fk_pregunta_ejercicio
        FOREIGN KEY (IdEjercicioFk) REFERENCES Tbl_ejercicio (IdEjercicio)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_opcion
-- ============================================================
DROP TABLE IF EXISTS Tbl_opcion;
CREATE TABLE Tbl_opcion (
    IdOpcion     INT        NOT NULL AUTO_INCREMENT,
    IdPreguntaFk INT        NOT NULL,
    Contenido    TEXT       NOT NULL,
    Correcta     TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (IdOpcion),
    CONSTRAINT fk_opcion_pregunta
        FOREIGN KEY (IdPreguntaFk) REFERENCES Tbl_pregunta (IdPregunta)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_respuesta_usuario
-- ============================================================
DROP TABLE IF EXISTS Tbl_respuesta_usuario;
CREATE TABLE Tbl_respuesta_usuario (
    Id_respuesta INT        NOT NULL AUTO_INCREMENT,
    Id_usuario   INT        NOT NULL,
    Id_pregunta  INT        NOT NULL,
    Id_opcion    INT        NULL,
    Correcta     TINYINT(1) NOT NULL DEFAULT 0,
    Fecha        DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id_respuesta),
    CONSTRAINT fk_resp_usuario
        FOREIGN KEY (Id_usuario)  REFERENCES Tbl_usuario  (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_resp_pregunta
        FOREIGN KEY (Id_pregunta) REFERENCES Tbl_pregunta (IdPregunta)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_resp_opcion
        FOREIGN KEY (Id_opcion)   REFERENCES Tbl_opcion   (IdOpcion)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_reporte
-- ============================================================
DROP TABLE IF EXISTS Tbl_reporte;
CREATE TABLE Tbl_reporte (
    IdReporte    INT         NOT NULL AUTO_INCREMENT,
    IdUsuarioFk  INT         NOT NULL,
    Entidad_tipo VARCHAR(60) NOT NULL COMMENT 'Nombre de la tabla reportada',
    Entidad_id   INT         NOT NULL,
    Motivo       TEXT        NULL,
    PRIMARY KEY (IdReporte),
    CONSTRAINT fk_reporte_usuario
        FOREIGN KEY (IdUsuarioFk) REFERENCES Tbl_usuario (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_configuracion
-- ============================================================
DROP TABLE IF EXISTS Tbl_configuracion;
CREATE TABLE Tbl_configuracion (
    IdConfig             INT        NOT NULL AUTO_INCREMENT,
    IdUsuario            INT        NOT NULL,
    Tema                 TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0 = claro | 1 = oscuro',
    Idioma               ENUM('es','en','fr','pt') NOT NULL DEFAULT 'es',
    Notificaciones_push  TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = activadas',
    Notificaciones_email TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = activadas',
    Notificaciones_racha TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Recordatorio de racha diaria',
    Tamano_fuente        ENUM('pequeno','normal','grande') NOT NULL DEFAULT 'normal',
    Reproduccion_auto    TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Autoplay de videos',
    Perfil_publico       TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = visible para otros usuarios',
    Created_at           DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at           DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdConfig),
    UNIQUE KEY uq_config_usuario (IdUsuario),
    CONSTRAINT fk_config_usuario
        FOREIGN KEY (IdUsuario) REFERENCES Tbl_usuario (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_racha
-- ============================================================
DROP TABLE IF EXISTS Tbl_racha;
CREATE TABLE Tbl_racha (
    Id_racha           INT        NOT NULL AUTO_INCREMENT,
    Id_usuario         INT        NOT NULL,
    Current_streak     INT        NOT NULL DEFAULT 0,
    Max_streak         INT        NOT NULL DEFAULT 0,
    Last_activity_date DATE       NULL,
    Active             TINYINT(1) NOT NULL DEFAULT 1,
    Created_at         DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id_racha),
    UNIQUE KEY uq_racha_usuario (Id_usuario),
    CONSTRAINT fk_racha_usuario
        FOREIGN KEY (Id_usuario) REFERENCES Tbl_usuario (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_evento_aprendizaje
-- ============================================================
DROP TABLE IF EXISTS Tbl_evento_aprendizaje;
CREATE TABLE Tbl_evento_aprendizaje (
    Id_evento    INT          NOT NULL AUTO_INCREMENT,
    Id_usuario   INT          NOT NULL,
    Session_id   VARCHAR(100) NULL,
    Tipo_evento  ENUM('inicio_leccion','fin_leccion','comentario','respuesta','guardar','notificacion_leida') NOT NULL,
    Entidad_tipo VARCHAR(60)  NULL,
    Entidad_id   INT          NULL,
    Fecha_evento DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Duracion     INT          NULL COMMENT 'Duración en segundos',
    Extra_data   JSON         NULL,
    PRIMARY KEY (Id_evento),
    CONSTRAINT fk_evento_usuario
        FOREIGN KEY (Id_usuario) REFERENCES Tbl_usuario (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_progreso_usuario
-- ============================================================
DROP TABLE IF EXISTS Tbl_progreso_usuario;
CREATE TABLE Tbl_progreso_usuario (
    Id_progreso         INT          NOT NULL AUTO_INCREMENT,
    Id_usuarioFk        INT          NOT NULL,
    Id_capituloFk       INT          NOT NULL,
    Estado              ENUM('no_iniciada','en_progreso','completada') NOT NULL DEFAULT 'no_iniciada',
    Porcentaje_capitulo DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    Created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Id_progreso),
    UNIQUE KEY uq_progreso (Id_usuarioFk, Id_capituloFk),
    CONSTRAINT fk_progreso_usuario
        FOREIGN KEY (Id_usuarioFk)  REFERENCES Tbl_usuario  (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_progreso_capitulo
        FOREIGN KEY (Id_capituloFk) REFERENCES Tbl_capitulo (IdCapitulo)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================

-- ============================================================
-- Tbl_calificacion_leccion  (M:N usuario <-> leccion)
-- ============================================================
DROP TABLE IF EXISTS Tbl_calificacion_leccion;
CREATE TABLE Tbl_calificacion_leccion (
    IdCalificacion INT          NOT NULL AUTO_INCREMENT,
    IdUsuarioFk    INT          NOT NULL,
    IdLeccionFk    INT          NOT NULL,
    Calificacion   DECIMAL(3,1) NOT NULL COMMENT 'Valor de 1.0 a 5.0',
    Comentario     TEXT         NULL,
    Created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdCalificacion),
    UNIQUE KEY uq_calif_leccion (IdUsuarioFk, IdLeccionFk),
    CONSTRAINT fk_calif_lec_usuario
        FOREIGN KEY (IdUsuarioFk) REFERENCES Tbl_usuario (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_calif_lec_leccion
        FOREIGN KEY (IdLeccionFk) REFERENCES Tbl_leccion (IdLeccion)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tbl_calificacion_curso  (M:N usuario <-> curso)
-- ============================================================
DROP TABLE IF EXISTS Tbl_calificacion_curso;
CREATE TABLE Tbl_calificacion_curso (
    IdCalificacion INT          NOT NULL AUTO_INCREMENT,
    IdUsuarioFk    INT          NOT NULL,
    IdCursoFk      INT          NOT NULL,
    Calificacion   DECIMAL(3,1) NOT NULL COMMENT 'Valor de 1.0 a 5.0',
    Comentario     TEXT         NULL,
    Created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdCalificacion),
    UNIQUE KEY uq_calif_curso (IdUsuarioFk, IdCursoFk),
    CONSTRAINT fk_calif_cur_usuario
        FOREIGN KEY (IdUsuarioFk) REFERENCES Tbl_usuario (IdUsuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_calif_cur_curso
        FOREIGN KEY (IdCursoFk) REFERENCES Tbl_curso (IdCurso)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
SET FOREIGN_KEY_CHECKS = 1;
-- ============================================================
