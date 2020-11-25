create table importacion.determinacionesPCR
(
fecha  date not null,
provincia varchar(200) not null,
codigo_indec_provincia int not null,
departamento  varchar(200) not null,
codigo_indec_departamento int not null,
localidad varchar(200) not null,
codigo_indec_localidad int not null,
origen_financiamiento varchar(30) null,
tipo varchar(30) null,
ultima_actualizacion date not null,
total integer not null,
positivos integer null
)


copy importacion.determinacionesPCR from 'C:\Users\tadeo\Dropbox\Facultad\Base_de_Datos\TP INTEGRADOR 2\Data\Covid19Determinaciones(15-11).csv' with delimiter ',' CSV HEADER;


select *
from importacion.determinacionespcr
begin transaction
UPDATE importacion.determinacionespcr set positivos = 0 where positivos is null
commit transaction



INSERT INTO casos.determinacionpcr (id_localidad,fecharealizacion,total,positivos,origenfinanciamiento) 
        SELECT  d.codigo_indec_localidad, d.fecha, d.total, d.positivos,d.origen_financiamiento FROM importacion.determinacionespcr d


