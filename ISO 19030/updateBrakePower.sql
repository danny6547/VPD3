/* Calculate brake power based on SFOC curve */


delimiter //

CREATE PROCEDURE updateBrakePower(IMO INT)
BEGIN
	
    /* Declare variables */
    DECLARE X0 INT;
    DECLARE X1 INT;
    DECLARE X2 INT;
    DECLARE X DOUBLE(10, 5);
    DECLARE Y DOUBLE(10, 5);
    
    /* Get coefficients of SFOC reference curve for engine of this vessel */
    SET X0 := (SELECT XO FROM SFOCCoefficients 
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO));
    SET X1 := (SELECT X1 FROM SFOCCoefficients 
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO));
    SET X2 := (SELECT X2 FROM SFOCCoefficients 
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO));
	
    SET X0 := (SELECT X0 FROM Vessels WHERE IMO_Vessel_Number = IMO);
    SET X1 := (SELECT X1 FROM Vessels WHERE IMO_Vessel_Number = IMO);
	SET X2 := (SELECT X2 FROM Vessels WHERE IMO_Vessel_Number = IMO);
    
    /* Calculate brake power from fuel consumption */
	SET X := (SELECT Mass_Consumed_Fuel_Oil FROM tempRawISO) * (SELECT Lower_Caloirifc_Value_Fuel_Oil FROM tempRawISO) / 42.7;
    SET Y := X2 * (SELECT POWER(X, 2)) + X1 * X + X0;
    
    /* Update table with calculated value for brake power */
    UPDATE tempRawISO SET Mass_Consumed_Fuel_Oil = Y;
    
END;