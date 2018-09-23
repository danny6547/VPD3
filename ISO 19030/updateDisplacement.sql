/* Set values of displacement in ISO analysis from current draft, trim 
values and diplacement table values */

DROP PROCEDURE IF EXISTS updateDisplacement;

delimiter //

CREATE PROCEDURE updateDisplacement(vcid INT)
proc_something:BEGIN
	
    DECLARE AdjustedTopArea DOUBLE(10, 5);
    
    DECLARE displacementGiven BOOLEAN DEFAULT FALSE;
    DECLARE displacementCalculable BOOLEAN DEFAULT TRUE;
    
    SET displacementGiven = (SELECT COUNT(*) FROM tempRawISO WHERE Displacement IS NOT NULL) > 0;
    
    IF displacementGiven THEN
		LEAVE proc_something;
	END IF;
        
	IF (SELECT Block_Coefficient FROM `static`.vesselconfiguration WHERE vessel_configuration_id = vcid) IS NULL THEN
	
		/* Calculate Displacement based on Hydrostatic Table */
		UPDATE tempRawISO SET Displacement = (SELECT Displacement FROM `static`.Displacement WHERE IMO_Vessel_Number = imo AND
																			Static_Draught_Fore = (SELECT Static_Draught_Fore FROM tempRawISO) AND
																			Static_Draught_Aft = (SELECT Static_Draught_Aft FROM tempRawISO));
    ELSE

		/* Calculate Displacement based on Block Coefficient Approximation */
        SET AdjustedTopArea := (SELECT Block_Coefficient*Length_Overall*Breadth_Moulded FROM `static`.vesselconfiguration WHERE vessel_configuration_id = vcid);
        UPDATE tempRawISO SET Displacement = AdjustedTopArea*( (Static_Draught_Fore + Static_Draught_Aft) / 2);
	
    END IF;
END;