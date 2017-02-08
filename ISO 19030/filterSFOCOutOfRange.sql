/* Create filter to remove data corresponding to brake power values below 
the minimum or above the maximum of the available engine test data. */

USE hull_performance;


DROP PROCEDURE IF EXISTS filterSFOCOutOfRange;

delimiter //

CREATE PROCEDURE filterSFOCOutOfRange(imo INT)

BEGIN
    
    UPDATE tempRawISO SET Filter_SFOC_Out_Range = CASE
		WHEN Brake_Power < (SELECT Lowest_Given_Brake_Power FROM sfoccoefficients WHERE Engine_Model = (SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = imo)) OR 
			Brake_Power > (SELECT Highest_Given_Brake_Power FROM sfoccoefficients WHERE Engine_Model = (SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = imo)) THEN TRUE
        ELSE FALSE
    END;
END;