DROP TABLE IF EXISTS mu10Mins;

CREATE TABLE mu10Mins (id INT PRIMARY KEY AUTO_INCREMENT,
							 DateTime_UTC DATETIME(3),
							 Relative_Wind_Speed DOUBLE(10, 5),
							 Relative_Wind_Direction DOUBLE(10, 5),
							 Speed_Over_Ground DOUBLE(10, 5),
							 Ship_Heading DOUBLE(10, 5),
							 Shaft_Revolutions DOUBLE(10, 5),
							 Water_Depth DOUBLE(10, 5),
							 Rudder_Angle DOUBLE(10, 5),
							 Seawater_Temperature DOUBLE(10, 5),
							 Speed_Through_Water DOUBLE(10, 5),
							 Delivered_Power DOUBLE(20, 3),
							 Air_Temperature DOUBLE(10, 8),
                             N INT);