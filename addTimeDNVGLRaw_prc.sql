/* Adds datetime data to raw data table for given IMO, creating column if necessary */

delimiter //

CREATE PROCEDURE addTimeDNVGLRaw(IMO int)
BEGIN

	IF NOT EXISTS( SELECT NULL
    
		FROM INFORMATION_SCHEMA.COLUMNS
	    WHERE table_name = 'rawdata'
		AND table_schema = 'test2'
		AND column_name = 'DateTime_UTC')
        
        THEN CALL addTimeColDNVGLRaw;
	END IF;
    
    /* Create datetime from inputs */
    CREATE TABLE tempRaw (id INTEGER PRIMARY KEY AUTO_INCREMENT, idRaw INT, Date_UTC DATE, Time_UTC TIME, DateTime_UTC DATETIME);
    INSERT INTO tempRaw (idRaw, Date_UTC, Time_UTC, DateTime_UTC) SELECT idRaw, Date_UTC, Time_UTC, ADDTIME(Date_UTC, Time_UTC) FROM rawdata WHERE IMO_Vessel_Number = IMO;
    
    /* Update */
	UPDATE rawdata SET DateTime_UTC = ADDTIME(Date_UTC, Time_UTC) WHERE rawdata.id IN (SELECT idRaw FROM tempRaw);
    
    /* Remove Temp table*/ 
	DROP TABLE tempRaw;
END;