/* Apply Chauvenet's criterion to all primary and secondary parameters. */
/* Assumptions: */
/* 1.  */


DROP PROCEDURE IF EXISTS updateChauvenetCriteria;

delimiter //

CREATE PROCEDURE updateChauvenetCriteria()

BEGIN

	/* Constants */
	SET @startTime := (SELECT MIN(Timestamp) from `inservice`.tempRawISO);
	SET @firstgroup := (SELECT FLOOR((TO_SECONDS(MIN(Timestamp)) - TO_SECONDS(@startTime))/(600)) FROM `inservice`.tempRawISO);
    
    /* Calculate 10 minute averages */
    DROP TABLE IF EXISTS `inservice`.mu10Mins;
	CREATE TABLE `inservice`.mu10Mins (
							id INT PRIMARY KEY AUTO_INCREMENT,
							Relative_Wind_Speed DOUBLE(10 , 5 ),
							Relative_Wind_Direction DOUBLE(10 , 5 ),
							Speed_Over_Ground DOUBLE(10 , 5 ),
							Ship_Heading DOUBLE(10 , 5 ),
							Shaft_Revolutions DOUBLE(10 , 5 ),
							Water_Depth DOUBLE(10 , 5 ),
							Rudder_Angle DOUBLE(10 , 5 ),
							Seawater_Temperature DOUBLE(10 , 5 ),
							Speed_Through_Water DOUBLE(10 , 5 ),
							Air_Temperature DOUBLE(10, 8),
							Delivered_Power DOUBLE(20 , 3 ),
							 Static_Draught_Fore DOUBLE(10, 5),
							 Static_Draught_Aft DOUBLE(10, 5),
							N INT);
                            
	INSERT INTO `inservice`.mu10Mins (
							Rudder_Angle,
							Relative_Wind_Direction,
							Ship_Heading, 
							Speed_Through_Water, 
							Delivered_Power, 
							Relative_Wind_Speed, 
							Speed_Over_Ground, 
							Shaft_Revolutions, 
							Water_Depth, 
                            Air_Temperature,
							Seawater_Temperature,
							 Static_Draught_Fore,
							 Static_Draught_Aft,
							N)
				(SELECT 
					 ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle))) AS Rudder_Angle,
					 ATAN2(AVG(SIN(Relative_Wind_Direction)), AVG(COS(Relative_Wind_Direction))) AS Relative_Wind_Direction,
					 ATAN2(AVG(SIN(Ship_Heading)), AVG(COS(Ship_Heading))) AS Ship_Heading,
					 AVG(Speed_Through_Water) AS Speed_Through_Water,
					 AVG(Delivered_Power) AS Delivered_Power,
					 AVG(Relative_Wind_Speed) AS Relative_Wind_Speed,
					 AVG(Speed_Over_Ground) AS Speed_Over_Ground,
					 AVG(Shaft_Revolutions) AS Shaft_Revolutions,
					 AVG(Water_Depth) AS Water_Depth,
					 AVG(Air_Temperature) AS Air_Temperature,
					 AVG(Seawater_Temperature) AS Seawater_Temperature,
					 AVG(Static_Draught_Fore) AS Static_Draught_Fore,
					 AVG(Static_Draught_Aft) AS Static_Draught_Aft,
					 COUNT(*) AS N
				FROM `inservice`.tempRawISO
					GROUP BY FLOOR((TO_SECONDS(Timestamp) - TO_SECONDS(@startTime))/(600)));
                    
    /* Calculate individual errors of data from the 10-minute mean */
	DROP TABLE IF EXISTS `inservice`.del10Mins;
	/* CREATE TABLE del10Mins LIKE mu10Mins; */
    
	CREATE TABLE `inservice`.del10Mins (
							id INT PRIMARY KEY AUTO_INCREMENT,
                            Timestamp DATETIME,
							Relative_Wind_Speed DOUBLE(10 , 5 ),
							Relative_Wind_Direction DOUBLE(10 , 5 ),
							Speed_Over_Ground DOUBLE(10 , 5 ),
							Ship_Heading DOUBLE(10 , 5 ),
							Shaft_Revolutions DOUBLE(10 , 5 ),
							Water_Depth DOUBLE(10 , 5 ),
							Rudder_Angle DOUBLE(10 , 5 ),
							Seawater_Temperature DOUBLE(10 , 5 ),
							Speed_Through_Water DOUBLE(10 , 5 ),
							Air_Temperature DOUBLE(10, 8),
							Delivered_Power DOUBLE(20 , 3 ),
							 Static_Draught_Fore DOUBLE(10, 5),
							 Static_Draught_Aft DOUBLE(10, 5),
							N INT);
    
	INSERT INTO `inservice`.del10Mins (Timestamp,
							Speed_Over_Ground, 
							Relative_Wind_Speed, 
							Shaft_Revolutions, 
							Water_Depth, 
							Seawater_Temperature,
							Speed_Through_Water, 
							Delivered_Power,
                            Air_Temperature,
							 Static_Draught_Fore,
							 Static_Draught_Aft,
							Rudder_Angle,
							Relative_Wind_Direction,
							Ship_Heading)
		SELECT
				t.Timestamp,
				ABS(t.Speed_Over_Ground - mu.Speed_Over_Ground) AS Speed_Over_Ground,
				ABS(t.Relative_Wind_Speed - mu.Relative_Wind_Speed) AS Relative_Wind_Speed,
				ABS(t.Shaft_Revolutions - mu.Shaft_Revolutions) AS Shaft_Revolutions,
				ABS(t.Water_Depth - mu.Water_Depth) AS Water_Depth,
				ABS(t.Seawater_Temperature - mu.Seawater_Temperature) AS Seawater_Temperature,
				ABS(t.Speed_Through_Water - mu.Speed_Through_Water) AS Speed_Through_Water,
				ABS(t.Delivered_Power - mu.Delivered_Power) AS Delivered_Power,
				ABS(t.Air_Temperature - mu.Air_Temperature) AS Air_Temperature,
				ABS(t.Static_Draught_Fore - mu.Static_Draught_Fore) AS Static_Draught_Fore,
				ABS(t.Static_Draught_Aft - mu.Static_Draught_Aft) AS Static_Draught_Aft,
				CASE mod(ABS(t.Rudder_Angle - mu.Rudder_Angle), 360) > 180
					WHEN TRUE THEN 360 - mod(ABS(t.Rudder_Angle - mu.Rudder_Angle), 360)
					WHEN FALSE THEN mod(ABS(t.Rudder_Angle - mu.Rudder_Angle), 360)
				END AS Rudder_Angle,
				CASE mod(ABS(t.Relative_Wind_Direction - mu.Relative_Wind_Direction), 360) > 180
					WHEN TRUE THEN 360 - mod(ABS(t.Relative_Wind_Direction - mu.Relative_Wind_Direction), 360)
					WHEN FALSE THEN mod(ABS(t.Relative_Wind_Direction - mu.Relative_Wind_Direction), 360)
				END AS Relative_Wind_Direction,
				CASE mod(ABS(t.Ship_Heading - mu.Ship_Heading), 360) > 180
					WHEN TRUE THEN 360 - mod(ABS(t.Ship_Heading - mu.Ship_Heading), 360)
					WHEN FALSE THEN mod(ABS(t.Ship_Heading - mu.Ship_Heading), 360)
				END AS Ship_Heading
					FROM `inservice`.tempRawISO t
						JOIN mu10Mins mu
							ON mu.id = FLOOR((TO_SECONDS(t.Timestamp) - TO_SECONDS(@startTime))/(600)) - @firstgroup + 1;
    
    /* Calculate 10 minute standard error of mean */
	DROP TABLE IF EXISTS `inservice`.sem10Mins;
	CREATE TABLE `inservice`.sem10Mins LIKE mu10Mins;
    
	INSERT INTO `inservice`.sem10Mins (
							Rudder_Angle,
							Relative_Wind_Direction,
							Ship_Heading, 
							Speed_Through_Water, 
							Delivered_Power, 
							Relative_Wind_Speed, 
							Speed_Over_Ground, 
							Shaft_Revolutions, 
							Water_Depth, 
                            Air_Temperature,
							 Static_Draught_Fore,
							 Static_Draught_Aft,
							Seawater_Temperature)
				(SELECT
					 SQRT(AVG(POWER(Rudder_Angle, 2))),
					 SQRT(AVG(POWER(Relative_Wind_Direction, 2))),
					 SQRT(AVG(POWER(Ship_Heading, 2))),
					 SQRT(AVG(POWER(Speed_Through_Water, 2))),
					 SQRT(AVG(POWER(Delivered_Power, 2))),
					 SQRT(AVG(POWER(Relative_Wind_Speed, 2))),
					 SQRT(AVG(POWER(Speed_Over_Ground, 2))),
					 SQRT(AVG(POWER(Shaft_Revolutions, 2))),
					 SQRT(AVG(POWER(Water_Depth, 2))),
					 SQRT(AVG(POWER(Air_Temperature, 2))),
					 SQRT(AVG(POWER(Static_Draught_Fore, 2))),
					 SQRT(AVG(POWER(Static_Draught_Aft, 2))),
					 SQRT(AVG(POWER(Seawater_Temperature, 2)))
				FROM `inservice`.del10Mins
					GROUP BY FLOOR((TO_SECONDS(Timestamp) - TO_SECONDS(@startTime))/(600)));
    
	/* Calculate ERFC function on 10 minute blocks */
	DROP TABLE IF EXISTS `inservice`.erfc10Mins;
	CREATE TABLE `inservice`.erfc10Mins (id INT PRIMARY KEY AUTO_INCREMENT,
								 x_Relative_Wind_Speed DOUBLE(20, 5),
								 x_Relative_Wind_Direction DOUBLE(20, 5),
								 x_Speed_Over_Ground DOUBLE(20, 5),
								 x_Ship_Heading DOUBLE(20, 5),
								 x_Shaft_Revolutions DOUBLE(20, 5),
								 x_Water_Depth DOUBLE(20, 5),
								 x_Rudder_Angle DOUBLE(20, 5),
								 x_Seawater_Temperature DOUBLE(20, 5),
								 x_Speed_Through_Water DOUBLE(20, 5),
								 x_Delivered_Power DOUBLE(20, 3),
								 x_Air_Temperature DOUBLE(20, 3),
								 x_Static_Draught_Fore DOUBLE(20, 5),
								 x_Static_Draught_Aft DOUBLE(20, 5),
								 t_Relative_Wind_Speed DOUBLE(20, 5),
								 t_Relative_Wind_Direction DOUBLE(20, 5),
								 t_Speed_Over_Ground DOUBLE(20, 5),
								 t_Ship_Heading DOUBLE(20, 5),
								 t_Shaft_Revolutions DOUBLE(20, 5),
								 t_Water_Depth DOUBLE(20, 5),
								 t_Rudder_Angle DOUBLE(20, 5),
								 t_Seawater_Temperature DOUBLE(20, 5),
								 t_Speed_Through_Water DOUBLE(20, 5),
								 t_Delivered_Power DOUBLE(20, 3),
								 t_Air_Temperature DOUBLE(20, 3),
								 t_Static_Draught_Fore DOUBLE(20, 5),
								 t_Static_Draught_Aft DOUBLE(20, 5),
								 N INT);
	set @p  := 0.3275911;
	SET @ROOT2 := SQRT(2);

	INSERT INTO `inservice`.erfc10Mins (x_Speed_Through_Water,
							x_Rudder_Angle,
							x_Relative_Wind_Direction,
							x_Ship_Heading, 
							x_Delivered_Power, 
							x_Relative_Wind_Speed, 
							x_Speed_Over_Ground, 
							x_Shaft_Revolutions, 
							x_Water_Depth, 
							x_Seawater_Temperature,
                            x_Air_Temperature,
							x_Static_Draught_Fore,
							x_Static_Draught_Aft,
							t_Speed_Through_Water,
							t_Rudder_Angle,
							t_Relative_Wind_Direction,
							t_Ship_Heading, 
							t_Delivered_Power, 
							t_Relative_Wind_Speed, 
							t_Speed_Over_Ground, 
							t_Shaft_Revolutions, 
							t_Water_Depth, 
							t_Seawater_Temperature,
                            t_Air_Temperature,
							t_Static_Draught_Fore,
							t_Static_Draught_Aft,
							N)
		SELECT
			t.Speed_Through_Water / (sem.Speed_Through_Water * @ROOT2),
			t.Rudder_Angle / (sem.Rudder_Angle * @ROOT2),
			t.Relative_Wind_Direction / (sem.Relative_Wind_Direction * @ROOT2),
			t.Ship_Heading / (sem.Ship_Heading * @ROOT2),
			t.Delivered_Power / (sem.Delivered_Power * @ROOT2),
			t.Relative_Wind_Speed / (sem.Relative_Wind_Speed * @ROOT2),
			t.Speed_Over_Ground / (sem.Speed_Over_Ground * @ROOT2),
			t.Shaft_Revolutions / (sem.Shaft_Revolutions * @ROOT2),
			t.Water_Depth / (sem.Water_Depth * @ROOT2),
			t.Seawater_Temperature / (sem.Seawater_Temperature * @ROOT2),
			t.Air_Temperature / (sem.Air_Temperature * @ROOT2),
			t.Static_Draught_Fore / (sem.Static_Draught_Fore * @ROOT2),
			t.Static_Draught_Aft / (sem.Static_Draught_Aft * @ROOT2),
			1 / (1 + @p* t.Speed_Through_Water / (sem.Speed_Through_Water * @ROOT2) ) AS t_Speed_Through_Water,
			1 / (1 + @p* t.Rudder_Angle / (sem.Rudder_Angle * @ROOT2) ) AS t_Rudder_Angle,
			1 / (1 + @p* t.Relative_Wind_Direction / (sem.Relative_Wind_Direction * @ROOT2) ) AS t_Relative_Wind_Direction,
			1 / (1 + @p* t.Ship_Heading / (sem.Ship_Heading * @ROOT2) ) AS t_Ship_Heading,
			1 / (1 + @p* t.Delivered_Power / (sem.Delivered_Power * @ROOT2) ) AS t_Delivered_Power,
			1 / (1 + @p* t.Relative_Wind_Speed / (sem.Relative_Wind_Speed * @ROOT2) ) AS t_Relative_Wind_Speed,
			1 / (1 + @p* t.Speed_Over_Ground / (sem.Speed_Over_Ground * @ROOT2) ) AS t_Speed_Over_Ground,
			1 / (1 + @p* t.Shaft_Revolutions / (sem.Shaft_Revolutions * @ROOT2) ) AS t_Shaft_Revolutions,
			1 / (1 + @p* t.Water_Depth / (sem.Water_Depth * @ROOT2) ) AS t_Water_Depth,
			1 / (1 + @p* t.Seawater_Temperature / (sem.Seawater_Temperature * @ROOT2) ) AS t_Seawater_Temperature,
			1 / (1 + @p* t.Air_Temperature / (sem.Air_Temperature * @ROOT2) ) AS t_Air_Temperature,
			1 / (1 + @p* t.Static_Draught_Fore / (sem.Static_Draught_Fore * @ROOT2) ) AS t_Static_Draught_Fore,
			1 / (1 + @p* t.Static_Draught_Aft / (sem.Static_Draught_Aft * @ROOT2) ) AS t_Static_Draught_Aft,
			mu.N
				FROM `inservice`.del10Mins t
				JOIN `inservice`.mu10Mins mu
					ON mu.id = FLOOR((TO_SECONDS(t.Timestamp) - TO_SECONDS(@startTime))/(600)) - @firstgroup + 1
				JOIN `inservice`.sem10Mins sem
					ON sem.id = FLOOR((TO_SECONDS(t.Timestamp) - TO_SECONDS(@startTime))/(600)) - @firstgroup + 1;
    
    /* Compare the complimentary error function for each parameter with the threhold value for exclusion */
	set @a1 := 0.254829592;
	set @a2 := -0.284496736;
	set @a3 := 1.421413741;
	set @a4 := -1.453152027;
	set @a5 := 1.061405429;
    
    DROP TABLE IF EXISTS `inservice`.ChauvenetTempFilter;
    CALL `inservice`.createTempChauvenetFilter();
	
	INSERT INTO `inservice`.ChauvenetTempFilter (Speed_Through_Water,
									Delivered_Power,
									Shaft_Revolutions,
									Relative_Wind_Speed, 
									Relative_Wind_Direction, 
									Speed_Over_Ground, 
									Ship_Heading, 
									Rudder_Angle, 
									Water_Depth, 
                                    Air_Temperature,
									 Static_Draught_Fore,
									 Static_Draught_Aft,
									Seawater_Temperature)
	SELECT
		CASE x_Speed_Through_Water >= 0
			WHEN TRUE THEN (@a1*t_Speed_Through_Water + @a2*POWER(t_Speed_Through_Water, 2) + @a3*POWER(t_Speed_Through_Water, 3) + @a4*POWER(t_Speed_Through_Water, 4) + @a5*POWER(t_Speed_Through_Water, 5))*exp(-POWER(x_Speed_Through_Water, 2)) * N < 0.5
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Speed_Through_Water + @a2*POWER(t_Speed_Through_Water, -2) + @a3*POWER(t_Speed_Through_Water, -3) + @a4*POWER(t_Speed_Through_Water, -4) + @a5*POWER(t_Speed_Through_Water, -5))*exp(-POWER(x_Speed_Through_Water, 2))) * N  < 0.5                        
		END AS Speed_Through_Water,
		CASE x_Delivered_Power >= 0
			WHEN TRUE THEN (@a1*t_Delivered_Power + @a2*POWER(t_Delivered_Power, 2) + @a3*POWER(t_Delivered_Power, 3) + @a4*POWER(t_Delivered_Power, 4) + @a5*POWER(t_Delivered_Power, 5))*exp(-POWER(x_Delivered_Power, 2)) * N < 0.5
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Delivered_Power + @a2*POWER(t_Delivered_Power, -2) + @a3*POWER(t_Delivered_Power, -3) + @a4*POWER(t_Delivered_Power, -4) + @a5*POWER(t_Delivered_Power, -5))*exp(-POWER(x_Delivered_Power, 2))) * N  < 0.5
		END AS Delivered_Power,
		CASE x_Shaft_Revolutions >= 0
			WHEN TRUE THEN (@a1*t_Shaft_Revolutions + @a2*POWER(t_Shaft_Revolutions, 2) + @a3*POWER(t_Shaft_Revolutions, 3) + @a4*POWER(t_Shaft_Revolutions, 4) + @a5*POWER(t_Shaft_Revolutions, 5))*exp(-POWER(x_Shaft_Revolutions, 2)) * N < 0.5
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Shaft_Revolutions + @a2*POWER(t_Shaft_Revolutions, -2) + @a3*POWER(t_Shaft_Revolutions, -3) + @a4*POWER(t_Shaft_Revolutions, -4) + @a5*POWER(t_Shaft_Revolutions, -5))*exp(-POWER(x_Shaft_Revolutions, 2))) * N  < 0.5
		END AS Shaft_Revolutions,
		CASE x_Relative_Wind_Speed >= 0
			WHEN TRUE THEN (@a1*t_Relative_Wind_Speed + @a2*POWER(t_Relative_Wind_Speed, 2) + @a3*POWER(t_Relative_Wind_Speed, 3) + @a4*POWER(t_Relative_Wind_Speed, 4) + @a5*POWER(t_Relative_Wind_Speed, 5))*exp(-POWER(x_Relative_Wind_Speed, 2)) * N < 0.5
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Relative_Wind_Speed + @a2*POWER(t_Relative_Wind_Speed, -2) + @a3*POWER(t_Relative_Wind_Speed, -3) + @a4*POWER(t_Relative_Wind_Speed, -4) + @a5*POWER(t_Relative_Wind_Speed, -5))*exp(-POWER(x_Relative_Wind_Speed, 2))) * N  < 0.5
		END AS Relative_Wind_Speed,
		CASE x_Relative_Wind_Direction >= 0
			WHEN TRUE THEN (@a1*t_Relative_Wind_Direction + @a2*POWER(t_Relative_Wind_Direction, 2) + @a3*POWER(t_Relative_Wind_Direction, 3) + @a4*POWER(t_Relative_Wind_Direction, 4) + @a5*POWER(t_Relative_Wind_Direction, 5))*exp(-POWER(x_Relative_Wind_Direction, 2)) * N < 0.5
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Relative_Wind_Direction + @a2*POWER(t_Relative_Wind_Direction, -2) + @a3*POWER(t_Relative_Wind_Direction, -3) + @a4*POWER(t_Relative_Wind_Direction, -4) + @a5*POWER(t_Relative_Wind_Direction, -5))*exp(-POWER(x_Relative_Wind_Direction, 2))) * N  < 0.5
		END AS Relative_Wind_Direction,
		CASE x_Speed_Over_Ground >= 0
			WHEN TRUE THEN (@a1*t_Speed_Over_Ground + @a2*POWER(t_Speed_Over_Ground, 2) + @a3*POWER(t_Speed_Over_Ground, 3) + @a4*POWER(t_Speed_Over_Ground, 4) + @a5*POWER(t_Speed_Over_Ground, 5))*exp(-POWER(x_Speed_Over_Ground, 2)) * N < 0.5
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Speed_Over_Ground + @a2*POWER(t_Speed_Over_Ground, -2) + @a3*POWER(t_Speed_Over_Ground, -3) + @a4*POWER(t_Speed_Over_Ground, -4) + @a5*POWER(t_Speed_Over_Ground, -5))*exp(-POWER(x_Speed_Over_Ground, 2))) * N  < 0.5
		END AS Speed_Over_Ground,
		CASE x_Ship_Heading >= 0
			WHEN TRUE THEN (@a1*t_Ship_Heading + @a2*POWER(t_Ship_Heading, 2) + @a3*POWER(t_Ship_Heading, 3) + @a4*POWER(t_Ship_Heading, 4) + @a5*POWER(t_Ship_Heading, 5))*exp(-POWER(x_Ship_Heading, 2)) * N < 0.5                                                                              
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Ship_Heading + @a2*POWER(t_Ship_Heading, -2) + @a3*POWER(t_Ship_Heading, -3) + @a4*POWER(t_Ship_Heading, -4) + @a5*POWER(t_Ship_Heading, -5))*exp(-POWER(x_Ship_Heading, 2))) * N  < 0.5
		END AS Ship_Heading,
		CASE x_Rudder_Angle >= 0
			WHEN TRUE THEN (@a1*t_Rudder_Angle + @a2*POWER(t_Rudder_Angle, 2) + @a3*POWER(t_Rudder_Angle, 3) + @a4*POWER(t_Rudder_Angle, 4) + @a5*POWER(t_Rudder_Angle, 5))*exp(-POWER(x_Rudder_Angle, 2)) * N < 0.5                                                                              
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Rudder_Angle + @a2*POWER(t_Rudder_Angle, -2) + @a3*POWER(t_Rudder_Angle, -3) + @a4*POWER(t_Rudder_Angle, -4) + @a5*POWER(t_Rudder_Angle, -5))*exp(-POWER(x_Rudder_Angle, 2))) * N  < 0.5
		END AS Rudder_Angle,
		CASE x_Water_Depth >= 0
			WHEN TRUE THEN (@a1*t_Water_Depth + @a2*POWER(t_Water_Depth, 2) + @a3*POWER(t_Water_Depth, 3) + @a4*POWER(t_Water_Depth, 4) + @a5*POWER(t_Water_Depth, 5))*exp(-POWER(x_Water_Depth, 2)) * N < 0.5                                                                                                                                                                  
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Water_Depth + @a2*POWER(t_Water_Depth, -2) + @a3*POWER(t_Water_Depth, -3) + @a4*POWER(t_Water_Depth, -4) + @a5*POWER(t_Water_Depth, -5))*exp(-POWER(x_Water_Depth, 2))) * N  < 0.5
		END AS Water_Depth,
		CASE x_Air_Temperature >= 0
			WHEN TRUE THEN (@a1*t_Air_Temperature + @a2*POWER(t_Air_Temperature, 2) + @a3*POWER(t_Air_Temperature, 3) + @a4*POWER(t_Air_Temperature, 4) + @a5*POWER(t_Air_Temperature, 5))*exp(-POWER(x_Air_Temperature, 2)) * N < 0.5                                                                                                                                                                   
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Air_Temperature + @a2*POWER(t_Air_Temperature, -2) + @a3*POWER(t_Air_Temperature, -3) + @a4*POWER(t_Air_Temperature, -4) + @a5*POWER(t_Air_Temperature, -5))*exp(-POWER(x_Air_Temperature, 2))) * N  < 0.5
		END AS Air_Temperature,
		CASE x_Static_Draught_Fore >= 0
			WHEN TRUE THEN (@a1*t_Static_Draught_Fore + @a2*POWER(t_Static_Draught_Fore, 2) + @a3*POWER(t_Static_Draught_Fore, 3) + @a4*POWER(t_Static_Draught_Fore, 4) + @a5*POWER(t_Static_Draught_Fore, 5))*exp(-POWER(x_Static_Draught_Fore, 2)) * N < 0.5                                                                                                                                                                   
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Static_Draught_Fore + @a2*POWER(t_Static_Draught_Fore, -2) + @a3*POWER(t_Static_Draught_Fore, -3) + @a4*POWER(t_Static_Draught_Fore, -4) + @a5*POWER(t_Static_Draught_Fore, -5))*exp(-POWER(x_Static_Draught_Fore, 2))) * N  < 0.5
		END AS Static_Draught_Fore,
		CASE x_Static_Draught_Aft >= 0
			WHEN TRUE THEN (@a1*t_Static_Draught_Aft + @a2*POWER(t_Static_Draught_Aft, 2) + @a3*POWER(t_Static_Draught_Aft, 3) + @a4*POWER(t_Static_Draught_Aft, 4) + @a5*POWER(t_Static_Draught_Aft, 5))*exp(-POWER(x_Static_Draught_Aft, 2)) * N < 0.5                                                                                                                                                                   
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Static_Draught_Aft + @a2*POWER(t_Static_Draught_Aft, -2) + @a3*POWER(t_Static_Draught_Aft, -3) + @a4*POWER(t_Static_Draught_Aft, -4) + @a5*POWER(t_Static_Draught_Aft, -5))*exp(-POWER(x_Static_Draught_Aft, 2))) * N  < 0.5
		END AS Static_Draught_Aft,
		CASE x_Seawater_Temperature >= 0
			WHEN TRUE THEN (@a1*t_Seawater_Temperature + @a2*POWER(t_Seawater_Temperature, 2) + @a3*POWER(t_Seawater_Temperature, 3) + @a4*POWER(t_Seawater_Temperature, 4) + @a5*POWER(t_Seawater_Temperature, 5))*exp(-POWER(x_Seawater_Temperature, 2)) * N < 0.5                                                                                                                                                                   
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Seawater_Temperature + @a2*POWER(t_Seawater_Temperature, -2) + @a3*POWER(t_Seawater_Temperature, -3) + @a4*POWER(t_Seawater_Temperature, -4) + @a5*POWER(t_Seawater_Temperature, -5))*exp(-POWER(x_Seawater_Temperature, 2))) * N  < 0.5
		END AS Seawater_Temperature
			FROM `inservice`.erfc10Mins e;
        
		/* Chauvenet criteria fails when it fails for any parameter */
		UPDATE temprawiso t
				JOIN `inservice`.ChauvenetTempFilter c
					ON t.id = c.id
						SET t.Chauvenet_Criteria = 
						(IFNULL(c.Speed_Through_Water, FALSE) OR IFNULL(c.Delivered_Power, FALSE) OR IFNULL(c.Shaft_Revolutions, FALSE) OR IFNULL(c.Relative_Wind_Speed, FALSE) OR
						IFNULL(c.Relative_Wind_Direction, FALSE) OR IFNULL(c.Speed_Over_Ground, FALSE) OR IFNULL(c.Ship_Heading, FALSE) OR IFNULL(c.Rudder_Angle, FALSE) OR
						IFNULL(c.Water_Depth, FALSE) OR IFNULL(c.Air_Temperature, FALSE) OR IFNULL(c.Static_Draught_Fore, FALSE) OR IFNULL(c.Static_Draught_Aft, FALSE) OR IFNULL(c.Seawater_Temperature, FALSE));
		
		/* Mark analysis as Chauvenet Filtered */
		SET @timeStep := (SELECT (SELECT to_seconds(Timestamp) FROM `inservice`.tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 1, 1) - 
			(SELECT to_seconds(Timestamp) FROM `inservice`.tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 0, 1) );
		IF @timeStep < 600 THEN
			SET @ChauvenetFiltered := TRUE;
		ELSE
			SET @ChauvenetFiltered := FALSE;
		END IF;
		
        /*
		CALL IMOStartEnd(@imo, @startd, @endd);
		IF @imo IS NOT NULL AND @startd IS NOT NULL AND @endd IS NOT NULL THEN
			INSERT INTO `inservice`.Analysis (IMO_Vessel_Number, StartDate, EndDate, ChauvenetFiltered)
			VALUES (@imo, @startd, @endd, @ChauvenetFiltered) ON DUPLICATE KEY UPDATE ChauvenetFiltered = VALUES(ChauvenetFiltered);
		END IF;
        */
END;