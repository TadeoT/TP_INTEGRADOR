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
   id_localidad         smallint              not null,
   fecharealizacion     Date                  not null,
   total                smallint              not null,
   positivos            integer               not null,
   origenfinanciamiento varchar(8)             not null,
   constraint chk_origenfinanciamiento check (origenfinanciamiento in ('Público','Privado')),
   constraint pk_determinacionpcr primary key (id_determinacionpcr),
   constraint uk_determinacionpcr unique (fecharealizacion, id_localidad,origenfinanciamiento),
   constraint fk_determinacionpcr_localidad foreign key (id_localidad) references territorio.localidad (id_localidad)
);
create index idx_determinacionpcr_localidad ON casos.determinacionpcr (id_localidad);