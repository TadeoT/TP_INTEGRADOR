
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

select distinct clasificacion from importacion_caso;

aux_identificador, aux_id_clasificacion, aux_id_pais, aux_id_provincia_residencia,aux_id_provincia_carga,
aux_id_departamento, id_actualizacioncasos, aux_sexo, aux_edad, aux_unidadedad, aux_fechainiciosintomas,
aux_fechaapartura, aux_fechainternacion, aux_cuidadointensivo, aux_fechafallecido, aux_asistenciarespiratoria,
aux_fechadiagnostico, aux_origenfinanciamiento;

select importacion_caso('C:\Users\tadeo\Dropbox\Facultad\Base_de_Datos\TP INTEGRADOR 2\Data','Covid19Casos(cortado).csv')
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
		        SELECT id_evento_caso, ,
		        FROM importacion.caso;
        ruta_nombre_full varchar (200);
        vCantFilas integer;
        result importacion.t_resultado_importacion;
        aux_identificador integer;
        aux_fechaActualizacion date;
        aux_id_fechaactualizacion integer;
        aux_id_clasificacion     smallint;    
        aux_id_pais              smallint;    
        aux_id_provincia_residencia smallint; 
        aux_id_provincia_carga   smallint;
        aux_id_departamento      smallint;    
        aux_id_actualizacioncasos smallinT;
        aux_identificador        smallint;    
        aux_sexo                 varchar(1); 
        aux_edad                 smallint;    
        aux_unidadedad           varchar(2);
        aux_fechainiciosintomas  Date; 
        aux_fechaapartura        Date; 
        aux_fechainternacion     Date;
        aux_cuidadointensivo     BOOLEAN;  
        aux_fechafallecido       DATE;
        aux_asistenciarespiratoria BOOLEAN;
        aux_fechadiagnostico     DATE;
        aux_origenfinanciamiento varchar(8),

BEGIN
        ruta_nombre_full = $1 || '\' || $2;
        DELETE  from importacion.caso;
        EXECUTE 'copy importacion.caso from '''||ruta_nombre_full||''' CSV HEADER DELIMITER '',''  ';

        SELECT ultima_actualizacion INTO aux_fechaActualizacion FROM importacion.caso LIMIT 1;
        -- vemos si existe esa fecha de actualizacion en la tabla actualizacioncasos
        IF NOT EXISTS (select fecha_actualizacion FROM casos.actualizacioncasos 
                                WHERE fecha_actualizacion = aux_fechaActualizacion ) THEN

                            INSERT INTO casos.actualizacioncasos (fecha_actualizacion) VALUES (aux_fechaActualizacion);
							RAISE NOTICE 'insert fecharealizacion';
                            END IF;
        SELECT  id_actualizacioncasos INTO aux_id_fechaactualizacion from casos.actualizacioncasos 
                                    WHERE  fecha_actualizacion = aux_fechaActualizacion;

        SELECT COUNT(1) INTO vCantFilas FROM importacion.caso;
        result.cant_filas := vCantFilas;

        BEGIN
            OPEN cursor_caso;
            LOOP 
            FETCH NEXT 
                    FROM cursor_caso
                    INTO aux_identificador, aux_id_clasificacion, aux_id_pais, aux_id_provincia_residencia,aux_id_provincia_carga,
                        aux_id_departamento, id_actualizacioncasos, aux_sexo, aux_edad, aux_unidadedad, aux_fechainiciosintomas,
                        aux_fechaapartura, aux_fechainternacion, aux_cuidadointensivo, aux_fechafallecido, aux_asistenciarespiratoria,
                        aux_fechadiagnostico, aux_origenfinanciamiento;
            EXIT WHEN NOT FOUND;
            IF aux_fechaActualizacion < '2020-01-01' THEN
                        CONTINUE;
                        END IF;
            IF NOT EXISTS (SELECT * FROM casos.caso
                                        WHERE identificador = aux_identificador
                                        AND id_actualizacioncasos = aux_id_fechaactualizacion) THEN
                                --Creamos una nueva fila
                                RAISE NOTICE 'insert caso';
                                --INSERT INTO casos.determinacionpcr
                                        --VALUES (DEFAULT,id_localidad_concatenado, fecha_aux, total_aux, positivos_aux, origen_aux);
                        ELSE
                                RAISE NOTICE 'insert caso repetido';
                                --Si ya fue registrada la localidad, sumamos los casos
                                --UPDATE casos.determinacionpcr
                                        --SET total = total + total_aux, 
                                        --positivos = positivos + positivos_aux
                                        --WHERE id_localidad = id_localidad_concatenado
                                        --AND origenfinanciamiento = origen_aux AND fecharealizacion = fecha_aux;

                END IF;
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



