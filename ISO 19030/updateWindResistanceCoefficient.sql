
DROP PROCEDURE IF EXISTS updateWindResistanceCoefficient;

delimiter //

CREATE PROCEDURE updateWindResistanceCoefficient(imo INT)
BEGIN
    
    SET @currModel := (SELECT Wind_Model_ID FROM `static`.Vessels WHERE IMO_Vessel_Number = imo);
    
    UPDATE `inservice`.tempRawISO t
		JOIN
			(
				SELECT b.Coefficient, b.tid AS 'id' FROM 
				(
					SELECT t.id AS 'tid', MIN(ABS(Direction - Relative_Wind_Direction_Reference)) AS 'MinDiff', Coefficient, Direction FROM `inservice`.tempRawISO t
						JOIN `static`.WindCoefficientDirection w
							 WHERE ModelID = @currModel
								GROUP BY tid 
						 ) a
				JOIN 
				(
					SELECT t.id AS 'tid', ABS(Direction - Relative_Wind_Direction_Reference) AS 'Diff', Coefficient, Direction FROM `inservice`.tempRawISO t
						JOIN `static`.WindCoefficientDirection w
							 WHERE ModelID = @currModel
						 ) b
				ON a.MinDiff = b.Diff
				GROUP BY b.tid 
					) w
			ON t.id = w.id
            SET t.WindCoefficient = w.Coefficient;
            
END;