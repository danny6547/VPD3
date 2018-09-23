/* Updates the wind resistance correction based on equation G2. */

DROP PROCEDURE IF EXISTS updateWindResistanceCorrection;

delimiter //

CREATE PROCEDURE updateWindResistanceCorrection(vcid INT)
BEGIN

	/* UPDATE tempRawISO
	SET Wind_Resistance_Correction = 
		((Wind_Resistance_Relative - Air_Resistance_No_Wind) * Speed_Over_Ground / (SELECT Propulsive_Efficiency FROM SpeedPower WHERE IMO_Vessel_Number = imo)) + 
		Delivered_Power * (1 - (0.7 / (SELECT Propulsive_Efficiency FROM SpeedPower WHERE IMO_Vessel_Number = imo)));
	*/
    
UPDATE tempRawISO e 
	JOIN
		(SELECT q.id, w.Propulsive_Efficiency, w.Speed, w.Power, q.Delivered_Power FROM tempRawISO q
	JOIN `static`.SpeedPower w
		JOIN `static`.SpeedPowerCoefficientModelValue t
			ON 
				q.Nearest_Displacement = t.Displacement AND
				q.Nearest_Trim = t.Trim
					WHERE w.Speed_Power_Coefficient_Model_Value_Id IN 
						(SELECT Speed_Power_Coefficient_Model_Value_Id FROM `static`.SpeedPowerCoefficientModelValue WHERE Speed_Power_Coefficient_Model_Id =
							(SELECT Speed_Power_Coefficient_Model_Id FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid)
                                                                        )
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