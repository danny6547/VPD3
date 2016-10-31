/* Update Air Resistance in no-wind condition */

delimiter //

CREATE PROCEDURE updateAirResistanceNoWind(imo INT)
BEGIN
	
    /* DECLARE WindResCoeff DOUBLE(10, 5); */
    CALL log_msg(concat('Air_Density = ', (SELECT AVG(Air_Density) FROM tempRawIso)));
    CALL log_msg(concat('Relative_Wind_Speed = ', (SELECT AVG(Speed_Over_Ground) FROM tempRawIso)));
    CALL log_msg(concat('Transverse_Projected_Area_Design = ', (SELECT Transverse_Projected_Area_Design FROM Vessels WHERE IMO_Vessel_Number = imo)));
    CALL log_msg(concat('Coefficient = ', (SELECT Coefficient FROM WindCoefficientDirection WHERE IMO = imo AND Start_Direction = 0)));
    
	UPDATE tempRawISO
	SET Air_Resistance_No_Wind = 
		0.5 * 
		Air_Density * 
		POWER(Speed_Over_Ground, 2) * 
		( SELECT Transverse_Projected_Area_Design FROM Vessels WHERE IMO = imo) * 
		( SELECT Coefficient FROM WindCoefficientDirection WHERE IMO = imo AND Start_Direction = 0);
	
END;