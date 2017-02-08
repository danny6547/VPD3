/* Create table for coefficients of SFOC fitted curve */

USE hull_performance;


CREATE TABLE SFOCCoefficients (id INT PRIMARY KEY AUTO_INCREMENT, Engine_Model VARCHAR(100), X0 DOUBLE(20, 10), X1 DOUBLE(20, 10),  X2 DOUBLE(20, 10), Minimum_FOC_ph DOUBLE(10, 3), Lowest_Given_Brake_Power DOUBLE(10, 3), Highest_Given_Brake_Power DOUBLE(10, 3));