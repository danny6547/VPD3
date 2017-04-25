/* Remove values of Mass of fuel consumed corresponding to those below the minimum rate of consumption for which SFOC data is available */



DROP PROCEDURE IF EXISTS removeFOCBelowMinimum;

delimiter //

CREATE PROCEDURE removeFOCBelowMinimum(imo INT)
BEGIN
    
    DECLARE FOCmin DOUBLE(10, 3);
    DECLARE HoursPerTimeStep DOUBLE(10, 3) DEFAULT 24;
    
    CALL log_msg('removeFOCBelowMinimum', 'starting');
    
    SET FOCmin = (SELECT Minimum_FOC_ph FROM SFOCCoefficients WHERE Engine_Model = (SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO)) * HoursPerTimeStep;
    /* DELETE FROM tempRawISO WHERE Mass_Consumed_Fuel_Oil < FOCmin; */
    UPDATE tempRawISO SET Filter_SFOC_Out_Range = TRUE WHERE Mass_Consumed_Fuel_Oil < FOCmin;
	
    CALL log_msg('removeFOCBelowMinimum', 'ending');
    
END