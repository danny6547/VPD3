/* Calculate brake power based on SFOC curve and mass of consumed fuel */

USE hull_performance;


delimiter //

CREATE PROCEDURE updateBrakePower(IMO INT)
BEGIN
	
    /* Declare variables */
    DECLARE X0 DOUBLE(20, 10) DEFAULT 0;
    DECLARE X1 DOUBLE(20, 10) DEFAULT 0;
    DECLARE X2 DOUBLE(20, 10) DEFAULT 0;
    
    /* Get coefficients of SFOC reference curve for engine of this vessel */
    SELECT SFOCCoefficients.X0 INTO X0 FROM SFOCCoefficients
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO);
    SELECT SFOCCoefficients.X1 INTO X1 FROM SFOCCoefficients
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO);
    SELECT SFOCCoefficients.X2 INTO X2 FROM SFOCCoefficients
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO);
    
    /* Perform calculation of Brake Power */
    UPDATE tempRawISO SET Brake_Power = 
										X0
									  + X1 * ( (Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil) / (42.7 * 24) )
									  + X2 * POWER(Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil / (42.7 * 24), 2)
    ;
    
END;