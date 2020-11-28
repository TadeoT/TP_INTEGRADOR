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


INSERT INTO territorio.provincia
	VALUES (99,99,'Sin especificar')


SELECT make_sinEspecificar()

CREATE FUNCTION make_sinEspecificar()
RETURNS void
LANGUAGE plpgsql
AS
$$
DECLARE
	cur_provincias CURSOR FOR
		SELECT id_provincia
		FROM territorio.provincia;
	id_aux int;
	codigo_serial int;
BEGIN
	OPEN cur_provincias;
	LOOP
		FETCH NEXT 
		FROM cur_provincias
		INTO id_aux;
	EXIT WHEN NOT FOUND;
	codigo_serial := 99999000 + id_aux;
	INSERT INTO territorio.localidad
		VALUES (codigo_serial, id_aux, NULL, NULL, codigo_serial, 'Sin especificar');
	END LOOP;
END;
$$;


CREATE TYPE importacion.t_resultado_importacion
 AS (
   codigo_resultado int, -- 0 sin errores
   texto_resultado varchar(300),
   cant_filas int, -- cant filas importadas
   texto_detalle varchar(300)
 ); 


CREATE OR REPLACE FUNCTION importacion_determinacionPCR(
        ruta_archivo varchar(120),
        nombre_archivo varchar(120)
)
RETURNS importacion.t_resultado_importacion
LANGUAGE plpgsql
AS
$$
DECLARE
	cursor_determinaciones CURSOR FOR
		SELECT fecha,codigo_indec_provincia, codigo_indec_departamento, codigo_indec_localidad, total, positivos, origen_financiamiento
		FROM importacion.determinacionespcr;
        ruta_nombre_full varchar (200);
        vCantFilas integer;
        result importacion.t_resultado_importacion;
	fecha_aux date;
	codigo_provincia int;
	codigo_localidad int;
	codigo_departamento int;
	total_aux int;
	positivos_aux int;
	origen_aux varchar(30);

	id_localidad_concatenado int;
	id_provincia_aux int;
	nombre_localidad varchar(120);
BEGIN 
        ruta_nombre_full = $1 || '\' || $2;
        DELETE  from importacion.determinacionespcr;
        EXECUTE 'copy importacion.determinacionespcr from '''||ruta_nombre_full||''' CSV HEADER DELIMITER '',''  ';

        result.cant_filas := 0;


        UPDATE importacion.determinacionespcr set positivos = 0 where positivos is null;


        BEGIN
                OPEN cursor_determinaciones;
                LOOP
                FETCH NEXT
                        FROM cursor_determinaciones
                        INTO fecha_aux, codigo_provincia, codigo_departamento, codigo_localidad, total_aux, positivos_aux, origen_aux;
                EXIT WHEN NOT FOUND;
                

                id_provincia_aux := codigo_provincia;

                --Si la fecha es errónea lo cancelamos
                IF fecha_aux < '2020-01-01' THEN
                        CONTINUE;
                        END IF;

                --Si el codigo de provincia no está registrado, usamos la provincia generica 'sin especificar'
                IF codigo_provincia NOT IN (SELECT id_provincia from territorio.provincia) THEN 
                        codigo_provincia := 99;
                        END IF;

                --Si el id de departamento tiene 2 digitos, sumamos 1 cero al final del de provincia
                IF 2 = (length (CAST(codigo_departamento AS varchar))) THEN
                        codigo_provincia =  CAST ( CONCAT(CAST(codigo_provincia AS varchar) ,'0' )  AS INTEGER);	
                ELSE
                --Si el id de departamento tiene 1 digito, sumamos 2 cero al final del de provincia
                        IF 1 = (length (CAST(codigo_departamento AS varchar))) THEN	
                                codigo_provincia =  CAST ( CONCAT(CAST(codigo_provincia AS varchar), '00' )  AS INTEGER);		
                        END IF;
                END IF;
                
                --Si el id de localidad tiene solo 2 digitos, sumamos 1 cero al final del de departamento
                IF 2 = (LENGTH (CAST (codigo_localidad AS varchar))) THEN
                        codigo_departamento = CAST ( CONCAT(CAST(codigo_departamento AS varchar) ,'0' )  AS INTEGER);	
                END IF;



                id_localidad_concatenado = CAST( concat(CAST(codigo_provincia AS varchar), CAST (codigo_departamento AS varchar), CAST (codigo_localidad AS varchar)) as INTEGER);
                IF id_localidad_concatenado NOT IN (SELECT id_localidad FROM territorio.localidad WHERE id_localidad = id_localidad_concatenado) THEN
                        --La insercion se hace en las localidades especial 'Sin determinar'
                        id_localidad_concatenado := 99999000 + id_provincia_aux;
                END IF;
                        
                nombre_localidad = (SELECT nombre FROM territorio.localidad
                        WHERE id_localidad = id_localidad_concatenado);	
                

                IF NOT EXISTS (SELECT * FROM casos.determinacionpcr
                                        WHERE id_localidad = id_localidad_concatenado
                                        AND origenfinanciamiento = origen_aux
                                        AND fecharealizacion = fecha_aux) THEN
                                --Creamos una nueva fila
                                INSERT INTO casos.determinacionpcr
                                        VALUES (DEFAULT,id_localidad_concatenado, fecha_aux, total_aux, positivos_aux, origen_aux);

                                result.cant_filas := result.cant_filas + 1;
                        ELSE
                                --Si ya fue registrada la localidad, sumamos los casos
                                UPDATE casos.determinacionpcr
                                        SET total = total + total_aux, 
                                        positivos = positivos + positivos_aux
                                        WHERE id_localidad = id_localidad_concatenado
                                        AND origenfinanciamiento = origen_aux AND fecharealizacion = fecha_aux;

                                result.cant_filas := result.cant_filas + 1;

                END IF;

                END LOOP;
	        CLOSE cursor_determinaciones;
                result.codigo_resultado := 0;
                result.texto_resultado := 'Importación completada';
                result.texto_detalle := 'Importacion correcta del archivo '|| ruta_nombre_full;
		RETURN result;
        EXCEPTION
                WHEN OTHERS THEN
                result.codigo_resultado := -1;
                result.texto_resultado := 'Importación errónea o incompleta';
                result.texto_detalle := 'ERROR AL PASAR DATOS AL SCHEMA CASOS';
                RAISE NOTICE 'ERROR AL PASAR AL SCHEMA CASOS. ERROR SQLERRM: % SQLSTATE: %', SQLERRM, SQLSTATE;
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
