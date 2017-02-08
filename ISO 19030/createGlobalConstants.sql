/* Create table for global constants */

USE hull_performance;


DROP TABLE IF EXISTS globalConstants;
CREATE TABLE globalConstants (id INT PRIMARY KEY AUTO_INCREMENT, Specific_Gas_Constant_Air DOUBLE(6, 3), g DOUBLE(10, 5));
INSERT INTO globalConstants (Specific_Gas_Constant_Air, g) VALUES (287.058, 9.80665);