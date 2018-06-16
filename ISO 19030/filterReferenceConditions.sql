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
    
    DROP TABLE IF EXISTS `inservice`.DepthFormula;
    CREATE TABLE `inservice`.DepthFormula (id INT PRIMARY KEY AUTO_INCREMENT, 
								DateTime_UTC DATETIME, 
								Water_Depth DOUBLE(10, 5), 
								DepthFormula5 DOUBLE(10, 5), 
								DepthFormula6 DOUBLE(10, 5));
    
    INSERT INTO `inservice`.DepthFormula (DateTime_UTC) SELECT DateTime_UTC FROM temprawiso;
    UPDATE `inservice`.DepthFormula, `inservice`.temprawiso SET `inservice`.DepthFormula.Water_Depth = `inservice`.temprawiso.Water_Depth;
    
    SET ShipBreadth := (SELECT Breadth_Moulded FROM `static`.Vessels WHERE IMO_Vessel_Number = imo);
    SET g1 := (SELECT g FROM `static`.globalConstants);
    
	UPDATE `inservice`.DepthFormula d 
		INNER JOIN `inservice`.temprawiso t
			ON d.DateTime_UTC = t.DateTime_UTC
				SET 
                d.DepthFormula5 = 3 * SQRT( ShipBreadth * (t.Static_Draught_Aft + t.Static_Draught_Fore) / 2 ),
                d.DepthFormula6 = 2.75 * POWER(t.Speed_Through_Water, 2) / g1, 
                d.Water_Depth = t.Water_Depth;
    
    UPDATE `inservice`.temprawiso SET Filter_Reference_Seawater_Temp = TRUE WHERE Seawater_Temperature <= 2;
    UPDATE `inservice`.temprawiso SET Filter_Reference_Wind_Speed = TRUE WHERE Relative_Wind_Speed > 7.9;
    UPDATE `inservice`.temprawiso SET Filter_Reference_Water_Depth = TRUE WHERE Water_Depth < 3 * SQRT( ShipBreadth * (Static_Draught_Aft + Static_Draught_Fore) / 2 ) 
		OR Water_Depth < 2.75 * POWER(Speed_Through_Water, 2) / g1;
    UPDATE `inservice`.temprawiso SET Filter_Reference_Rudder_Angle = TRUE WHERE Rudder_Angle > 5;
    
	/* DELETE FROM temprawiso WHERE Seawater_Temperature <= 2; */
    /* 
	DELETE FROM temprawiso WHERE Relative_Wind_Speed < 0 OR Relative_Wind_Speed > 7.9;
	DELETE FROM temprawiso WHERE Rudder_Angle > 5;
    DELETE d
		FROM temprawiso d
        JOIN DepthFormula dd ON d.DateTime_UTC = dd.DateTime_UTC
        WHERE d.Water_Depth < dd.DepthFormula5 OR
			  d.Water_Depth < dd.DepthFormula6;
    /* DROP TABLE DepthFormula; */
END;