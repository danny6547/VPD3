/* Create temporary table for speed-power data look-up */

CREATE TABLE tempSpeedPowerConditions (id INT PRIMARY KEY AUTO_INCREMENT,
								Displacement DOUBLE(10, 5),
								Difference_With_Nearest DOUBLE(10, 5),
                                Nearest_In_Speed_Power DOUBLE(10, 5),
                                Difference_PC DOUBLE(10, 5),
                                Displacement_Condition BOOLEAN,
                                Trim_Condition BOOLEAN,
                                Nearest_Neighbour_Condition BOOLEAN);