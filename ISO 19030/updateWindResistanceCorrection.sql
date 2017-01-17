/* Updates the wind resistance correction */

DROP PROCEDURE IF EXISTS updateWindResistanceCorrection;

delimiter //

CREATE PROCEDURE updateWindResistanceCorrection(imo INT)
BEGIN

	/* UPDATE tempRawISO
	SET Wind_Resistance_Correction = 
		((Wind_Resistance_Relative - Air_Resistance_No_Wind) * Speed_Over_Ground / (SELECT Propulsive_Efficiency FROM SpeedPower WHERE IMO_Vessel_Number = imo)) + 
		Delivered_Power * (1 - (0.7 / (SELECT Propulsive_Efficiency FROM SpeedPower WHERE IMO_Vessel_Number = imo)));
	*/
    
	UPDATE tempRawISO e 
		JOIN
			(SELECT q.id, w.Propulsive_Efficiency, w.Speed, w.Power, q.Delivered_Power FROM tempRawISO q
				JOIN SpeedPower w
					ON q.IMO_Vessel_Number = w.IMO_Vessel_Number AND
						q.NearestDisplacement = w.Displacement AND
						q.NearestTrim = w.Trim
				GROUP BY id) r
		ON e.id = r.id
		SET e.Wind_Resistance_Correction = (
			(e.Wind_Resistance_Relative - e.Air_Resistance_No_Wind) * e.Speed_Over_Ground / r.Propulsive_Efficiency) + 
			e.Delivered_Power * (1 - (0.7 / r.Propulsive_Efficiency)
			)
			;
END;