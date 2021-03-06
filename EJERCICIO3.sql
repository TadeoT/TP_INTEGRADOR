
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
INSERT INTO personas.pais (id,codigo,nombre) VALUES (1,1,'Argentina')
INSERT INTO personas.pais (id,codigo,nombre) VALUES (0,0,'SIN ESPECIFICAR')
INSERT INTO casos.clasificacion (id_clasificacion,codigo,descripcion) VALUES (1,1,'Descartado');
INSERT INTO casos.clasificacion (id_clasificacion,codigo,descripcion) VALUES (2,2,'Confirmado');
INSERT INTO casos.clasificacion (id_clasificacion,codigo,descripcion) VALUES (3,3,'Sospechoso');


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
		        SELECT id_evento_caso, clasificacion_resumen, residencia_pais_nombre, residencia_provincia_id, carga_provincia_id,
                        sexo, edad, edad_años_meses, fecha_inicio_sintomas, fecha_apertura, fecha_internacion, cuidado_intensivo, fecha_fallecimiento,
                        asistencia_respiratoria_mecanica, fecha_diagnostico, origen_financiamiento, residencia_departamento_id
		        FROM importacion.caso;
        ruta_nombre_full varchar (200);
        vCantFilas integer;
        result importacion.t_resultado_importacion;
        aux_identificador integer;
        aux_fechaActualizacion date;
        aux_id_fechaactualizacion integer;
        aux_id_clasificacion     varchar(200);
        aux_id_clasificacion2     smallint;    
        aux_id_pais              varchar(200);
	aux_id_pais2              smallint;    
        aux_id_provincia_residencia smallint; 
        aux_id_provincia_carga   smallint;
        aux_id_departamento      smallint;
	aux_id_departamento2      int;    
        aux_id_actualizacioncasos smallint;  
        aux_sexo                 varchar(8); 
        aux_edad                 smallint;    
        aux_unidadedad           varchar(8);
        aux_fechainiciosintomas  Date; 
        aux_fechaapartura        Date; 
        aux_fechainternacion     Date;
        aux_cuidadointensivo     varchar(8);  
        aux_cuidadointensivo2   BOOLEAN;
        aux_fechafallecido       DATE;
        aux_asistenciarespiratoria varchar(8);
        aux_asistenciarespiratoria2 BOOLEAN;
        aux_fechadiagnostico     DATE;
        aux_origenfinanciamiento varchar(8);

BEGIN
	RAISE NOTICE 'Inicia carga datos';
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
        
        result.cant_filas := 0;
        BEGIN
            OPEN cursor_caso;
            LOOP 
            FETCH NEXT 
                    FROM cursor_caso
                    INTO aux_identificador, aux_id_clasificacion, aux_id_pais, aux_id_provincia_residencia,aux_id_provincia_carga,
                        aux_sexo, aux_edad, aux_unidadedad, aux_fechainiciosintomas,
                        aux_fechaapartura, aux_fechainternacion, aux_cuidadointensivo, aux_fechafallecido, aux_asistenciarespiratoria,
                        aux_fechadiagnostico, aux_origenfinanciamiento, aux_id_departamento;
            EXIT WHEN NOT FOUND;
            IF aux_fechaActualizacion < '2020-01-01' THEN
                        CONTINUE;
                        END IF;
		
		---Correcion id departamento
		IF aux_id_departamento = 0 THEN
			aux_id_departamento2 := NULL;
		ELSE
			If aux_id_provincia_residencia = 2 THEN
				aux_id_departamento2 := 2000 + (aux_id_departamento*7);
			ELSE
				IF length (CAST (aux_id_departamento AS varchar)) = 2 THEN
					aux_id_departamento2 = CAST( concat(CAST(aux_id_provincia_residencia AS varchar),'0', CAST (aux_id_departamento AS varchar)) as INTEGER);					
				ELSE
					IF length (CAST (aux_id_departamento AS varchar)) = 1 THEN
						aux_id_departamento2 = CAST( concat(CAST(aux_id_provincia_residencia AS varchar),'00', CAST (aux_id_departamento AS varchar)) as INTEGER);
					ELSE
						aux_id_departamento2 = CAST( concat(CAST(aux_id_provincia_residencia AS varchar), CAST (aux_id_departamento AS varchar)) as INTEGER);
					END IF;
				END IF;			
			END IF;
		END IF;
	
		--
		IF aux_id_clasificacion = 'Descartado' THEN
		    aux_id_clasificacion2 := 1;
		ELSE
			IF aux_id_clasificacion = 'Confirmado' THEN
				aux_id_clasificacion2 := 2;
			ELSE
				IF aux_id_clasificacion = 'Sospechoso' THEN
					aux_id_clasificacion2 := 3;
				END IF;
			END IF;
		END IF;
		--
		IF aux_id_pais = 'Argentina' THEN 
			aux_id_pais2 := 1;
		ELSE
			IF aux_id_pais = 'SIN ESPECIFICAR' THEN 
				aux_id_pais2 := 0;
			END IF;
		END IF;
		--
                IF aux_cuidadointensivo = 'SI' THEN 
                        aux_cuidadointensivo2 := true;
                ELSE   
                        IF aux_cuidadointensivo = 'NO' THEN
                                aux_cuidadointensivo2 := false;
                        END IF;
                END IF;
		--
                IF aux_asistenciarespiratoria = 'SI' THEN 
                        aux_asistenciarespiratoria2 := true;
                ELSE   
                        IF aux_asistenciarespiratoria = 'NO' THEN
                                aux_asistenciarespiratoria2 := false;
                        END IF;
                END IF;                
                                
	
            IF NOT EXISTS (SELECT * FROM casos.caso
                                        WHERE identificador = aux_identificador
                                        AND id_actualizacioncasos = aux_id_fechaactualizacion) THEN
                                --Creamos una nueva fila
                                RAISE NOTICE 'insert caso';
                                INSERT INTO casos.caso(id_clasificacion, id_pais, id_provincia_residencia, id_provincia_carga, id_departamento,
														id_actualizacioncasos,identificador,sexo,edad,unidadedad,fechainiciosintomas,
														fechaapartura, fechainternacion, cuidadointensivo, fechafallecido,asistenciarespiratoria,
														fechadiagnostico,origenfinanciamiento)
                                        VALUES (aux_id_clasificacion2, aux_id_pais2, 
                                                aux_id_provincia_residencia,aux_id_provincia_carga,
                                                aux_id_departamento2 ,aux_id_fechaactualizacion,aux_identificador,
                                                aux_sexo, aux_edad, aux_unidadedad, aux_fechainiciosintomas, 
												aux_fechaapartura, aux_fechainternacion, aux_cuidadointensivo2, aux_fechafallecido, aux_asistenciarespiratoria2,
                                                aux_fechadiagnostico, aux_origenfinanciamiento);
				result.cant_filas := result.cant_filas + 1;
                        ELSE
                                RAISE NOTICE 'este caso esta repetido NO SE INSERTO';
                END IF;
            RAISE NOTICE 'id del caso %', aux_identificador;
            END LOOP;
            CLOSE cursor_caso;
            result.codigo_resultado := 0;
            result.texto_resultado := 'Importación completada';
            result.texto_detalle := 'Importacion correcta del archivo '|| ruta_nombre_full;
	    RAISE NOTICE 'Se insertaron % filas en total', result.cant_filas;
		    RETURN result;
        EXCEPTION
             WHEN OTHERS THEN
		---- La BD nos detalla cual fue el error, y si alguna constraint fue violada
                result.codigo_resultado := -1;
                result.texto_resultado := 'Importación errónea o incompleta';
                result.texto_detalle := 'ERROR AL PASAR DATOS AL SCHEMA CASOS';
                RAISE NOTICE 'ERROR AL PASAR DATOS AL SCHEMA CASOS. ERROR SQLERRM: % SQLSTATE: %', SQLERRM, SQLSTATE;
		----- Borramos la tabla auxiliar, ya que conteiene datos erroneos que no pueden ser cargados
		TRUNCATE TABLE importacion.casos;
        RETURN result;
		END;
	----- Borramos los datos de la tabla temporal, siendo que ya están cargados
	    TRUNCATE TABLE importacion.casos;
EXCEPTION
        WHEN OTHERS THEN
        result.codigo_resultado := -1;
        result.texto_resultado := 'Importación errónea o incompleta';
        result.texto_detalle := 'ERROR AL CARGAR LOS DATOS DESDE EL ARCHIVO';
        RAISE NOTICE 'ERROR AL CARGAR DATOS DEL ARCHIVO. ERROR SQLERRM: % SQLSTATE: %', SQLERRM, SQLSTATE;
        RETURN result;
END;
$$;