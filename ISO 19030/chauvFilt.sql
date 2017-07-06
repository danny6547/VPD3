set @a1 := 0.254829592;
set @a2 := -0.284496736;
set @a3 := 1.421413741;
set @a4 := -1.453152027;
set @a5 := 1.061405429;

INSERT INTO ChauvenetTempFilter (ChauvFilt_Speed_Through_Water,
								ChauvFilt_Delivered_Power,
								ChauvFilt_Shaft_Revolutions,
								ChauvFilt_Relative_Wind_Speed, 
								ChauvFilt_Relative_Wind_Direction, 
								ChauvFilt_Speed_Over_Ground, 
								ChauvFilt_Ship_Heading, 
								ChauvFilt_Rudder_Angle, 
								ChauvFilt_Water_Depth, 
								ChauvFilt_Air_Temperature, 
								ChauvFilt_Seawater_Temperature)
	SELECT
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
		CASE x_Air_Temperature >= 0
			WHEN TRUE THEN (@a1*t_Air_Temperature + @a2*POWER(t_Air_Temperature, 2) + @a3*POWER(t_Air_Temperature, 3) + @a4*POWER(t_Air_Temperature, 4) + @a5*POWER(t_Air_Temperature, 5))*exp(-POWER(x_Air_Temperature, 2)) * N < 0.5                                                                                                                                                                   
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Air_Temperature + @a2*POWER(t_Air_Temperature, -2) + @a3*POWER(t_Air_Temperature, -3) + @a4*POWER(t_Air_Temperature, -4) + @a5*POWER(t_Air_Temperature, -5))*exp(-POWER(x_Air_Temperature, 2))) * N  < 0.5
		END AS ChauvFilt_Air_Temperature,
		CASE x_Seawater_Temperature >= 0
			WHEN TRUE THEN (@a1*t_Seawater_Temperature + @a2*POWER(t_Seawater_Temperature, 2) + @a3*POWER(t_Seawater_Temperature, 3) + @a4*POWER(t_Seawater_Temperature, 4) + @a5*POWER(t_Seawater_Temperature, 5))*exp(-POWER(x_Seawater_Temperature, 2)) * N < 0.5                                                                                                                                                                   
			WHEN FALSE THEN ( 2 - ABS(@a1*t_Seawater_Temperature + @a2*POWER(t_Seawater_Temperature, -2) + @a3*POWER(t_Seawater_Temperature, -3) + @a4*POWER(t_Seawater_Temperature, -4) + @a5*POWER(t_Seawater_Temperature, -5))*exp(-POWER(x_Seawater_Temperature, 2))) * N  < 0.5
		END AS ChauvFilt_Seawater_Temperature
			FROM erfc10Mins e;