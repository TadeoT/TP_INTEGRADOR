
--A
SELECT origenfinanciamiento, EXTRACT(MONTH FROM fecharealizacion) AS mes, count(*) AS cantidad_total From casos.determinacionpcr
	GROUP BY origenfinanciamiento, mes
	ORDER BY cantidad_total DESC
--B
SELECT to_char(A.fecha_actualizacion,'MM') as MES,territorio.provincia.nombre, COUNT(*) AS CASOS,
									COUNT(CASE WHEN id_clasificacion = 2 THEN 1 END) AS CONFIRMADO ,
       								COUNT(CASE WHEN id_clasificacion = 1 THEN 1 END) AS DESCARTADO ,
       								COUNT(CASE WHEN id_clasificacion = 3 THEN 1 END) AS SOSPECHOSO From casos.caso C
							INNER JOIN territorio.provincia ON territorio.provincia.id_provincia = C.id_provincia_residencia
							INNER JOIN casos.actualizacioncasos A ON A.id_actualizacioncasos = C.id_actualizacioncasos
							GROUP BY id_provincia, to_char(A.fecha_actualizacion,'MM')
							ORDER BY to_char(A.fecha_actualizacion,'MM'), id_provincia
--C
SELECT P.nombre,COUNT(CASE WHEN C.id_clasificacion = 2 THEN 1 END) AS "TEST POSITIVO" ,SUM(D.positivos)AS "CASO CONFIRMADO"  FROM casos.determinacionpcr D
		INNER JOIN territorio.localidad L ON L.id_localidad = D.id_localidad
		INNER JOIN territorio.provincia P ON P.id_provincia = L.id_provincia 
		INNER JOIN casos.caso C ON C.id_provincia_carga = P.id_provincia
		GROUP BY P.id_provincia
		ORDER BY (COUNT(CASE WHEN C.id_clasificacion = 2 THEN 1 END)- (SUM(D.positivos)))