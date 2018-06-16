/* Calculate ERFC function on 10 minute blocks */

DROP TABLE IF EXISTS `inservice`.erfc10Mins;

CREATE TABLE `inservice`.erfc10Mins (id INT PRIMARY KEY AUTO_INCREMENT,
							 x_Relative_Wind_Speed DOUBLE(10, 5),
							 x_Relative_Wind_Direction DOUBLE(10, 5),
							 x_Speed_Over_Ground DOUBLE(10, 5),
							 x_Ship_Heading DOUBLE(10, 5),
							 x_Shaft_Revolutions DOUBLE(10, 5),
							 x_Water_Depth DOUBLE(10, 5),
							 x_Rudder_Angle DOUBLE(10, 5),
							 x_Seawater_Temperature DOUBLE(10, 5),
							 x_Speed_Through_Water DOUBLE(10, 5),
							 x_Delivered_Power DOUBLE(20, 3),
							 x_Air_Temperature DOUBLE(20, 3),
							 t_Relative_Wind_Speed DOUBLE(10, 5),
							 t_Relative_Wind_Direction DOUBLE(10, 5),
							 t_Speed_Over_Ground DOUBLE(10, 5),
							 t_Ship_Heading DOUBLE(10, 5),
							 t_Shaft_Revolutions DOUBLE(10, 5),
							 t_Water_Depth DOUBLE(10, 5),
							 t_Rudder_Angle DOUBLE(10, 5),
							 t_Seawater_Temperature DOUBLE(10, 5),
							 t_Speed_Through_Water DOUBLE(10, 5),
							 t_Delivered_Power DOUBLE(20, 3),
							 t_Air_Temperature DOUBLE(20, 3),
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
                        N)
	SELECT
		t.Speed_Through_Water / (sem.Speed_Through_Water - @ROOT2),
		t.Rudder_Angle / (sem.x_Rudder_Angle - @ROOT2),
		t.Relative_Wind_Direction / (sem.x_Relative_Wind_Direction - @ROOT2),
		t.Ship_Heading / (sem.x_Ship_Heading - @ROOT2),
		t.Delivered_Power / (sem.x_Delivered_Power - @ROOT2),
		t.Relative_Wind_Speed / (sem.x_Relative_Wind_Speed - @ROOT2),
		t.Speed_Over_Ground / (sem.x_Speed_Over_Ground - @ROOT2),
		t.Shaft_Revolutions / (sem.x_Shaft_Revolutions - @ROOT2),
		t.Water_Depth / (sem.x_Water_Depth - @ROOT2),
		t.Seawater_Temperature / (sem.x_Seawater_Temperature - @ROOT2),
		t.Air_Temperature / (sem.x_Air_Temperature - @ROOT2),
		1 / (1 + @p* t.Speed_Through_Water / (sem.Speed_Through_Water - @ROOT2) ) AS t_Speed_Through_Water,
		1 / (1 + @p* t.Rudder_Angle / (sem.Rudder_Angle - @ROOT2) ) AS t_Rudder_Angle,
		1 / (1 + @p* t.Relative_Wind_Direction / (sem.Relative_Wind_Direction - @ROOT2) ) AS t_Relative_Wind_Direction,
		1 / (1 + @p* t.Ship_Heading / (sem.Ship_Heading - @ROOT2) ) AS t_Ship_Heading,
		1 / (1 + @p* t.Delivered_Power / (sem.Delivered_Power - @ROOT2) ) AS t_Delivered_Power,
		1 / (1 + @p* t.Relative_Wind_Speed / (sem.Relative_Wind_Speed - @ROOT2) ) AS t_Relative_Wind_Speed,
		1 / (1 + @p* t.Speed_Over_Ground / (sem.Speed_Over_Ground - @ROOT2) ) AS t_Speed_Over_Ground,
		1 / (1 + @p* t.Shaft_Revolutions / (sem.Shaft_Revolutions - @ROOT2) ) AS t_Shaft_Revolutions,
		1 / (1 + @p* t.Water_Depth / (sem.Water_Depth - @ROOT2) ) AS t_Water_Depth,
		1 / (1 + @p* t.Seawater_Temperature / (sem.Seawater_Temperature - @ROOT2) ) AS t_Seawater_Temperature,
		1 / (1 + @p* t.Air_Temperature / (sem.Air_Temperature - @ROOT2) ) AS t_Air_Temperature,
        mu.N
			FROM `inservice`.del10Mins t
			JOIN `inservice`.mu10Mins mu
				ON mu.id = FLOOR((TO_SECONDS(t.DateTime_UTC) - TO_SECONDS(@startTime))/(600)) - @firstgroup + 1
			JOIN `inservice`.sem10Mins sem
				ON sem.id = FLOOR((TO_SECONDS(t.DateTime_UTC) - TO_SECONDS(@startTime))/(600)) - @firstgroup + 1;