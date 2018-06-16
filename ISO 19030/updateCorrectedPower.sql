/* Correct delivered power values for environmental factors. */



DROP PROCEDURE IF EXISTS updateCorrectedPower;

delimiter //

CREATE PROCEDURE updateCorrectedPower()
BEGIN
    
    DECLARE WindResValid BOOLEAN;
    SET WindResValid := (SELECT COUNT(Wind_Resistance_Correction) FROM `inservice`.tempRawISO) != 0;
    
    IF WindResValid THEN
		UPDATE `inservice`.tempRawISO SET Corrected_Power = Delivered_Power - Wind_Resistance_Correction;
    ELSE
		UPDATE `inservice`.tempRawISO SET Corrected_Power = Delivered_Power;
	END IF;
    
    /*IF @imo IS NOT NULL AND @startd IS NOT NULL AND @endd IS NOT NULL THEN*/
		CALL IMOStartEnd(@imo, @startd, @endd);
		INSERT INTO `inservice`.Analysis (IMO_Vessel_Number, StartDate, EndDate, WindResistanceApplied) 
		VALUES (@imo, @startd, @endd, WindResValid) ON duplicate key update WindResistanceApplied = values(WindResistanceApplied);
    /*END IF;*/
END;