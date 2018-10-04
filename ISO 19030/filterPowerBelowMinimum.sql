/* Create filter for values below the lowest value of power in the speed,
power data. */

DROP PROCEDURE IF EXISTS filterPowerBelowMinimum;

delimiter //

CREATE PROCEDURE filterPowerBelowMinimum(vcid INT)

BEGIN
	
    /* Get nearest displacements and trim Filter_SpeedPower_Disp_Trim*/
	/* UPDATE tempRawISO t
		JOIN SpeedPower p
		ON t.IMO_Vessel_Number = p.IMO_Vessel_Number AND
			t.NearestTrim = p.Trim AND
            t.Nearest_Displacement = p.Displacement
		SET t.Filter_SpeedPower_Below = t.Corrected_Power < MIN(p.Power)
        ; */
    
	/* Get the minimum power of the power curve corresponding to delivered power, then whether DeliveredPower is less than this value. */
	UPDATE tempRawISO y JOIN
		(SELECT q.id, MinPower, MaxPower,
											IFNULL(q.Corrected_Power > MaxPower, FALSE) AS PHigh,
											IFNULL(q.Corrected_Power < MinPower, FALSE) AS PLow FROM
		(SELECT r.id, r.Corrected_Power, p.Maximum_Power, r.Nearest_Displacement, r.Nearest_Trim, r.Speed_Through_Water
			FROM tempRawISO r
				JOIN `static`.SpeedPowerCoefficientModelValue p
					ON
					 /* r.IMO_Vessel_Number = p.IMO_Vessel_Number AND */
					r.Nearest_Trim = p.Trim AND
					r.Nearest_Displacement = p.Displacement
					WHERE p.Speed_Power_Coefficient_Model_Id = (SELECT Speed_Power_Coefficient_Model_Id FROM `static`.vesselConfiguration WHERE vessel_Configuration_Id = vcid)
					) AS q
		INNER JOIN
			(SELECT id, Corrected_Power, Minimum_Power AS MinPower, Maximum_Power AS MaxPower
			FROM
				(SELECT t.id, t.Corrected_Power, p.Maximum_Power, p.Minimum_Power FROM tempRawISO t
					JOIN `static`.SpeedPowerCoefficientModelValue p
						ON
						/* t.IMO_Vessel_Number = p.IMO_Vessel_Number AND */
						t.Nearest_Trim = p.Trim AND
						t.Nearest_Displacement = p.Displacement
						WHERE p.Speed_Power_Coefficient_Model_Id = (SELECT Speed_Power_Coefficient_Model_Id FROM `static`.vesselConfiguration WHERE vessel_Configuration_Id = vcid)) AS w
			GROUP BY id) AS e
		ON
		q.id = e.id
		/* AND q.Power = e.Power*/
		GROUP BY q.id) u
			ON y.id = u.id
			SET y.Filter_SpeedPower_Below  = u.PLow,
				 y.Filter_SpeedPower_Above  = u.PHigh
			;
    
    /* Filter variable when STW is NULL */
	/*UPDATE tempRawISO SET Filter_SpeedPower_Below  = IFNULL(Filter_SpeedPower_Below, TRUE);
	UPDATE tempRawISO SET Filter_SpeedPower_Above  = IFNULL(Filter_SpeedPower_Above, TRUE);
	UPDATE tempRawISO SET Filter_SpeedPower_Below  = TRUE WHERE Speed_Through_Water IS NULL;
	UPDATE tempRawISO SET Filter_SpeedPower_Above  = TRUE WHERE Speed_Through_Water IS NULL;*/
    
	UPDATE tempRawISO SET Filter_SpeedPower_Below  = NULL WHERE Corrected_Power IS NULL;
	UPDATE tempRawISO SET Filter_SpeedPower_Above  = NULL WHERE Corrected_Power IS NULL;
            
END