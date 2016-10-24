delimiter //

CREATE PROCEDURE addTimeColDNVGLRaw (tablename CHAR(50))
BEGIN

    SET @tablename := tablename;
    
    IF EXISTS( SELECT NULL
    
		FROM INFORMATION_SCHEMA.COLUMNS
	    WHERE table_name = @tablename
		AND table_schema = 'test2'
		AND column_name = 'DateTime_UTC')
		THEN SELECT('Column "DateTime_UTC" already exists in Table "rawdata". The table is not affected.');
	ELSE
    
		/* ALTER TABLE tablename ADD DateTime_UTC DATETIME AFTER Date_UTC; */
        
        SET @sql_text = concat('ALTER TABLE ', @tablename, ' ADD DateTime_UTC DATETIME AFTER Date_UTC;');
        
        PREPARE stmt FROM @sql_text;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
        
	END IF;
END;
