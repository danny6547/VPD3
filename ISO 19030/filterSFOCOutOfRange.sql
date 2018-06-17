/* Create filter to remove data corresponding to brake power values below 
the minimum or above the maximum of the available engine test data. */

DROP PROCEDURE IF EXISTS filterSFOCOutOfRange;

delimiter //

CREATE PROCEDURE filterSFOCOutOfRange(vcid INT)

BEGIN
    
    UPDATE `inservice`.tempRawISO SET Filter_SFOC_Out_Range = CASE
		WHEN Brake_Power < (SELECT Lowest_Given_Brake_Power FROM `static`.sfoccoefficients WHERE Engine_Model_Id = (SELECT Engine_Model_Id FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid)) OR 
			Brake_Power > (SELECT Highest_Given_Brake_Power FROM `static`.sfoccoefficients WHERE Engine_Model_Id = (SELECT Engine_Model_Id FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid)) THEN TRUE
        ELSE FALSE
    END;
END;