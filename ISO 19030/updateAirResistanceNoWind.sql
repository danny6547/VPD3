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
        Transverse_Projected_Area_Current * 
		( SELECT Coefficient FROM WindCoefficientDirection WHERE IMO_Vessel_Number = imo AND 0 BETWEEN Start_Direction AND End_Direction);
        
END;