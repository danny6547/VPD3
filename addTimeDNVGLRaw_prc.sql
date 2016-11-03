/* Adds datetime data to raw data table for given IMO, creating column if necessary */

delimiter //

CREATE PROCEDURE addTimeDNVGLRaw()
BEGIN
	
	IF NOT EXISTS( SELECT NULL
		
		FROM INFORMATION_SCHEMA.COLUMNS
	    WHERE table_name = 'tempraw'
		AND table_schema = 'test2'
		AND column_name = 'DateTime_UTC')
        
        THEN CALL addTimeColDNVGLRaw('tempraw');
	END IF;
    
    /* Update */
	UPDATE tempraw SET DateTime_UTC = ADDTIME(Date_UTC, Time_UTC);
    
END;