/* Updates the wind resistance correction based on equation G2. */



DROP PROCEDURE IF EXISTS updateWindResistanceCorrection;

delimiter //

CREATE PROCEDURE updateWindResistanceCorrection(imo INT)
BEGIN

	/* UPDATE tempRawISO
	SET Wind_Resistance_Correction = 
		((Wind_Resistance_Relative - Air_Resistance_No_Wind) * Speed_Over_Ground / (SELECT Propulsive_Efficiency FROM SpeedPower WHERE IMO_Vessel_Number = imo)) + 
		Delivered_Power * (1 - (0.7 / (SELECT Propulsive_Efficiency FROM SpeedPower WHERE IMO_Vessel_Number = imo)));
	*/
    
	UPDATE `inservice`.tempRawISO e 
		JOIN
			(SELECT q.id, w.Propulsive_Efficiency, w.Speed, w.Power, q.Delivered_Power FROM `inservice`.tempRawISO q
				JOIN `static`.SpeedPower w
					ON 
						/* q.IMO_Vessel_Number = w.IMO_Vessel_Number AND */
						q.NearestDisplacement = w.Displacement AND
						q.NearestTrim = w.Trim
                        WHERE w.ModelID IN (SELECT Speed_Power_Model FROM `static`.VesselSpeedPowerModel)
				GROUP BY id) r
		ON e.id = r.id
		SET e.Wind_Resistance_Correction = 
			/*(
			(e.Wind_Resistance_Relative - e.Air_Resistance_No_Wind) * e.Speed_Over_Ground / r.Propulsive_Efficiency) + 
			(e.Delivered_Power * 1E3) * (1 - (0.7 / r.Propulsive_Efficiency)
			) / 1E3
			;*/
            
            (((e.Wind_Resistance_Relative - e.Air_Resistance_No_Wind) * e.Speed_Over_Ground / IFNULL(r.Propulsive_Efficiency, 0.7)) + (e.Delivered_Power * 1E3) * (1 - (0.7 / IFNULL(r.Propulsive_Efficiency, 0.7)))) /1e3;
END;