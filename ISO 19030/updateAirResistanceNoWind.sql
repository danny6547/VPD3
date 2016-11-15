/* Update Air Resistance in no-wind condition */

DROP PROCEDURE IF EXISTS updateAirResistanceNoWind;

delimiter //

CREATE PROCEDURE updateAirResistanceNoWind(imo INT)
BEGIN
	
	UPDATE tempRawISO
	SET Air_Resistance_No_Wind = 
		0.5 * 
		Air_Density * 
		POWER(Speed_Over_Ground, 2) * 
		( SELECT Transverse_Projected_Area_Design FROM Vessels WHERE IMO = imo) * 
		( SELECT Coefficient FROM WindCoefficientDirection WHERE IMO = imo AND Start_Direction = 0);
	
END;