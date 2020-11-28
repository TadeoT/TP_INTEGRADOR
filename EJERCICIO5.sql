persona_fisica,persona_juridica y organismo_entidad
--- PERSONA FISICA TRIGGER----------------
CREATE TRIGGER trPersona_fisica_I
AFTER
INSERT ON personas.personafisica FOR EACH ROW
EXECUTE PROCEDURE tr_persona_fisica_insert();

CREATE TRIGGER trPersona_fisica_U
AFTER
UPDATE ON personas.personafisica FOR EACH ROW
EXECUTE PROCEDURE tr_persona_fisica_update();
  
CREATE TRIGGER trPersona_fisica_D
AFTER
DELETE ON personas.personafisica FOR EACH ROW
EXECUTE PROCEDURE tr_persona_fisica_delete();

--- PERSONA JURIDICA TRIGGER----------------
CREATE TRIGGER trPersona_juridica_I
AFTER
INSERT ON personas.personajuridica FOR EACH ROW
EXECUTE PROCEDURE tr_persona_juridica_insert();

CREATE TRIGGER trPersona_juridica_U
AFTER
UPDATE ON personas.personajuridica FOR EACH ROW
EXECUTE PROCEDURE tr_persona_juridica_update();

CREATE TRIGGER trPersona_juridica_D
AFTER
DELETE ON personas.personajuridica FOR EACH ROW
EXECUTE PROCEDURE tr_persona_juridica_delete();

--- ORGANISMO ENTIDAD TRIGGER----------------
CREATE TRIGGER trOrganismo_entidad_I
AFTER
INSERT ON personas.organismoentidad FOR EACH ROW
EXECUTE PROCEDURE tr_organismo_entidad_insert();

CREATE TRIGGER trOrganismo_entidad_U
AFTER
UPDATE ON personas.organismoentidad FOR EACH ROW
EXECUTE PROCEDURE tr_organismo_entidad_update();

CREATE TRIGGER trOrganismo_entidad_D
AFTER
DELETE ON personas.organismoentidad FOR EACH ROW
EXECUTE PROCEDURE tr_organismo_entidad_delete();

CREATE TABLE auditoria.log_persona_fisica(
    identificador integer not null,
    usuario varchar(255) not null,
    fecha date not null,
    tipo_instruccion varchar(60) not null,
    valor_previo varchar(255),
    valor_posterior varchar(255)
)

CREATE TABLE auditoria.log_persona_juridica(
    identificador integer not null,
    usuario varchar(255) not null,
    fecha date not null,
    tipo_instruccion varchar(60) not null,
    valor_previo varchar(255),
    valor_posterior varchar(255)
)
CREATE TABLE auditoria.log_organismo_entidad(
    identificador integer not null,
    usuario varchar(255) not null,
    fecha date not null,
    tipo_instruccion varchar(60) not null,
    valor_previo varchar(255),
    valor_posterior varchar(255)
)
----FUNCIONES  FISICA------------
CREATE OR REPLACE FUNCTION tr_persona_fisica_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    INSERT INTO auditoria.log_persona_fisica VALUES (NEW.id,SESSION_USER,(SELECT CURRENT_TIMESTAMP),'INSERT',NULL,NEW);
	RETURN null;
END;
$$

CREATE OR REPLACE FUNCTION tr_persona_fisica_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    INSERT INTO auditoria.log_persona_fisica VALUES (NEW.id,SESSION_USER,(SELECT CURRENT_TIMESTAMP),'UPDATE',OLD,NEW);
	RETURN null;
END;
$$
CREATE OR REPLACE FUNCTION tr_persona_fisica_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    INSERT INTO auditoria.log_persona_fisica VALUES (OLD.id,SESSION_USER,(SELECT CURRENT_TIMESTAMP),'DELETE',OLD,NULL);
	RETURN null;
END;
$$

----FUNCIONES  JURIDICA------------
CREATE OR REPLACE FUNCTION tr_persona_juridica_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    INSERT INTO auditoria.log_persona_juridica VALUES (NEW.id,SESSION_USER,(SELECT CURRENT_TIMESTAMP),'INSERT',NULL,NEW);
	RETURN null;
END;
$$

CREATE OR REPLACE FUNCTION tr_persona_juridica_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    INSERT INTO auditoria.log_persona_juridica VALUES (NEW.id,SESSION_USER,(SELECT CURRENT_TIMESTAMP),'UPDATE',OLD,NEW);
	RETURN null;
END;
$$
CREATE OR REPLACE FUNCTION tr_persona_juridica_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    INSERT INTO auditoria.log_persona_juridica VALUES (OLD.id,SESSION_USER,(SELECT CURRENT_TIMESTAMP),'DELETE',OLD,NULL);
	RETURN null;
END;
$$

----FUNCIONES  ORGANISMO ENTIDAD------------
CREATE OR REPLACE FUNCTION tr_organismo_entidad_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    INSERT INTO auditoria.log_organismo_entidad VALUES (NEW.id,SESSION_USER,(SELECT CURRENT_TIMESTAMP),'INSERT',NULL,NEW);
	RETURN null;
END;
$$

CREATE OR REPLACE FUNCTION tr_organismo_entidad_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    INSERT INTO auditoria.log_organismo_entidad VALUES (NEW.id,SESSION_USER,(SELECT CURRENT_TIMESTAMP),'UPDATE',OLD,NEW);
	RETURN null;
END;
$$
CREATE OR REPLACE FUNCTION tr_organismo_entidad_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    INSERT INTO auditoria.log_organismo_entidad VALUES (OLD.id,SESSION_USER,(SELECT CURRENT_TIMESTAMP),'DELETE',OLD,NULL);
	RETURN null;
END;
$$