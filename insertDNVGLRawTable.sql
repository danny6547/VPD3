/* Adds datetime data to raw data table for given IMO, creating column if necessary */

delimiter //

CREATE PROCEDURE addTimeDNVGLRaw(tablename CHAR(50))
BEGIN

    SET @tablename := tablename;
    
	IF NOT EXISTS( SELECT NULL
    
		FROM INFORMATION_SCHEMA.COLUMNS
	    WHERE table_name = @tablename
		AND table_schema = 'test2'
		AND column_name = 'DateTime_UTC')
        
        THEN CALL addTimeColDNVGLRaw( tablename );
	END IF;
    
    /* Create datetime from inputs */
    
    /*CREATE TABLE tempRaw (id INTEGER PRIMARY KEY AUTO_INCREMENT, idRaw INT, Date_UTC DATE, Time_UTC TIME, DateTime_UTC DATETIME);
    INSERT INTO tempRaw (idRaw, Date_UTC, Time_UTC, DateTime_UTC) SELECT id, Date_UTC, Time_UTC, ADDTIME(Date_UTC, Time_UTC) FROM tablename WHERE IMO_Vessel_Number = IMO;
    SET @sql_text = concat('INSERT INTO tempRaw (idRaw, Date_UTC, Time_UTC, DateTime_UTC) SELECT id, Date_UTC, Time_UTC, ADDTIME(Date_UTC, Time_UTC) FROM ',
		@tablename);
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; */
    
    /* Update */
	/* UPDATE tablename SET DateTime_UTC = ADDTIME(Date_UTC, Time_UTC) WHERE tablename.id IN (SELECT idRaw FROM tempRaw); */
    SET @sql_text = concat('UPDATE ', @tablename, ' SET DateTime_UTC = ADDTIME(Date_UTC, Time_UTC);');
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
    
    /* Remove Temp table*/
	/* DROP TABLE tempRaw; */
END;