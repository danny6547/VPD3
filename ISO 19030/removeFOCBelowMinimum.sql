/* Remove values of Mass of fuel consumed corresponding to those below the minimum hourly rate of consumption for which SFOC data is available */

delimiter //

CREATE PROCEDURE removeFOCBelowMinimum(imo INT)
BEGIN
	
    DECLARE FOCmin DOUBLE(10, 3);
    DECLARE HoursPerTimeStep DOUBLE(10, 3) DEFAULT 24;
    
    SET FOCmin = (SELECT Minimum_FOC_ph FROM SFOCCoefficients WHERE Engine_Model = (SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO)) * HoursPerTimeStep;
    CALL log_msg(concat('focmin = ', FOCmin));
    DELETE FROM tempRawISO WHERE Mass_Consumed_Fuel_Oil < FOCmin;
	
END