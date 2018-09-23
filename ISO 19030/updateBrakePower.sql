/* Calculate brake power based on SFOC curve and mass of consumed fuel */


DROP PROCEDURE IF EXISTS updateBrakePower;

delimiter //

CREATE PROCEDURE updateBrakePower(vid INT)
BEGIN
	
    /* Declare variables */
    DECLARE X0 DOUBLE(20, 10) DEFAULT 0;
    DECLARE X1 DOUBLE(20, 10) DEFAULT 0;
    DECLARE X2 DOUBLE(20, 10) DEFAULT 0;
    
    /* Get coefficients of SFOC reference curve for engine of this vessel */
    SELECT `static`.enginemodel.X0 INTO X0 FROM `static`.enginemodel
			WHERE Engine_Model_Id = 
				(SELECT Engine_Model_Id FROM `static`.VesselConfiguration WHERE Vessel_Id = vid);
    SELECT `static`.enginemodel.X1 INTO X1 FROM `static`.enginemodel
			WHERE Engine_Model_Id = 
				(SELECT Engine_Model_Id FROM `static`.VesselConfiguration WHERE Vessel_Id = vid);
    SELECT `static`.enginemodel.X2 INTO X2 FROM `static`.enginemodel
			WHERE Engine_Model_Id = 
				(SELECT Engine_Model_Id FROM `static`.VesselConfiguration WHERE Vessel_Id = vid);
    
    /* Perform calculation of Brake Power */
    UPDATE tempRawISO SET Brake_Power = 
										X0
									  + X1 * ( (Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil) / (42.7 * 24) )
									  + X2 * POWER(Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil / (42.7 * 24), 2);
END;