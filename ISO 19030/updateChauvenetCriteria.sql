/* Apply Chauvenet's criterion to all primary and secondary parameters. */
/* Assumptions: */
/* 1.  */

USE hull_performance;


DROP PROCEDURE IF EXISTS updateChauvenetCriteria;

delimiter //

CREATE PROCEDURE updateChauvenetCriteria()

BEGIN
	
    /* Declare constants */
    DECLARE a1 DOUBLE (10, 9);
    DECLARE a2 DOUBLE (10, 9);
    DECLARE a3 DOUBLE (10, 9);
    DECLARE a4 DOUBLE (10, 9);
    DECLARE a5 DOUBLE (10, 9);
    DECLARE p DOUBLE (10, 9);
    DECLARE startTime INT(12);
    
    set @a1 := 0.254829592;
	set @a2 := -0.284496736;
	set @a3 := 1.421413741;
	set @a4 := -1.453152027;
	set @a5 := 1.061405429;
	set @p  := 0.3275911;
    
    SET @startTime := (SELECT TO_SECONDS(MIN(DateTime_UTC)) FROM tempRawISO);
    
    /* Update Chauvenet_Criteria field */
	CALL createTempChauvenetFilter();
    INSERT INTO ChauvenetTempFilter (id) (SELECT id FROM tempRawISO);
    UPDATE ChauvenetTempFilter AS t7
		INNER JOIN
			(SELECT t6.id, /* (IFNULL(ChauvFilt_Speed_Through_Water, FALSE) OR IFNULL(ChauvFilt_Delivered_Power, FALSE) OR IFNULL(ChauvFilt_Shaft_Revolutions, FALSE) OR IFNULL(ChauvFilt_Relative_Wind_Speed, FALSE) OR IFNULL(ChauvFilt_Relative_Wind_Direction, FALSE) OR IFNULL(ChauvFilt_Speed_Over_Ground, FALSE) OR IFNULL(ChauvFilt_Ship_Heading, FALSE) OR IFNULL(ChauvFilt_Rudder_Angle, FALSE) OR IFNULL(ChauvFilt_Water_Depth, FALSE) OR IFNULL(ChauvFilt_Seawater_Temperature, FALSE)) */ 
					ChauvFilt_Speed_Through_Water , ChauvFilt_Delivered_Power , ChauvFilt_Shaft_Revolutions , ChauvFilt_Relative_Wind_Speed , ChauvFilt_Relative_Wind_Direction , ChauvFilt_Speed_Over_Ground , ChauvFilt_Ship_Heading , ChauvFilt_Rudder_Angle , ChauvFilt_Water_Depth , ChauvFilt_Seawater_Temperature /* AS Chauvenet_Criteria */
				FROM (SELECT t5.id,
							CASE x_Speed_Through_Water >= 0
								WHEN TRUE THEN (@a1*t_Speed_Through_Water + @a2*POWER(t_Speed_Through_Water, 2) + @a3*POWER(t_Speed_Through_Water, 3) + @a4*POWER(t_Speed_Through_Water, 4) + @a5*POWER(t_Speed_Through_Water, 5))*exp(-POWER(x_Speed_Through_Water, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Speed_Through_Water + @a2*POWER(t_Speed_Through_Water, -2) + @a3*POWER(t_Speed_Through_Water, -3) + @a4*POWER(t_Speed_Through_Water, -4) + @a5*POWER(t_Speed_Through_Water, -5))*exp(-POWER(x_Speed_Through_Water, 2))) * N  < 0.5                        
							END AS ChauvFilt_Speed_Through_Water,
                            CASE x_Delivered_Power >= 0
								WHEN TRUE THEN (@a1*t_Delivered_Power + @a2*POWER(t_Delivered_Power, 2) + @a3*POWER(t_Delivered_Power, 3) + @a4*POWER(t_Delivered_Power, 4) + @a5*POWER(t_Delivered_Power, 5))*exp(-POWER(x_Delivered_Power, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Delivered_Power + @a2*POWER(t_Delivered_Power, -2) + @a3*POWER(t_Delivered_Power, -3) + @a4*POWER(t_Delivered_Power, -4) + @a5*POWER(t_Delivered_Power, -5))*exp(-POWER(x_Delivered_Power, 2))) * N  < 0.5
							END AS ChauvFilt_Delivered_Power,
                            CASE x_Shaft_Revolutions >= 0
								WHEN TRUE THEN (@a1*t_Shaft_Revolutions + @a2*POWER(t_Shaft_Revolutions, 2) + @a3*POWER(t_Shaft_Revolutions, 3) + @a4*POWER(t_Shaft_Revolutions, 4) + @a5*POWER(t_Shaft_Revolutions, 5))*exp(-POWER(x_Shaft_Revolutions, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Shaft_Revolutions + @a2*POWER(t_Shaft_Revolutions, -2) + @a3*POWER(t_Shaft_Revolutions, -3) + @a4*POWER(t_Shaft_Revolutions, -4) + @a5*POWER(t_Shaft_Revolutions, -5))*exp(-POWER(x_Shaft_Revolutions, 2))) * N  < 0.5
							END AS ChauvFilt_Shaft_Revolutions,
                            CASE x_Relative_Wind_Speed >= 0
								WHEN TRUE THEN (@a1*t_Relative_Wind_Speed + @a2*POWER(t_Relative_Wind_Speed, 2) + @a3*POWER(t_Relative_Wind_Speed, 3) + @a4*POWER(t_Relative_Wind_Speed, 4) + @a5*POWER(t_Relative_Wind_Speed, 5))*exp(-POWER(x_Relative_Wind_Speed, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Relative_Wind_Speed + @a2*POWER(t_Relative_Wind_Speed, -2) + @a3*POWER(t_Relative_Wind_Speed, -3) + @a4*POWER(t_Relative_Wind_Speed, -4) + @a5*POWER(t_Relative_Wind_Speed, -5))*exp(-POWER(x_Relative_Wind_Speed, 2))) * N  < 0.5
							END AS ChauvFilt_Relative_Wind_Speed,
                            CASE x_Relative_Wind_Direction >= 0
								WHEN TRUE THEN (@a1*t_Relative_Wind_Direction + @a2*POWER(t_Relative_Wind_Direction, 2) + @a3*POWER(t_Relative_Wind_Direction, 3) + @a4*POWER(t_Relative_Wind_Direction, 4) + @a5*POWER(t_Relative_Wind_Direction, 5))*exp(-POWER(x_Relative_Wind_Direction, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Relative_Wind_Direction + @a2*POWER(t_Relative_Wind_Direction, -2) + @a3*POWER(t_Relative_Wind_Direction, -3) + @a4*POWER(t_Relative_Wind_Direction, -4) + @a5*POWER(t_Relative_Wind_Direction, -5))*exp(-POWER(x_Relative_Wind_Direction, 2))) * N  < 0.5
							END AS ChauvFilt_Relative_Wind_Direction,
                            CASE x_Speed_Over_Ground >= 0
								WHEN TRUE THEN (@a1*t_Speed_Over_Ground + @a2*POWER(t_Speed_Over_Ground, 2) + @a3*POWER(t_Speed_Over_Ground, 3) + @a4*POWER(t_Speed_Over_Ground, 4) + @a5*POWER(t_Speed_Over_Ground, 5))*exp(-POWER(x_Speed_Over_Ground, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Speed_Over_Ground + @a2*POWER(t_Speed_Over_Ground, -2) + @a3*POWER(t_Speed_Over_Ground, -3) + @a4*POWER(t_Speed_Over_Ground, -4) + @a5*POWER(t_Speed_Over_Ground, -5))*exp(-POWER(x_Speed_Over_Ground, 2))) * N  < 0.5
							END AS ChauvFilt_Speed_Over_Ground,
                            CASE x_Ship_Heading >= 0
								WHEN TRUE THEN (@a1*t_Ship_Heading + @a2*POWER(t_Ship_Heading, 2) + @a3*POWER(t_Ship_Heading, 3) + @a4*POWER(t_Ship_Heading, 4) + @a5*POWER(t_Ship_Heading, 5))*exp(-POWER(x_Ship_Heading, 2)) * N < 0.5                                                                              
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Ship_Heading + @a2*POWER(t_Ship_Heading, -2) + @a3*POWER(t_Ship_Heading, -3) + @a4*POWER(t_Ship_Heading, -4) + @a5*POWER(t_Ship_Heading, -5))*exp(-POWER(x_Ship_Heading, 2))) * N  < 0.5
							END AS ChauvFilt_Ship_Heading,
                            CASE x_Rudder_Angle >= 0
								WHEN TRUE THEN (@a1*t_Rudder_Angle + @a2*POWER(t_Rudder_Angle, 2) + @a3*POWER(t_Rudder_Angle, 3) + @a4*POWER(t_Rudder_Angle, 4) + @a5*POWER(t_Rudder_Angle, 5))*exp(-POWER(x_Rudder_Angle, 2)) * N < 0.5                                                                              
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Rudder_Angle + @a2*POWER(t_Rudder_Angle, -2) + @a3*POWER(t_Rudder_Angle, -3) + @a4*POWER(t_Rudder_Angle, -4) + @a5*POWER(t_Rudder_Angle, -5))*exp(-POWER(x_Rudder_Angle, 2))) * N  < 0.5
							END AS ChauvFilt_Rudder_Angle,
                            CASE x_Water_Depth >= 0
								WHEN TRUE THEN (@a1*t_Water_Depth + @a2*POWER(t_Water_Depth, 2) + @a3*POWER(t_Water_Depth, 3) + @a4*POWER(t_Water_Depth, 4) + @a5*POWER(t_Water_Depth, 5))*exp(-POWER(x_Water_Depth, 2)) * N < 0.5                                                                                                                                                                  
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Water_Depth + @a2*POWER(t_Water_Depth, -2) + @a3*POWER(t_Water_Depth, -3) + @a4*POWER(t_Water_Depth, -4) + @a5*POWER(t_Water_Depth, -5))*exp(-POWER(x_Water_Depth, 2))) * N  < 0.5
							END AS ChauvFilt_Water_Depth,
                            CASE x_Seawater_Temperature >= 0
								WHEN TRUE THEN (@a1*t_Seawater_Temperature + @a2*POWER(t_Seawater_Temperature, 2) + @a3*POWER(t_Seawater_Temperature, 3) + @a4*POWER(t_Seawater_Temperature, 4) + @a5*POWER(t_Seawater_Temperature, 5))*exp(-POWER(x_Seawater_Temperature, 2)) * N < 0.5                                                                                                                                                                   
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Seawater_Temperature + @a2*POWER(t_Seawater_Temperature, -2) + @a3*POWER(t_Seawater_Temperature, -3) + @a4*POWER(t_Seawater_Temperature, -4) + @a5*POWER(t_Seawater_Temperature, -5))*exp(-POWER(x_Seawater_Temperature, 2))) * N  < 0.5
							END AS ChauvFilt_Seawater_Temperature
					FROM
						(SELECT t4.id,
							N,
							ABS(Speed_Through_Water - Avg_Speed_Through_Water) / (Std_Speed_Through_Water - SQRT(2)) AS x_Speed_Through_Water,
							ABS(Delivered_Power - Avg_Delivered_Power) / (Std_Delivered_Power - SQRT(2)) AS x_Delivered_Power,
							ABS(Shaft_Revolutions - Avg_Shaft_Revolutions) / (Std_Shaft_Revolutions - SQRT(2)) AS x_Shaft_Revolutions,
							ABS(Relative_Wind_Speed - Avg_Relative_Wind_Speed) / (Std_Relative_Wind_Speed - SQRT(2)) AS x_Relative_Wind_Speed,
							ABS(Relative_Wind_Direction - Avg_Relative_Wind_Direction) / (Std_Relative_Wind_Direction - SQRT(2)) AS x_Relative_Wind_Direction,
							ABS(Speed_Over_Ground - Avg_Speed_Over_Ground) / (Std_Speed_Over_Ground - SQRT(2)) AS x_Speed_Over_Ground,
							ABS(Ship_Heading - Avg_Ship_Heading) / (Std_Ship_Heading - SQRT(2)) AS x_Ship_Heading,
							ABS(Rudder_Angle - Avg_Rudder_Angle) / (Std_Rudder_Angle - SQRT(2)) AS x_Rudder_Angle,
							ABS(Water_Depth - Avg_Water_Depth) / (Std_Water_Depth - SQRT(2)) AS x_Water_Depth,
							ABS(Seawater_Temperature - Avg_Seawater_Temperature) / (Std_Seawater_Temperature - SQRT(2)) AS x_Seawater_Temperature,
							1 / (1 + @p* (ABS(Speed_Through_Water - Avg_Speed_Through_Water)) / (Std_Speed_Through_Water - SQRT(2)) ) AS t_Speed_Through_Water,
							1 / (1 + @p* (ABS(Delivered_Power - Avg_Delivered_Power)) / (Std_Delivered_Power - SQRT(2)) ) AS t_Delivered_Power,
							1 / (1 + @p* (ABS(Shaft_Revolutions - Avg_Shaft_Revolutions)) / (Std_Shaft_Revolutions - SQRT(2)) ) AS t_Shaft_Revolutions,
							1 / (1 + @p* (ABS(Relative_Wind_Speed - Avg_Relative_Wind_Speed)) / (Std_Relative_Wind_Speed - SQRT(2)) ) AS t_Relative_Wind_Speed,
							1 / (1 + @p* (ABS(Relative_Wind_Direction - Avg_Relative_Wind_Direction)) / (Std_Relative_Wind_Direction - SQRT(2)) ) AS t_Relative_Wind_Direction,
							1 / (1 + @p* (ABS(Speed_Over_Ground - Avg_Speed_Over_Ground)) / (Std_Speed_Over_Ground - SQRT(2)) ) AS t_Speed_Over_Ground,
							1 / (1 + @p* (ABS(Ship_Heading - Avg_Ship_Heading)) / (Std_Ship_Heading - SQRT(2)) ) AS t_Ship_Heading,
							1 / (1 + @p* (ABS(Rudder_Angle - Avg_Rudder_Angle)) / (Std_Rudder_Angle - SQRT(2)) ) AS t_Rudder_Angle,
							1 / (1 + @p* (ABS(Water_Depth - Avg_Water_Depth)) / (Std_Water_Depth - SQRT(2)) ) AS t_Water_Depth,
							1 / (1 + @p* (ABS(Seawater_Temperature - Avg_Seawater_Temperature)) / (Std_Seawater_Temperature - SQRT(2)) ) AS t_Seawater_Temperature
						FROM
							(SELECT t3.id,
									Speed_Through_Water,
									Delivered_Power,
									Shaft_Revolutions,
									Relative_Wind_Speed,
									Relative_Wind_Direction,
									Speed_Over_Ground,
									Ship_Heading,
									Rudder_Angle,
									Water_Depth,
									Seawater_Temperature,
									@lasta := IFNULL(Avg_Speed_Through_Water, @lasta) AS Avg_Speed_Through_Water,        
									@lastb := IFNULL(Avg_Delivered_Power, @lastb) AS Avg_Delivered_Power,                
									@lastc := IFNULL(Avg_Shaft_Revolutions, @lastc) AS Avg_Shaft_Revolutions,            
									@lastd := IFNULL(Avg_Relative_Wind_Speed, @lastd) AS Avg_Relative_Wind_Speed,        
									@laste := IFNULL(Avg_Relative_Wind_Direction, @laste) AS Avg_Relative_Wind_Direction,
									@lastf := IFNULL(Avg_Speed_Over_Ground, @lastf) AS Avg_Speed_Over_Ground,            
									@lastg := IFNULL(Avg_Ship_Heading, @lastg) AS Avg_Ship_Heading,                       
									@lasth := IFNULL(Avg_Rudder_Angle, @lasth) AS Avg_Rudder_Angle,                      
									@lasti := IFNULL(Avg_Water_Depth, @lasti) AS Avg_Water_Depth,                        
									@lastj := IFNULL(Avg_Seawater_Temperature, @lastj) AS Avg_Seawater_Temperature,      
									@lastk := IFNULL(Std_Speed_Through_Water, @lastk) AS Std_Speed_Through_Water,        
									@lastl := IFNULL(Std_Delivered_Power, @lastl) AS Std_Delivered_Power,                
									@lastm := IFNULL(Std_Shaft_Revolutions, @lastm) AS Std_Shaft_Revolutions,            
									@lastn := IFNULL(Std_Relative_Wind_Speed, @lastn) AS Std_Relative_Wind_Speed,        
									@lasto := IFNULL(Std_Relative_Wind_Direction, @lasto) AS Std_Relative_Wind_Direction,
									@lastp := IFNULL(Std_Speed_Over_Ground, @lastp) AS Std_Speed_Over_Ground,            
									@lastq := IFNULL(Std_Ship_Heading, @lastq) AS Std_Ship_Heading,                      
									@lastr := IFNULL(Std_Rudder_Angle, @lastr) AS Std_Rudder_Angle,                      
									@lasts := IFNULL(Std_Water_Depth, @lasts) AS Std_Water_Depth,                        
									@lastt := IFNULL(Std_Seawater_Temperature, @lastt) AS Std_Seawater_Temperature,     
                                    @lastv := IFNULL(N, @lastv) AS N
							FROM
								(SELECT
									t1.id,
									N,
									Speed_Through_Water,
									Delivered_Power,
									Shaft_Revolutions,
									Relative_Wind_Speed,
									Relative_Wind_Direction,
									Speed_Over_Ground,
									Ship_Heading,
									Rudder_Angle,
									Water_Depth,
									Seawater_Temperature,
									Avg_Speed_Through_Water,
									Avg_Delivered_Power,
									Avg_Shaft_Revolutions,
									Avg_Relative_Wind_Speed,
									Avg_Relative_Wind_Direction,
									Avg_Speed_Over_Ground,
									Avg_Ship_Heading,
									Avg_Water_Depth,
									Avg_Seawater_Temperature,
                                    Avg_Rudder_Angle,
									Std_Speed_Through_Water,
									Std_Delivered_Power,
									Std_Shaft_Revolutions,
									Std_Relative_Wind_Speed,
									Std_Relative_Wind_Direction,
									Std_Speed_Over_Ground,
									Std_Ship_Heading,
									Std_Water_Depth,
									Std_Seawater_Temperature,
                                    Std_Rudder_Angle
										FROM tempRawISO t1
											LEFT JOIN (SELECT id, DateTime_UTC, t33.IMO_Vessel_Number, COUNT(*) AS N,
												AVG(Speed_Through_Water) AS  Avg_Speed_Through_Water,        
												AVG(Delivered_Power) AS  Avg_Delivered_Power,                
												AVG(Shaft_Revolutions) AS  Avg_Shaft_Revolutions,            
												AVG(Relative_Wind_Speed) AS  Avg_Relative_Wind_Speed,        
												AVG(Relative_Wind_Direction) AS  Avg_Relative_Wind_Direction,
												AVG(Speed_Over_Ground) AS  Avg_Speed_Over_Ground,            
												AVG(Ship_Heading) AS  Avg_Ship_Heading,                      
												AVG(Water_Depth) AS  Avg_Water_Depth,                        
												AVG(Seawater_Temperature) AS  Avg_Seawater_Temperature,
                                                mu_Rudder_Angle AS Avg_Rudder_Angle,
                                                mu_Relative_Wind_Direction AS mu_Relative_Wind_Direction,
												STD(Speed_Through_Water) AS  Std_Speed_Through_Water,        
												STD(Delivered_Power) AS  Std_Delivered_Power,                
												STD(Shaft_Revolutions) AS  Std_Shaft_Revolutions,            
												STD(Relative_Wind_Speed) AS  Std_Relative_Wind_Speed,        
												STD(Speed_Over_Ground) AS  Std_Speed_Over_Ground,            
												STD(Ship_Heading) AS  Std_Ship_Heading,                        
												STD(Water_Depth) AS  Std_Water_Depth,                        
												STD(Seawater_Temperature) AS  Std_Seawater_Temperature,
												SQRT(AVG(POWER(Delta_Rudder_Angle, 2))) AS Std_Rudder_Angle,
												SQRT(AVG(POWER(Delta_Relative_Wind_Direction, 2))) AS Std_Relative_Wind_Direction
													FROM (SELECT
																t32.id,
                                                                t32.IMO_Vessel_Number,
																t32.DateTime_UTC,
																Speed_Through_Water,
																Delivered_Power,
																Shaft_Revolutions,
																Relative_Wind_Speed,
																Relative_Wind_Direction,
																Speed_Over_Ground,
																Ship_Heading,
																Water_Depth,
																Seawater_Temperature,
                                                                mu_Rudder_Angle,
                                                                mu_Relative_Wind_Direction,
																CASE mod(ABS(t32.Rudder_Angle - mu_Rudder_Angle), 360) > 180
																	WHEN TRUE THEN 360 - mod(ABS(t32.Rudder_Angle - mu_Rudder_Angle), 360)
																	WHEN FALSE THEN mod(ABS(t32.Rudder_Angle - mu_Rudder_Angle), 360)
																END AS Delta_Rudder_Angle,
																CASE mod(ABS(t32.Relative_Wind_Direction - mu_Relative_Wind_Direction), 360) > 180
																	WHEN TRUE THEN 360 - mod(ABS(t32.Relative_Wind_Direction - mu_Relative_Wind_Direction), 360)
																	WHEN FALSE THEN mod(ABS(t32.Relative_Wind_Direction - mu_Relative_Wind_Direction), 360)
																END AS Delta_Relative_Wind_Direction
															FROM
																(SELECT t31.id,
																	t31.IMO_Vessel_Number,
                                                                    t31.DateTime_UTC,
																	t31.Rudder_Angle,
																	Speed_Through_Water,
																	Delivered_Power,
																	Shaft_Revolutions,
																	Relative_Wind_Speed,
																	Relative_Wind_Direction,
																	Speed_Over_Ground,
																	Ship_Heading,
																	Water_Depth,
																	Seawater_Temperature,
																	@lastw := IFNULL(mu_Rudder_Angle, @lastw) AS mu_Rudder_Angle,
																	@lastx := IFNULL(mu_Relative_Wind_Direction, @lastx) AS mu_Relative_Wind_Direction
																	FROM
																		(SELECT id,
																			IMO_Vessel_Number,
																			DateTime_UTC,
																			 ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle))) AS mu_Rudder_Angle,
																			 ATAN2(AVG(SIN(Relative_Wind_Direction)), AVG(COS(Relative_Wind_Direction))) AS mu_Relative_Wind_Direction
																		FROM tempRawISO
																			GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t30
																		RIGHT JOIN tempRawISO t31
																			ON t30.id = t31.id
																				CROSS JOIN (SELECT @lastw := 0) AS var_w) t32) t33
														GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t2
											ON t1.id = t2.id) t3
											CROSS JOIN (SELECT @lasta := 0) AS var_a
											CROSS JOIN (SELECT @lastb := 0) AS var_b
											CROSS JOIN (SELECT @lastd := 0) AS var_d
											CROSS JOIN (SELECT @lastf := 0) AS var_f
											CROSS JOIN (SELECT @lasth := 0) AS var_h
											CROSS JOIN (SELECT @lastj := 0) AS var_j
											CROSS JOIN (SELECT @lastl := 0) AS var_l
											CROSS JOIN (SELECT @lastn := 0) AS var_n
											CROSS JOIN (SELECT @lastp := 0) AS var_p
											CROSS JOIN (SELECT @lastr := 0) AS var_r
											CROSS JOIN (SELECT @lastt := 0) AS var_t
											CROSS JOIN (SELECT @lastc := 0) AS var_c
											CROSS JOIN (SELECT @laste := 0) AS var_e
											CROSS JOIN (SELECT @lastg := 0) AS var_g
											CROSS JOIN (SELECT @lasti := 0) AS var_i
											CROSS JOIN (SELECT @lastk := 0) AS var_k
											CROSS JOIN (SELECT @lastm := 0) AS var_m
											CROSS JOIN (SELECT @lasto := 0) AS var_o
											CROSS JOIN (SELECT @lastq := 0) AS var_q
											CROSS JOIN (SELECT @lasts := 0) AS var_s
											CROSS JOIN (SELECT @lastu := 0) AS var_u
											CROSS JOIN (SELECT @lastv := 0) AS var_v) t4) t5) t6) AS t8
												ON t7.id = t8.id
													SET t7.Speed_Through_Water = t8.ChauvFilt_Speed_Through_Water,
													    t7.Delivered_Power = t8.ChauvFilt_Delivered_Power,
													    t7.Shaft_Revolutions = t8.ChauvFilt_Shaft_Revolutions,
													    t7.Relative_Wind_Speed = t8.ChauvFilt_Relative_Wind_Speed,
													    t7.Relative_Wind_Direction = t8.ChauvFilt_Relative_Wind_Direction,
													    t7.Speed_Over_Ground = t8.ChauvFilt_Speed_Over_Ground,
													    t7.Shaft_Revolutions = t8.ChauvFilt_Shaft_Revolutions,
													    t7.Ship_Heading = t8.ChauvFilt_Ship_Heading,
													    t7.Rudder_Angle = t8.ChauvFilt_Rudder_Angle,
													    t7.Water_Depth = t8.ChauvFilt_Water_Depth,
													    t7.Seawater_Temperature = t8.ChauvFilt_Seawater_Temperature
                                                        ;
    
	UPDATE temprawiso t
		JOIN ChauvenetTempFilter c
			ON t.id = c.id
				SET t.Chauvenet_Criteria = 
                (IFNULL(c.Speed_Through_Water, FALSE) OR IFNULL(c.Delivered_Power, FALSE) OR IFNULL(c.Shaft_Revolutions, FALSE) OR IFNULL(c.Relative_Wind_Speed, FALSE) OR
                IFNULL(c.Relative_Wind_Direction, FALSE) OR IFNULL(c.Speed_Over_Ground, FALSE) OR IFNULL(c.Ship_Heading, FALSE) OR IFNULL(c.Rudder_Angle, FALSE) OR
                IFNULL(c.Water_Depth, FALSE) OR IFNULL(c.Seawater_Temperature, FALSE));
                
    /* Mark analysis as Chauvenet Filtered */
    SET @timeStep := (SELECT (SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 1, 1) - 
		(SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 0, 1) );
	IF @timeStep < 600 THEN
		SET @ChauvenetFiltered := TRUE;
	ELSE
		SET @ChauvenetFiltered := FALSE;
	END IF;
    
    CALL IMOStartEnd(@imo, @startd, @endd);
    IF @imo IS NOT NULL AND @startd IS NOT NULL AND @endd IS NOT NULL THEN
		INSERT INTO StandardCompliance (IMO_Vessel_Number, StartDate, EndDate, ChauvenetFiltered)
		VALUES (@imo, @startd, @endd, @ChauvenetFiltered) ON DUPLICATE KEY UPDATE ChauvenetFiltered = VALUES(ChauvenetFiltered);
    END IF;
    
END;