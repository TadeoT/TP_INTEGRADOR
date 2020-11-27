
create table importacion.caso
(
id_evento_caso integer not null,
sexo varchar(20) not null,
edad  integer  null,
edad_años_meses varchar(20) null,
residencia_pais_nombre varchar(200) null,
residencia_provincia_nombre varchar(200) null,
residencia_departamento_nombre varchar(200) null,
carga_provincia_nombre varchar(200) null,
fecha_inicio_sintomas date null,
fecha_apertura  date null,
sepi_apertura  integer null,
fecha_internacion  date null,
cuidado_intensivo  varchar(2) null,
fecha_cui_intensivo  date null,
fallecido varchar(2) null,
fecha_fallecimiento date null,
asistencia_respiratoria_mecanica varchar(2) null,
carga_provincia_id  integer not null,
origen_financiamiento varchar(30) null,
clasificacion varchar(200) null,
clasificacion_resumen varchar(200) null,
residencia_provincia_id  integer not null,
fecha_diagnostico  date null,
residencia_departamento_id  integer not null,
ultima_actualizacion date not null
)



CREATE OR REPLACE FUNCTION importacion_caso(
        ruta_archivo varchar(120),
        nombre_archivo varchar(120)
)
RETURNS importacion.t_resultado_importacion
LANGUAGE plpgsql
AS
$$
DECLARE 
        cursor_caso CURSOR FOR
		        SELECT id_evento_caso
		        FROM importacion.caso;
        ruta_nombre_full varchar (200);
        vCantFilas integer;
        result importacion.t_resultado_importacion;
        aux_identificador integer;
BEGIN
        ruta_nombre_full = $1 || '\' || $2;
        DELETE  from importacion.caso;
        EXECUTE 'copy importacion.caso from '''||ruta_nombre_full||''' CSV HEADER DELIMITER '',''  ';

        SELECT COUNT(1) INTO vCantFilas FROM importacion.caso;
        result.cant_filas := vCantFilas;

        BEGIN
            OPEN cursor_caso;
            LOOP 
            FETCH NEXT 
                    FROM cursor_caso
                    INTO aux_identificador;
            EXIT WHEN NOT FOUND;

            RAISE NOTICE 'id del caso %', aux_identificador;



            END LOOP;
            CLOSE cursor_caso;
            result.codigo_resultado := 0;
            result.texto_resultado := 'Importación completada';
            result.texto_detalle := 'Importacion correcta del archivo '|| ruta_nombre_full;
		    RETURN result;
		END;
EXCEPTION
        WHEN OTHERS THEN
        result.codigo_resultado := -1;
        result.texto_resultado := 'Importación errónea o incompleta';
        result.texto_detalle := 'ERROR AL PASAR DATOS AL SCHEMA CASOS';
        RAISE NOTICE 'ERROR AL CARGAR DATOS DEL ARCHIVO. ERROR SQLERRM: % SQLSTATE: %', SQLERRM, SQLSTATE;
        RETURN result;
END;
$$;
