CREATE schema importacion

-----------------------
-- PROVINCIAS
-----------------------
create table importacion.provincia
(
categoria varchar(30) not null,
centroide_lat decimal not null,
centroide_lon decimal not null,
fuente varchar(30) not null,
id integer not null,
iso_id varchar(30) not null,
iso_nombre varchar(120) not null ,
nombre varchar(120) not null,
nombre_completo varchar(120) not null
)

copy importacion.provincia from 'C:\Users\tadeo\Dropbox\Facultad\Base_de_Datos\TP INTEGRADOR 2\Data\provincias.csv' with delimiter ',' CSV HEADER;

select * from importacion.provincia 

-----------------------
-- DEPARTAMENTOS
-----------------------
CREATE table importacion.departamento
(
categoria varchar(30) not null,
centroide_lat decimal not null,
centroide_lon decimal not null,
fuente varchar(120) not null,
id integer not null,
nombre varchar(120) not null,
nombre_completo varchar(120) not null,
provincia_id integer not null,
provincia_interseccion decimal not null,
provincia_nombre varchar(120) not null
)

copy importacion.departamento from 'C:\Users\tadeo\Dropbox\Facultad\Base_de_Datos\TP INTEGRADOR 2\Data\departamentos.csv' with delimiter ',' CSV HEADER;

-----------------------
-- LOCALIDADES
-----------------------

CREATE table importacion.localidad
(
categoria varchar(120) not null,
centroide_lat decimal not null,
centroide_lon decimal not null,
departamento_id varchar(30),
departamento_nombre varchar(120) not null,
fuente varchar(30) not null,
funcion varchar(30) null,
id integer not null,
municipio_id varchar(30) not null,
municipio_nombre varchar(120) not null,
nombre varchar (120) not null,
provincia_id integer not null,
provincia_nombre varchar (120) not null
)

UPDATE importacion.localidad SET departamento_id = NULL  where departamento_id = ''


copy importacion.localidad from 'C:\Users\tadeo\Dropbox\Facultad\Base_de_Datos\TP INTEGRADOR 2\Data\localidades-censales.csv' with delimiter ',' CSV HEADER;





-------------------- PASAMOS AL SCHEMA TERRITORIO-------------------------------------

INSERT INTO territorio.provincia (id_provincia,identificador,nombre) 
        SELECT i.id, i.id, i.nombre_completo FROM importacion.provincia i


INSERT INTO territorio.departamento (id_departamento,id_provincia,identificador,nombre) 
        SELECT d.id, d.provincia_id, d.id, d.nombre_completo FROM importacion.departamento d


INSERT INTO territorio.localidad (id_localidad,id_provincia,id_departamento,identificador,nombre) 
        SELECT l.id, l.provincia_id, CAST(l.departamento_id AS integer), l.id, l.nombre FROM importacion.localidad l