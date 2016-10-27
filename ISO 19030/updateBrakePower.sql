/* Calculate brake power based on SFOC curve */

delimiter //

CREATE PROCEDURE updateBrakePower(IMO INT)
BEGIN
	
    /* Declare variables */
    DECLARE X0 DOUBLE(20, 10) DEFAULT 0;
    DECLARE X1 DOUBLE(20, 10) DEFAULT 0;
    DECLARE X2 DOUBLE(20, 10) DEFAULT 0;
    
    call log_msg(concat('IMO is: ', IMO));
    call log_msg(concat('X0 is: ', X0, ' and X1 is: ', X1, ' and X2 is: ', X2));
    
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
    
    /* SET X0 = (SELECT X0 FROM SFOCCoefficients 
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO));
    SET @X1 := (SELECT X1 FROM SFOCCoefficients 
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO));
    SET X2 := (SELECT X2 FROM SFOCCoefficients 
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO)); */
    
    call log_msg(concat('X0 is: ', X0));
    call log_msg(concat('X1 is: ', X1));
    call log_msg(concat('X2 is: ', X2));
    call log_msg(concat('X0 + X1 is: ', X0 + X1));
    call log_msg(concat('X0 * X1 is: ', X0 * X1));
    
    call log_msg(concat('X1 Term is: ', X1 * (SELECT AVG(Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil)/42.7 FROM tempRawISO)));
    call log_msg(concat('X2 Term is: ', X2 * (SELECT AVG(POWER(Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil / 42.7, 2)) FROM tempRawISO)));
	
    /* SET ShipEngine := (SELECT Engine_Model FROM vessels WHERE IMO_Vessel_Number = IMO);
    SET X0 := (SELECT X0 FROM SFOCCoefficients WHERE Engine_Model = ShipEngine);
    SET X1 := (SELECT X1 FROM SFOCCoefficients WHERE Engine_Model = ShipEngine);
	SET X2 := (SELECT X2 FROM SFOCCoefficients WHERE Engine_Model = ShipEngine); */
    
    /* Calculate brake power from fuel consumption */
    /* UPDATE tempRawISO SET Normalised_Energy_Consumption =  */
    
	/* SET X := (SELECT Mass_Consumed_Fuel_Oil FROM tempRawISO) * (SELECT Lower_Caloirifc_Value_Fuel_Oil FROM tempRawISO) / 42.7;
    SET Y := X2 * (SELECT POWER(X, 2)) + X1 * X + X0;
    
    /* Update table with calculated value for brake power */
    /* UPDATE tempRawISO SET Brake_Power = Y; */
    
    /* UPDATE tempRawISO SET Brake_Power = 
    X2 * (  SELECT POWER((SELECT Mass_Consumed_Fuel_Oil FROM tempRawISO) * (SELECT Lower_Caloirifc_Value_Fuel_Oil FROM tempRawISO) / 42.7, 2) + 
    X1 * ( (SELECT Mass_Consumed_Fuel_Oil FROM tempRawISO) * (SELECT Lower_Caloirifc_Value_Fuel_Oil FROM tempRawISO) / 42.7 ) + 
    X0
    ); */
    
    UPDATE tempRawISO SET Brake_Power = 
										X0
									  + X1 * (Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil) / 42.7
									  + X2 * POWER(Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil / 42.7, 2)
    ;
    
    /* UPDATE tempRawISO SET Brake_Power = 
		(SELECT X0 FROM sfoccoefficients WHERE Engine_Model = ShipEngine)
	  + (SELECT X1 FROM sfoccoefficients WHERE Engine_Model = ShipEngine) * ((Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil) / 42.7)
	  + (SELECT X2 FROM sfoccoefficients WHERE Engine_Model = ShipEngine) * (SELECT POWER(Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil / 42.7, 2))
    ; */
    
END;