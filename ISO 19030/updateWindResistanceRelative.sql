/* Update Wind Resistance Relative based on equation G2. */



DROP PROCEDURE IF EXISTS updateWindResistanceRelative;

delimiter //

CREATE PROCEDURE updateWindResistanceRelative(imo INT)
BEGIN
    
    SET @currModel := (SELECT Wind_Model_ID FROM Vessels WHERE IMO_Vessel_Number = imo);
    /*
	UPDATE tempRawISO t
		JOIN (
			SELECT s1.id, s1.Coefficient
				FROM (SELECT t.id, Relative_Wind_Direction_Reference, Direction, Coefficient, ABS(Relative_Wind_Direction_Reference - Direction) AS Diff FROM TempRawISO t 
					JOIN
						(SELECT Direction, Coefficient, id AS 'windID' FROM windcoefficientdirection WHERE ModelID = @currModel) w) s1
							LEFT JOIN
								(SELECT t.id, Relative_Wind_Direction_Reference, Direction, Coefficient, ABS(Relative_Wind_Direction_Reference - Direction) AS Diff FROM TempRawISO t 
									JOIN
										(SELECT Direction, Coefficient, id AS 'windID' FROM windcoefficientdirection WHERE ModelID = @currModel) w) s2
											ON s1.id = s2.id AND s1.Diff > s2.Diff
												WHERE s2.id IS NULL) w
                                                ON t.id = w.id
		SET t.Wind_Resistance_Relative =
				0.5 *
				Air_Density *
				POWER(Relative_Wind_Speed_Reference, 2) *
				Transverse_Projected_Area_Current * 
				w.Coefficient;
		/*( SELECT Coefficient FROM WindCoefficientDirection WHERE IMO_Vessel_Number = imo AND Relative_Wind_Direction >= Start_Direction AND Relative_Wind_Direction < End_Direction);*/
	
    UPDATE tempRawISO t
		JOIN (
				SELECT b.Coefficient, b.tid AS 'id' FROM 
				(
					SELECT t.id AS 'tid', MIN(ABS(Direction - Relative_Wind_Direction_Reference)) AS 'MinDiff', Coefficient, Direction FROM tempRawISO t
						JOIN WindCoefficientDirection w
							 WHERE ModelID = @currModel
								GROUP BY tid 
						 ) a
				JOIN 
				(
					SELECT t.id AS 'tid', ABS(Direction - Relative_Wind_Direction_Reference) AS 'Diff', Coefficient, Direction FROM tempRawISO t
						JOIN WindCoefficientDirection w
							 WHERE ModelID = @currModel
						 ) b
				ON a.MinDiff = b.Diff
				GROUP BY b.tid 
			) w
		ON t.id = w.id
		SET t.Wind_Resistance_Relative =
				0.5 *
				Air_Density *
				POWER(Relative_Wind_Speed_Reference, 2) *
				Transverse_Projected_Area_Current * 
				w.Coefficient;
     /*           
	UPDATE tempRawISO SET Wind_Resistance_Relative = 
				0.5 *
				Air_Density *
				POWER(Relative_Wind_Speed_Reference, 2) *
				Transverse_Projected_Area_Current * 
				w.Coefficient;*/
END;