

DROP PROCEDURE IF EXISTS updateNearestTrim;

delimiter //

CREATE PROCEDURE updateNearestTrim(imo INT)
BEGIN
	
    /* Get valid trim and nearest trim */
    UPDATE `inservice`.tempRawISO q
	JOIN 
		(SELECT a.id, b.Trim, NOT( a.NearestTrim >= (a.Trim - 0.002*(SELECT LBP FROM `static`.Vessels WHERE IMO_Vessel_Number = imo)) AND
				a.NearestTrim <= (a.Trim + 0.002*(SELECT LBP FROM `static`.Vessels WHERE IMO_Vessel_Number = imo)) ) AS 'FT'
			FROM `inservice`.tempRawISO a
			JOIN
			(
				SELECT t.id, s.Trim, s.Displacement FROM speedpowercoefficients s
					JOIN `inservice`.tempRawISO t
						ON s.Displacement = t.NearestDisplacement
							WHERE s.ModelID IN (SELECT Speed_Power_Model FROM `static`.vesselspeedpowermodel WHERE IMO_Vessel_Number = imo)
						  ) b
					ON a.id = b.id) w
						ON q.id = w.id
                        SET q.Filter_SpeedPower_Trim = w.FT,
							q.NearestTrim			 = w.Trim;
                            
END