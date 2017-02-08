/* Set values of displacement in ISO analysis from current draft, trim 
values and diplacement table values */

USE hull_performance;


DROP PROCEDURE IF EXISTS updateDisplacement;

delimiter //

CREATE PROCEDURE updateDisplacement(IMO INT)
BEGIN
	
    DECLARE AdjustedTopArea DOUBLE(10, 5);
        
	IF (SELECT Block_Coefficient FROM Vessels WHERE IMO_Vessel_Number = IMO) IS NULL THEN
	
		/* Calculate Displacement based on Hydrostatic Table */
		UPDATE tempRawISO SET Displacement = (SELECT Displacement FROM Displacement WHERE IMO_Vessel_Number = imo AND
																			Draft_Actual_Fore = (SELECT Draft_Actual_Fore FROM tempRawISO) AND
																			Static_Draught_Aft = (SELECT Static_Draught_Aft FROM tempRawISO));
    
    ELSE
    
		/* Calculate Displacement based on Block Coefficient Approximation */
        SET AdjustedTopArea := (SELECT Block_Coefficient*Length_Overall*Breadth_Moulded FROM Vessels WHERE IMO_Vessel_Number = IMO);
        UPDATE tempRawISO SET Displacement = AdjustedTopArea*( (Static_Draught_Fore + Static_Draught_Aft) / 2);
	
    END IF;
END;