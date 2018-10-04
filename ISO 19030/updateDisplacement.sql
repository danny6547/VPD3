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
    
    SET @Disp_ID := (SELECT Displacement_Model_Id FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid);
	IF (SELECT Block_Coefficient FROM `static`.vesselconfiguration WHERE vessel_configuration_id = vcid) IS NULL THEN
		
		/* Calculate Displacement based on Hydrostatic Table */
		UPDATE tempRawISO t
			JOIN `static`.DisplacementModelValue d
				ON t.Trim = d.Trim
				AND (t.Static_Draught_Fore + t.Static_Draught_Aft)/2 = d.Draft_Mean
		SET t.Displacement = d.Displacement;
    ELSE
		
		/* Calculate Displacement based on Block Coefficient Approximation */
        SET AdjustedTopArea := (SELECT Block_Coefficient*Length_Overall*Breadth_Moulded FROM `static`.vesselconfiguration WHERE vessel_configuration_id = vcid);
        UPDATE tempRawISO SET Displacement = AdjustedTopArea*( (Static_Draught_Fore + Static_Draught_Aft) / 2);
    END IF;
END;