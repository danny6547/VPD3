/* Create filter for values below the lowest value of power in the speed,
power data. */

DROP PROCEDURE IF EXISTS filterPowerBelowMinimum;

delimiter //

CREATE PROCEDURE filterPowerBelowMinimum(imo INT)

BEGIN
	
    /* Get nearest displacements and trim Filter_SpeedPower_Disp_Trim*/
	/* UPDATE tempRawISO t
		JOIN SpeedPower p
		ON t.IMO_Vessel_Number = p.IMO_Vessel_Number AND
			t.NearestTrim = p.Trim AND
            t.NearestDisplacement = p.Displacement
		SET t.Filter_SpeedPower_Below = t.Corrected_Power < MIN(p.Power)
        ; */
    
	/* Get the minimum power of the power curve corresponding to delivered power, then whether DeliveredPower is less than this value. */
	UPDATE tempRawISO y JOIN
		(SELECT q.id, MinPower, MaxPower, MaxSpeed, MinSpeed,
											IFNULL(q.Speed_Through_Water > MaxSpeed, FALSE) AS SHigh,
											IFNULL(q.Speed_Through_Water < MinSpeed, FALSE) AS SLow,
											IFNULL(q.Corrected_Power > MaxPower, FALSE) AS PHigh,
											IFNULL(q.Corrected_Power < MinPower, FALSE) AS PLow FROM
		(SELECT r.id, r.Corrected_Power, p.Power, r.NearestDisplacement, r.NearestTrim, r.Speed_Through_Water
			FROM tempRawISO r
				JOIN SpeedPower p
					ON
					 /* r.IMO_Vessel_Number = p.IMO_Vessel_Number AND */
					r.NearestTrim = p.Trim AND
					r.NearestDisplacement = p.Displacement
					WHERE p.ModelID IN (SELECT Speed_Power_Model FROM vesselspeedpowermodel WHERE IMO_Vessel_Number = imo)
					) AS q
		INNER JOIN
			(SELECT id, Corrected_Power, Power, MIN(Power) AS MinPower, MAX(Power) AS MaxPower, MIN(Speed) AS MinSpeed, MAX(Speed) AS MaxSpeed
			FROM
				(SELECT t.id, t.Corrected_Power, p.Power, p.Speed FROM tempRawISO t
					JOIN SpeedPower p
						ON
						/* t.IMO_Vessel_Number = p.IMO_Vessel_Number AND */
						t.NearestTrim = p.Trim AND
						t.NearestDisplacement = p.Displacement
						WHERE p.ModelID IN (SELECT Speed_Power_Model FROM vesselspeedpowermodel WHERE IMO_Vessel_Number = imo)) AS w
			GROUP BY id) AS e
		ON
		q.id = e.id AND
		q.Power = e.Power
		GROUP BY q.id) u
			ON y.id = u.id
			SET y.Filter_SpeedPower_Below  = u.SLow OR u.PLow,
				 y.Filter_SpeedPower_Above  = u.SHigh OR u.PHigh
			;
    
    /* Filter variable when STW is NULL */
	UPDATE tempRawISO SET Filter_SpeedPower_Below  = IFNULL(Filter_SpeedPower_Below, TRUE);
	UPDATE tempRawISO SET Filter_SpeedPower_Above  = IFNULL(Filter_SpeedPower_Above, TRUE);
	UPDATE tempRawISO SET Filter_SpeedPower_Below  = TRUE WHERE Speed_Through_Water IS NULL;
	UPDATE tempRawISO SET Filter_SpeedPower_Above  = TRUE WHERE Speed_Through_Water IS NULL;
    
	UPDATE tempRawISO SET Filter_SpeedPower_Below  = TRUE WHERE Corrected_Power IS NULL;
	UPDATE tempRawISO SET Filter_SpeedPower_Above  = TRUE WHERE Corrected_Power IS NULL;
            
END