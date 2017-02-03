/* Update filter columns for rows which do not meet the reference 
conditions given in standard ISO 19030-2. */

DROP PROCEDURE IF EXISTS filterReferenceConditions;

delimiter //

CREATE PROCEDURE filterReferenceConditions(imo INT)

BEGIN
	
    DECLARE DepthFormula5 DOUBLE(10, 5);
    DECLARE DepthFormula6 DOUBLE(10, 5);
    DECLARE ShipBreadth DOUBLE(10, 5);
    DECLARE g1 DOUBLE(10, 5);
    
    DROP TABLE IF EXISTS DepthFormula;
    CREATE TABLE DepthFormula (id INT PRIMARY KEY AUTO_INCREMENT, 
								DateTime_UTC DATETIME, 
								Water_Depth DOUBLE(10, 5), 
								DepthFormula5 DOUBLE(10, 5), 
								DepthFormula6 DOUBLE(10, 5));
    
    INSERT INTO DepthFormula (DateTime_UTC) SELECT DateTime_UTC FROM tempRawISO;
    UPDATE DepthFormula, tempRawISO SET DepthFormula.Water_Depth = tempRawISO.Water_Depth;
    
    SET ShipBreadth := (SELECT Breadth_Moulded FROM Vessels WHERE IMO_Vessel_Number = imo);
    SET g1 := (SELECT g FROM globalConstants);
    
	UPDATE DepthFormula d 
		INNER JOIN tempRawISO t
			ON d.DateTime_UTC = t.DateTime_UTC
				SET 
                d.DepthFormula5 = 3 * SQRT( ShipBreadth * (t.Static_Draught_Aft + t.Static_Draught_Fore) / 2 ),
                d.DepthFormula6 = 2.75 * POWER(t.Speed_Through_Water, 2) / g1, 
                d.Water_Depth = t.Water_Depth;
    
    UPDATE tempRawISO SET Filter_Reference_Seawater_Temp = TRUE WHERE Seawater_Temperature <= 2;
    UPDATE tempRawISO SET Filter_Reference_Wind_Speed = TRUE WHERE Relative_Wind_Speed > 7.9;
    UPDATE tempRawISO SET Filter_Reference_Water_Depth = TRUE WHERE Water_Depth < 3 * SQRT( ShipBreadth * (Static_Draught_Aft + Static_Draught_Fore) / 2 ) 
		OR Water_Depth < 2.75 * POWER(Speed_Through_Water, 2) / g1;
    UPDATE tempRawISO SET Filter_Reference_Rudder_Angle = TRUE WHERE Rudder_Angle > 5;
    
	/* DELETE FROM tempRawISO WHERE Seawater_Temperature <= 2; */
    /* 
	DELETE FROM tempRawISO WHERE Relative_Wind_Speed < 0 OR Relative_Wind_Speed > 7.9;
	DELETE FROM tempRawISO WHERE Rudder_Angle > 5;
    DELETE d
		FROM tempRawISO d
        JOIN DepthFormula dd ON d.DateTime_UTC = dd.DateTime_UTC
        WHERE d.Water_Depth < dd.DepthFormula5 OR
			  d.Water_Depth < dd.DepthFormula6;
    /* DROP TABLE DepthFormula; */
END;