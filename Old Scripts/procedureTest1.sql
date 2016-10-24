delimiter //

CREATE PROCEDURE addTimeDNVGLRaw_prc ()
BEGIN

    IF EXISTS( SELECT NULL
    
		FROM INFORMATION_SCHEMA.COLUMNS
	   WHERE table_name = 'rawdata'
		 AND table_schema = 'test2'
		 AND column_name = 'DateTime_UTC')
		 THEN ALTER TABLE rawdata ADD DateTime_UTC DATETIME AFTER Date_UTC;
	END IF;
END;
