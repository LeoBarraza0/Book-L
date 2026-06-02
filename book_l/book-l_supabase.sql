-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.tbl_usuario (
  idusuario integer NOT NULL DEFAULT nextval('tbl_usuario_idusuario_seq'::regclass),
  nombrecompleto character varying NOT NULL,
  correo character varying NOT NULL UNIQUE,
  contrasena character varying NOT NULL,
  username character varying NOT NULL UNIQUE,
  celular bigint,
  semestre smallint,
  nacimiento date,
  programa USER-DEFINED,
  preferencias jsonb,
  rol USER-DEFINED NOT NULL DEFAULT 'Estudiante'::tipo_rol,
  avatar_url character varying,
  descripcion text,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  CONSTRAINT tbl_usuario_pkey PRIMARY KEY (idusuario)
);
CREATE TABLE public.tbl_seguidores (
  idseguidor integer NOT NULL,
  idseguido integer NOT NULL,
  estado USER-DEFINED NOT NULL DEFAULT 'pendiente'::tipo_estado_seguidor,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_seguidores_pkey PRIMARY KEY (idseguidor, idseguido),
  CONSTRAINT fk_seguidor_usuario FOREIGN KEY (idseguidor) REFERENCES public.tbl_usuario(idusuario),
  CONSTRAINT fk_seguido_usuario FOREIGN KEY (idseguido) REFERENCES public.tbl_usuario(idusuario)
);
CREATE TABLE public.tbl_leccion (
  idleccion integer NOT NULL DEFAULT nextval('tbl_leccion_idleccion_seq'::regclass),
  idusuariofk integer NOT NULL,
  nombre character varying NOT NULL,
  contenido jsonb,
  imagen_url character varying,
  tagcolor integer,
  esnuevo boolean NOT NULL DEFAULT true,
  estado USER-DEFINED NOT NULL DEFAULT 'activa'::tipo_estado_leccion,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_leccion_pkey PRIMARY KEY (idleccion),
  CONSTRAINT fk_leccion_usuario FOREIGN KEY (idusuariofk) REFERENCES public.tbl_usuario(idusuario)
);
CREATE TABLE public.tbl_material (
  idmaterial integer NOT NULL DEFAULT nextval('tbl_material_idmaterial_seq'::regclass),
  idleccionfk integer NOT NULL,
  nombre character varying NOT NULL,
  url character varying,
  descripcion text,
  tipo USER-DEFINED NOT NULL,
  tamano_bytes bigint NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_material_pkey PRIMARY KEY (idmaterial),
  CONSTRAINT fk_material_leccion FOREIGN KEY (idleccionfk) REFERENCES public.tbl_leccion(idleccion)
);
CREATE TABLE public.tbl_curso (
  idcurso integer NOT NULL DEFAULT nextval('tbl_curso_idcurso_seq'::regclass),
  idusuariofk integer NOT NULL,
  nombre character varying NOT NULL,
  contenido jsonb,
  imagen_url character varying,
  tagcolor integer,
  esnuevo boolean NOT NULL DEFAULT true,
  estado USER-DEFINED NOT NULL DEFAULT 'activo'::tipo_estado_curso,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_curso_pkey PRIMARY KEY (idcurso),
  CONSTRAINT fk_curso_usuario FOREIGN KEY (idusuariofk) REFERENCES public.tbl_usuario(idusuario)
);
CREATE TABLE public.tbl_lecciones_cursos (
  idleccion integer NOT NULL,
  idcurso integer NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_lecciones_cursos_pkey PRIMARY KEY (idleccion, idcurso),
  CONSTRAINT fk_lc_leccion FOREIGN KEY (idleccion) REFERENCES public.tbl_leccion(idleccion),
  CONSTRAINT fk_lc_curso FOREIGN KEY (idcurso) REFERENCES public.tbl_curso(idcurso)
);
CREATE TABLE public.tbl_capitulo (
  idcapitulo integer NOT NULL DEFAULT nextval('tbl_capitulo_idcapitulo_seq'::regclass),
  idleccion integer NOT NULL,
  nombre character varying NOT NULL,
  contenido jsonb,
  tiempo_total integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_capitulo_pkey PRIMARY KEY (idcapitulo),
  CONSTRAINT fk_capitulo_leccion FOREIGN KEY (idleccion) REFERENCES public.tbl_leccion(idleccion)
);
CREATE TABLE public.tbl_discusion (
  id_discusion integer NOT NULL DEFAULT nextval('tbl_discusion_id_discusion_seq'::regclass),
  id_cursofk integer,
  id_leccionfk integer,
  CONSTRAINT tbl_discusion_pkey PRIMARY KEY (id_discusion),
  CONSTRAINT fk_discusion_curso FOREIGN KEY (id_cursofk) REFERENCES public.tbl_curso(idcurso),
  CONSTRAINT fk_discusion_leccion FOREIGN KEY (id_leccionfk) REFERENCES public.tbl_leccion(idleccion)
);
CREATE TABLE public.tbl_comentario (
  id_comentario integer NOT NULL DEFAULT nextval('tbl_comentario_id_comentario_seq'::regclass),
  id_discusionfk integer NOT NULL,
  id_usuariofk integer NOT NULL,
  contenido text NOT NULL,
  id_padre integer,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_comentario_pkey PRIMARY KEY (id_comentario),
  CONSTRAINT fk_comentario_discusion FOREIGN KEY (id_discusionfk) REFERENCES public.tbl_discusion(id_discusion),
  CONSTRAINT fk_comentario_usuario FOREIGN KEY (id_usuariofk) REFERENCES public.tbl_usuario(idusuario),
  CONSTRAINT fk_comentario_padre FOREIGN KEY (id_padre) REFERENCES public.tbl_comentario(id_comentario)
);
CREATE TABLE public.tbl_notificacion (
  idnotificacion integer NOT NULL DEFAULT nextval('tbl_notificacion_idnotificacion_seq'::regclass),
  idusuariofk integer NOT NULL,
  tipo character varying NOT NULL,
  idreferencia integer,
  mensaje text NOT NULL,
  leida boolean NOT NULL DEFAULT false,
  idcursofk integer,
  idleccionfk integer,
  idcomentariofk integer,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_notificacion_pkey PRIMARY KEY (idnotificacion),
  CONSTRAINT fk_notif_usuario FOREIGN KEY (idusuariofk) REFERENCES public.tbl_usuario(idusuario),
  CONSTRAINT fk_notif_curso FOREIGN KEY (idcursofk) REFERENCES public.tbl_curso(idcurso),
  CONSTRAINT fk_notif_leccion FOREIGN KEY (idleccionfk) REFERENCES public.tbl_leccion(idleccion),
  CONSTRAINT fk_notif_comentario FOREIGN KEY (idcomentariofk) REFERENCES public.tbl_comentario(id_comentario)
);
CREATE TABLE public.tbl_guardado_leccion (
  idguardadoleccion integer NOT NULL DEFAULT nextval('tbl_guardado_leccion_idguardadoleccion_seq'::regclass),
  idusuario integer NOT NULL,
  idleccion integer NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_guardado_leccion_pkey PRIMARY KEY (idguardadoleccion),
  CONSTRAINT fk_guardado_leccion_usuario FOREIGN KEY (idusuario) REFERENCES public.tbl_usuario(idusuario),
  CONSTRAINT fk_guardado_leccion_leccion FOREIGN KEY (idleccion) REFERENCES public.tbl_leccion(idleccion)
);
CREATE TABLE public.tbl_guardado_curso (
  idguardadocurso integer NOT NULL DEFAULT nextval('tbl_guardado_curso_idguardadocurso_seq'::regclass),
  idusuario integer NOT NULL,
  idcurso integer NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_guardado_curso_pkey PRIMARY KEY (idguardadocurso),
  CONSTRAINT fk_guardado_curso_usuario FOREIGN KEY (idusuario) REFERENCES public.tbl_usuario(idusuario),
  CONSTRAINT fk_guardado_curso_curso FOREIGN KEY (idcurso) REFERENCES public.tbl_curso(idcurso)
);
CREATE TABLE public.tbl_ejercicio (
  idejercicio integer NOT NULL DEFAULT nextval('tbl_ejercicio_idejercicio_seq'::regclass),
  idcapitulo integer NOT NULL,
  tipo USER-DEFINED NOT NULL,
  titulo character varying NOT NULL,
  descripcion text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_ejercicio_pkey PRIMARY KEY (idejercicio),
  CONSTRAINT fk_ejercicio_capitulo FOREIGN KEY (idcapitulo) REFERENCES public.tbl_capitulo(idcapitulo)
);
CREATE TABLE public.tbl_pregunta (
  idpregunta integer NOT NULL DEFAULT nextval('tbl_pregunta_idpregunta_seq'::regclass),
  idejerciciofk integer NOT NULL,
  contenido text NOT NULL,
  explicacion text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_pregunta_pkey PRIMARY KEY (idpregunta),
  CONSTRAINT fk_pregunta_ejercicio FOREIGN KEY (idejerciciofk) REFERENCES public.tbl_ejercicio(idejercicio)
);
CREATE TABLE public.tbl_opcion (
  idopcion integer NOT NULL DEFAULT nextval('tbl_opcion_idopcion_seq'::regclass),
  idpreguntafk integer NOT NULL,
  contenido text NOT NULL,
  correcta boolean NOT NULL DEFAULT false,
  CONSTRAINT tbl_opcion_pkey PRIMARY KEY (idopcion),
  CONSTRAINT fk_opcion_pregunta FOREIGN KEY (idpreguntafk) REFERENCES public.tbl_pregunta(idpregunta)
);
CREATE TABLE public.tbl_respuesta_usuario (
  id_respuesta integer NOT NULL DEFAULT nextval('tbl_respuesta_usuario_id_respuesta_seq'::regclass),
  id_usuario integer NOT NULL,
  id_pregunta integer NOT NULL,
  id_opcion integer,
  correcta boolean NOT NULL DEFAULT false,
  fecha timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_respuesta_usuario_pkey PRIMARY KEY (id_respuesta),
  CONSTRAINT fk_resp_usuario FOREIGN KEY (id_usuario) REFERENCES public.tbl_usuario(idusuario),
  CONSTRAINT fk_resp_pregunta FOREIGN KEY (id_pregunta) REFERENCES public.tbl_pregunta(idpregunta),
  CONSTRAINT fk_resp_opcion FOREIGN KEY (id_opcion) REFERENCES public.tbl_opcion(idopcion)
);
CREATE TABLE public.tbl_reporte (
  idreporte integer NOT NULL DEFAULT nextval('tbl_reporte_idreporte_seq'::regclass),
  idusuariofk integer NOT NULL,
  entidad_tipo character varying NOT NULL,
  entidad_id integer NOT NULL,
  motivo text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_reporte_pkey PRIMARY KEY (idreporte),
  CONSTRAINT fk_reporte_usuario FOREIGN KEY (idusuariofk) REFERENCES public.tbl_usuario(idusuario)
);
CREATE TABLE public.tbl_configuracion (
  idconfig integer NOT NULL DEFAULT nextval('tbl_configuracion_idconfig_seq'::regclass),
  idusuario integer NOT NULL UNIQUE,
  tema boolean NOT NULL DEFAULT false,
  idioma USER-DEFINED NOT NULL DEFAULT 'es'::tipo_idioma,
  notificaciones_push boolean NOT NULL DEFAULT true,
  notificaciones_email boolean NOT NULL DEFAULT true,
  notificaciones_racha boolean NOT NULL DEFAULT true,
  tamano_fuente USER-DEFINED NOT NULL DEFAULT 'normal'::tipo_fuente,
  reproduccion_auto boolean NOT NULL DEFAULT true,
  perfil_publico boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_configuracion_pkey PRIMARY KEY (idconfig),
  CONSTRAINT fk_config_usuario FOREIGN KEY (idusuario) REFERENCES public.tbl_usuario(idusuario)
);
CREATE TABLE public.tbl_racha (
  id_racha integer NOT NULL DEFAULT nextval('tbl_racha_id_racha_seq'::regclass),
  id_usuario integer NOT NULL UNIQUE,
  current_streak integer NOT NULL DEFAULT 0,
  max_streak integer NOT NULL DEFAULT 0,
  last_activity_date date,
  active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_racha_pkey PRIMARY KEY (id_racha),
  CONSTRAINT fk_racha_usuario FOREIGN KEY (id_usuario) REFERENCES public.tbl_usuario(idusuario)
);
CREATE TABLE public.tbl_evento_aprendizaje (
  id_evento integer NOT NULL DEFAULT nextval('tbl_evento_aprendizaje_id_evento_seq'::regclass),
  id_usuario integer NOT NULL,
  session_id character varying,
  tipo_evento USER-DEFINED NOT NULL,
  entidad_tipo character varying,
  entidad_id integer,
  fecha_evento timestamp with time zone NOT NULL DEFAULT now(),
  duracion integer,
  extra_data jsonb,
  CONSTRAINT tbl_evento_aprendizaje_pkey PRIMARY KEY (id_evento),
  CONSTRAINT fk_evento_usuario FOREIGN KEY (id_usuario) REFERENCES public.tbl_usuario(idusuario)
);
CREATE TABLE public.tbl_progreso_usuario (
  id_progreso integer NOT NULL DEFAULT nextval('tbl_progreso_usuario_id_progreso_seq'::regclass),
  id_usuariofk integer NOT NULL,
  id_capitulofk integer NOT NULL,
  estado USER-DEFINED NOT NULL DEFAULT 'no_iniciada'::tipo_progreso,
  porcentaje_capitulo numeric NOT NULL DEFAULT 0.00,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_progreso_usuario_pkey PRIMARY KEY (id_progreso),
  CONSTRAINT fk_progreso_usuario FOREIGN KEY (id_usuariofk) REFERENCES public.tbl_usuario(idusuario),
  CONSTRAINT fk_progreso_capitulo FOREIGN KEY (id_capitulofk) REFERENCES public.tbl_capitulo(idcapitulo)
);
CREATE TABLE public.tbl_calificacion_leccion (
  idcalificacion integer NOT NULL DEFAULT nextval('tbl_calificacion_leccion_idcalificacion_seq'::regclass),
  idusuariofk integer NOT NULL,
  idleccionfk integer NOT NULL,
  valor smallint NOT NULL,
  comentario text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_calificacion_leccion_pkey PRIMARY KEY (idcalificacion),
  CONSTRAINT fk_calif_lec_usuario FOREIGN KEY (idusuariofk) REFERENCES public.tbl_usuario(idusuario),
  CONSTRAINT fk_calif_lec_leccion FOREIGN KEY (idleccionfk) REFERENCES public.tbl_leccion(idleccion)
);
CREATE TABLE public.tbl_calificacion_curso (
  idcalificacion integer NOT NULL DEFAULT nextval('tbl_calificacion_curso_idcalificacion_seq'::regclass),
  idusuariofk integer NOT NULL,
  idcursofk integer NOT NULL,
  valor smallint NOT NULL,
  comentario text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tbl_calificacion_curso_pkey PRIMARY KEY (idcalificacion),
  CONSTRAINT fk_calif_cur_usuario FOREIGN KEY (idusuariofk) REFERENCES public.tbl_usuario(idusuario),
  CONSTRAINT fk_calif_cur_curso FOREIGN KEY (idcursofk) REFERENCES public.tbl_curso(idcurso)
);