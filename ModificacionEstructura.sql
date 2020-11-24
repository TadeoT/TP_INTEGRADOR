ALTER TABLE territorio.provincia ALTER COLUMN nombre TYPE character varying (120) 

ALTER TABLE territorio.departamento ALTER COLUMN id_departamento TYPE integer
ALTER TABLE territorio.departamento ALTER COLUMN identificador TYPE integer 

ALTER TABLE territorio.localidad ALTER COLUMN id_departamento TYPE integer 
ALTER TABLE territorio.localidad ALTER COLUMN id_departamento DROP NOT NULL;
ALTER TABLE territorio.localidad ALTER COLUMN id_provincia TYPE integer 
ALTER TABLE territorio.localidad ALTER COLUMN id TYPE integer 
ALTER TABLE territorio.localidad ALTER COLUMN identificador TYPE integer 
ALTER TABLE territorio.localidad ALTER COLUMN nombre TYPE character varying (120) 