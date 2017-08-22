/* Sort data by time */

DROP PROCEDURE IF EXISTS performanceData;

delimiter //

CREATE PROCEDURE performanceData(imo INT(7), ddi INT, OUT intervalStart DATETIME, OUT intervalEnd DATETIME, OUT ddinterval INT)
proc_label:BEGIN
	
	DECLARE ddiBefore INT;
	DECLARE ddiAfter INT;
	DECLARE intervalStartDate DATETIME;
	DECLARE intervalEndDate DATETIME;
    DECLARE numDD INT;
	DECLARE maxDate DATETIME;
    DECLARE numData INT;
    DECLARE dateMissing BOOLEAN;
    
    /* Get constants */
    SET maxDate = '9999-12-31 23:59:59';
    
    /* Get the number of dry-dockings for this vessel */
    SET numDD = (SELECT COUNT(*) FROM DryDockDates WHERE IMO_Vessel_Number = imo);
    
    /* Make DDi Zero-based, as in LIMIT statement */
    SET ddi = ddi - 1;
    
    /* Get indices to dry docking dates from dry-docking interval index */
    SET ddiBefore = ddi - 1;
    SET ddiAfter = ddi;
    
	/* Assign dates for when interval is neither first not last: interval runs from end of previous dry-docking to start of next dry-docking */
	SET intervalStartDate = (SELECT EndDate FROM DryDockDates WHERE IMO_Vessel_Number = imo LIMIT ddiBefore, 1);
	SET intervalEndDate = (SELECT StartDate FROM DryDockDates WHERE IMO_Vessel_Number = imo LIMIT ddiAfter, 1);
    
    /* Assign outputs */
    SET intervalStart := intervalStartDate;
    SET intervalEnd := intervalEndDate;
    
    /* If first interval requested but no dry-dock dates found, return all data */
    SET dateMissing = (SELECT COUNT(intervalEndDate) FROM DryDockDates WHERE IMO_Vessel_Number = imo) = 0;
    IF ddi = 0 AND dateMissing THEN
		
		SET intervalEndDate := (SELECT MAX(DateTime_UTC) FROM PerformanceData WHERE IMO_Vessel_Number = imo);
    END IF;
    
    IF ddi = 0 THEN
		
		/* When first dry-dock interval requested, lookn for data after the earliest possible date */
		SET intervalStartDate = '1000-01-01 00:00:00';
		SET intervalStart := (SELECT MIN(DateTime_UTC) FROM PerformanceData WHERE IMO_Vessel_Number = imo);
        
    ELSEIF ddi >= numDD THEN
		
        /* When last dry-dock interval requested, look for data until the latest possible date */
		SET intervalEndDate = '9999-12-31 23:59:59';
		SET intervalEnd := (SELECT MAX(DateTime_UTC) FROM PerformanceData WHERE IMO_Vessel_Number = imo);
        
	ELSEIF ddi IS NULL THEN
        
        /* When no dry-dock interval requested, look for data for all times */
		SET intervalStartDate = '1000-01-01 00:00:00';
		SET intervalEndDate = '9999-12-31 23:59:59';
		SET intervalStart := (SELECT MIN(DateTime_UTC) FROM PerformanceData WHERE IMO_Vessel_Number = imo);
		SET intervalEnd := (SELECT MAX(DateTime_UTC) FROM PerformanceData WHERE IMO_Vessel_Number = imo);
    END IF;
    
    /* If no data found between two dry-dockings, return non-empty null table */
    SET numData = (SELECT COUNT(*) FROM PerformanceData WHERE IMO_Vessel_Number = imo
																					AND DateTime_UTC > intervalStartDate
																					AND DateTime_UTC < intervalEndDate);
    IF numData = 0 AND intervalEndDate != maxDate THEN
		
        SELECT NULL AS 'DateTime_UTC', NULL AS 'Performance_Index', NULL AS 'Speed_Index';
        LEAVE proc_label;
    END IF;
    
    /* Select output table */
    SELECT DateTime_UTC, Performance_Index, Speed_Index FROM PerformanceData WHERE IMO_Vessel_Number = imo
																					AND DateTime_UTC > intervalStartDate
																					AND DateTime_UTC < intervalEndDate;
                                                                                    
    /* Assign dry dock index to output */
    SET ddinterval = ddi + 1;
END