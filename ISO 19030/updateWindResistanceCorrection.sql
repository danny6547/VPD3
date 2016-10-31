/* Updates the wind resistance correction */

delimiter //

CREATE PROCEDURE updateWindResistanceCorrection(imo INT)
BEGIN

	UPDATE tempRawISO
	SET Wind_Resistance_Correction = 
		((Wind_Resistance_Relative - Air_Resistance_No_Wind) * Speed_Over_Ground / (SELECT Propulsive_Efficiency FROM SpeedPower WHERE IMO_Vessel_Number = imo)) + 
		Delivered_Power * (1 - (0.7 / (SELECT Propulsive_Efficiency FROM SpeedPower WHERE IMO_Vessel_Number = imo)));
	
END;