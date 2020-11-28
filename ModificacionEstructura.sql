ALTER TABLE territorio.provincia ALTER COLUMN nombre TYPE character varying (120) 

ALTER TABLE territorio.departamento ALTER COLUMN id_departamento TYPE integer
ALTER TABLE territorio.departamento ALTER COLUMN identificador TYPE integer 

ALTER TABLE territorio.localidad ALTER COLUMN id_departamento TYPE integer 
ALTER TABLE territorio.localidad ALTER COLUMN id_departamento DROP NOT NULL;
ALTER TABLE territorio.localidad ALTER COLUMN id_provincia TYPE integer 
ALTER TABLE territorio.localidad ALTER COLUMN id TYPE integer 
ALTER TABLE territorio.localidad ALTER COLUMN identificador TYPE integer 
ALTER TABLE territorio.localidad ALTER COLUMN nombre TYPE character varying (120) 

drop table casos.determinacionpcr

create table casos.determinacionpcr (
   id_determinacionpcr  SERIAL               not null,
   id_localidad         int                  not null,
   fecharealizacion     Date                  not null,
   total                int                  not null,
   positivos            integer               not null,
   origenfinanciamiento varchar(8)             not null,
   constraint chk_origenfinanciamiento check (origenfinanciamiento in ('Público','Privado')),
   constraint pk_determinacionpcr primary key (id_determinacionpcr),
   constraint uk_determinacionpcr unique (fecharealizacion, id_localidad,origenfinanciamiento),
   constraint fk_determinacionpcr_localidad foreign key (id_localidad) references territorio.localidad (id_localidad)
);
create index idx_determinacionpcr_localidad ON casos.determinacionpcr (id_localidad);

ALTER TABLE casos.caso ALTER COLUMN id_caso TYPE integer;
ALTER TABLE casos.caso ALTER COLUMN id_clasificacion TYPE integer;
ALTER TABLE casos.caso ALTER COLUMN id_provincia_carga TYPE integer;
ALTER TABLE casos.caso ALTER COLUMN id_provincia_residencia TYPE integer;
ALTER TABLE casos.caso ALTER COLUMN id_departamento TYPE integer;
ALTER TABLE casos.caso ALTER COLUMN id_actualizacioncasos TYPE integer;
ALTER TABLE casos.caso ALTER COLUMN identificador TYPE integer;
ALTER TABLE casos.caso ALTER COLUMN fechainiciosintomas DROP NOT NULL;
ALTER TABLE casos.caso ALTER COLUMN sexo TYPE character varying (8);
ALTER TABLE casos.caso DROP CONSTRAINT  chk_origenfinanciamiento;
ALTER TABLE casos.caso add  constraint chk_origenfinanciamiento check (origenfinanciamiento in ('Público','Privado')),



CREATE SEQUENCE id_caso_a_seq START WITH 1
ALTER TABLE casos.caso ALTER COLUMN id_caso SET DEFAULT nextval('id_caso_a_seq');

CREATE SEQUENCE actualizacioncasos_a_seq START WITH 1
ALTER TABLE casos.actualizacioncasos ALTER COLUMN id_actualizacioncasos SET DEFAULT nextval('actualizacioncasos_a_seq');


CREATE SEQUENCE clasificacion_a_seq START WITH 1
ALTER TABLE casos.clasificacion ALTER COLUMN id_clasificacion SET DEFAULT nextval('clasificacion_a_seq');

CREATE SEQUENCE codigo_a_seq START WITH 1
ALTER TABLE casos.clasificacion ALTER COLUMN codigo SET DEFAULT nextval('codigo_a_seq');